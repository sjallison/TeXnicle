//
//  TPOutlineBuilder.m
//  TeXnicle
//
//  Created by Martin Hewitson on 9/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPOutlineBuilder.h"
#import "TPSectionTemplate.h"
#import "NSString+LaTeX.h"
#import "NSString+Comparisons.h"
#import "FileEntity.h"
#import "externs.h"
#import "TPFileMetadata.h"
#import "NSString+SectionsOutline.h"
#import "NSArray+Color.h"
#import "TPDocumentSectionManager.h"

@interface TPOutlineBuilder ()

@property (assign) BOOL isUpdating;

@end

@implementation TPOutlineBuilder

+ (id) outlineBuilderWithDelegate:(id<TPOutlineBuilderDelegate>)aDelegate
{
  return [[TPOutlineBuilder alloc] initWithDelegate:aDelegate];
}

- (id) initWithDelegate:(id<TPOutlineBuilderDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
    // ensure the section manager makes its templates
    TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
    self.depth = [sm.templates count]-1;
    self.sections = [NSMutableArray array];
    self.isUpdating = NO;
    queue = dispatch_queue_create("com.bobsoft.TeXnicle.outlineArray", DISPATCH_QUEUE_SERIAL);
        
  }
  
  return self;
}


- (void) stopTimer
{
  if (self.timer) {
//    NSLog(@"Invalidate timer...");
    [self.sections removeAllObjects];
    [self.timer invalidate];
    self.timer = nil;
  }
}

- (void) startTimer
{
  [self stopTimer];
  
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                target:self
                                              selector:@selector(buildOutline) 
                                              userInfo:nil
                                               repeats:YES];
}


- (void) dealloc
{
//  NSLog(@"Dealloc %@", self);
}

- (void) tearDown
{
#if TEAR_DOWN
  NSLog(@"Tear down %@", self);
#endif
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self stopTimer];
  self.delegate = nil;
//  dispatch_release(queue);
  [self.sections removeAllObjects];
}

- (void) buildOutline
{
//  NSLog(@"Build outline...");
  NSApplication *app = [NSApplication sharedApplication];
  if ([app isActive] == NO) {
    return;
  }
  
  if ([self shouldGenerateOutline] == NO && [self.sections count] > 0) {
//    NSLog(@"   NO: Delegate says no, and I have sections already");
    return;
  }
  
  __block TPDocumentSectionManager *sm = [TPDocumentSectionManager sharedSectionManager];
  __block TPOutlineBuilder *blockSelf = self;
  __block NSArray *metafiles = [self allMetadataFiles];
  
  // if we have unscanned files, return since we must be mid-generation
  NSInteger noCount = 0;
  for (TPFileMetadata *file in metafiles) {
    if (file.wasScannedForSections == NO) {
      noCount ++;
    }
  }
  
  if (noCount < [metafiles count] && noCount > 0) {
    return;
  }
  
  for (TPFileMetadata *file in metafiles) {
    file.wasScannedForSections = NO;
  }
  
  NSArray *templatesToScanFor = [sm.templates subarrayWithRange:NSMakeRange(0, 1+self.depth)];
  
  // get the main file from the delegate
  id file = nil;
  if ([self shouldFocusOnFile]) {
    file = [self focusFile];
  } else {
    file = [self mainFile];
  }
  
//  NSLog(@"  main file %@ [%@]", [file valueForKey:@"name"], file);
  if ([file isKindOfClass:[TPFileMetadata class]]) {
    
    __block TPOutlineBuilder *blockSelf = self;
    dispatch_async(queue, ^{
      
//      NSLog(@"   computing sections...");
      NSArray *newSections = [file generateSectionsForTypes:templatesToScanFor
                                                      files:metafiles
                                                forceUpdate:NO];
//      NSLog(@"  got %ld", [newSections count]);
//      NSLog(@"   processing sections...");
      [blockSelf processNewSections:newSections forFile:file templates:templatesToScanFor];
//      NSLog(@"      done");
      for (TPFileMetadata *file in metafiles) {
        file.wasScannedForSections = NO;
      }
    });
    
    

  } else {
    // get text
    NSString *text = [self textForFile:file];
        
    dispatch_async(queue, ^{
      NSArray *newSections = [text sectionsInStringForTypes:templatesToScanFor
                                           existingSections:blockSelf.sections
                                                     inFile:file];
      
      [blockSelf processNewSections:newSections forFile:file templates:templatesToScanFor];
    });
            
  }
  
}

- (NSInteger) documentCountInArray:(NSArray*)array
{
  NSInteger count = 0;
  for (TPSection *s in array) {
    //NSLog(@"Checking %@", s);
    if ([s.name isEqualToString:@"document"]) {
      count++;
    }
  }
  
  return count;
}

- (void) processNewSections:(NSArray*)sections forFile:(id)file templates:(NSArray*)templates
{
  NSMutableArray *newSections = [NSMutableArray arrayWithArray:sections];
  NSMutableArray *remove = [NSMutableArray array];
  
  TPFileMetadata *mainfile = [self mainFile];
  if (mainfile && [mainfile isKindOfClass:[TPFileMetadata class]]) {
    NSString *mainFileName = mainfile.name;
    for (TPSection *s in newSections) {
      // strip out 'document' leafs for subfiles support
      if ([s.name isEqualToString:@"document"] && [s.filename isEqualToString:mainFileName] == NO) {
        [remove addObject:s];
      }
    }
    [newSections removeObjectsInArray:remove];
  }
  
  NSArray *existingSections = self.sections;
  
  // check if we have a root section, otherwise insert it, or reuse it
  if ([newSections count] > 0) {
    TPSection *firstSection = newSections[0];
//    NSLog(@"First section %@", firstSection);
    
    if ([firstSection.type.name isEqualToString:@"begin"] == NO) {
      
      NSString *rootName = @"Root";
      if ([file isKindOfClass:[TPFileMetadata class]]) {
        TPFileMetadata *meta = (TPFileMetadata*)file;
        rootName = meta.name;
      }
      
      TPSection *root = [TPSection sectionWithParent:nil start:0 inFile:file type:templates[0] name:rootName];
      
      // see if we have an existing root which matches what we would anyway insert
      TPSection *firstExistingSection = nil;
      if ([existingSections count] > 0) {
        firstExistingSection = existingSections[0];
      }
      
      if (firstExistingSection != nil && [firstExistingSection matches:root]) {
        
        [newSections insertObject:firstExistingSection atIndex:0];
        
      } else {
        
//        NSLog(@"Inserting root");
        root.needsReload = YES;
        [newSections insertObject:root atIndex:0];
        
        // set all other parents to nil because they are invalid now
        for (TPSection *s in newSections) {
          s.parent = nil;
        }
      }
    }
    
    // get new root
    if ([existingSections count] > 0) {
      TPSection *root = newSections[0];
      TPSection *existingRoot = existingSections[0];
      
      // if the new root doesn't match the old root, reset all parents
      if ([root matches:existingRoot] == NO) {
        // set all other parents to nil because they are invalid now
        for (TPSection *s in newSections) {
          s.parent = nil;
        }
      }
    }
  }
  
//  NSLog(@"Got sections %@", newSections);
  
//  NSLog(@"Updating sections...");
  NSArray *updatedSections = [self getUpdatedSections:newSections];
  
  if (updatedSections) {
//    NSLog(@"Updated sections %@", updatedSections);
    
    [self.sections removeAllObjects];
    [self.sections addObjectsFromArray:updatedSections];
    
    self.isUpdating = NO;
    
    // inform delegate
    dispatch_async(dispatch_get_main_queue(), ^{
      [self didComputeNewSections];
    });
  }
//  NSLog(@"--------------------------------------------  update done");
}

- (NSArray*) getUpdatedSections:(NSArray*)newSections
{
  NSInteger existingSectionsCount = [self.sections count];
  NSInteger newSectionsCount = [newSections count];
  
  // update parents
  if ([newSections count] > 0) {
    // set parents
    TPSection *root = newSections[0];
    
    if (newSectionsCount != existingSectionsCount) {
      // reload
      root.needsReload = YES;
    }
    
    for (int kk=1; kk<[newSections count]; kk++) {
      TPSection *s = newSections[kk];
      
      int jj = kk-1;
      TPSection *parent = newSections[jj];
      while (jj>=0) {
        if ([TPSectionTemplate template:s.type isChildOf:parent.type]) {
          if (s.parent != parent) {
            s.parent = parent;
            parent.needsReload = YES;
          }
          break;
        }
        if (jj>=0) {
          parent = newSections[jj];
        }
        jj--;
      }
      
      if (s.parent == nil) {
        s.parent = root;
      }
      
    }
  }
  
  
  return newSections;  
}



#pragma mark -
#pragma mark delegate

- (NSArray*) allMetadataFiles
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(allMetadataFiles)]) {
    return [self.delegate performSelector:@selector(allMetadataFiles)];
  }
  
  return @[];
}

- (BOOL) shouldFocusOnFile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(shouldFocusOnFile)]) {
    return [self.delegate shouldFocusOnFile];
  }
  
  return NO;
}

- (id) focusFile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(focusFile)]) {
    return [self.delegate focusFile];
  }
  
  return nil;
}

- (id) mainFile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(mainFile)]) {
    return [self.delegate mainFile];
  }
  
  return nil;
}

- (NSString*) textForFile:(id)aFile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(textForFile:)]) {
    return [self.delegate textForFile:aFile];
  }
  
  return @"";
}

- (void) didComputeNewSections
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(didComputeNewSections)]) {
    [self.delegate didComputeNewSections];
  }
}

- (BOOL) shouldGenerateOutline
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(shouldGenerateOutline)]) {
    return [self.delegate shouldGenerateOutline];
  }
  
  return NO;
}


@end
