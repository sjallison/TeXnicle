//
//  MHFoldingTag.m
//  TeXnicle
//
//  Created by Martin Hewitson on 01/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "MHFoldingTagDescription.h"
#import "NSString+Extension.h"

@implementation MHFoldingTagDescription

@synthesize startTag;
@synthesize endTag;
@synthesize hasFollowingArgument;
@synthesize index;

+ (MHFoldingTagDescription*)deepCopyOfTag:(MHFoldingTagDescription*)aTag
{
  MHFoldingTagDescription *tag = [MHFoldingTagDescription foldingTagWithStartTag:aTag.startTag endTag:aTag.endTag followingArgument:aTag.hasFollowingArgument];
  tag.index = aTag.index;
  return tag;
}

+ (MHFoldingTagDescription*)foldingTagWithStartTag:(NSString*)aStartTag endTag:(NSString*)anEndTag followingArgument:(BOOL)hasArgument
{
  return [[MHFoldingTagDescription alloc] initWithStartTag:aStartTag endTag:anEndTag followingArgument:hasArgument];
}

- (id)initWithStartTag:(NSString*)aStartTag endTag:(NSString*)anEndTag followingArgument:(BOOL)hasArgument
{
  self = [super init];
  if (self) {
    // Initialization code here.
    self.startTag = aStartTag;
    self.endTag = anEndTag;
    self.hasFollowingArgument = hasArgument;
  }
  
  return self;
}


+ (MHFoldingTagDescription*) foldingTagInLine:(NSString*)line atIndex:(NSInteger*)index fromTags:(NSArray*)tags matched:(NSInteger*)matchingTag
{
  NSInteger idx = *index;
  
//	NSString *testline = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//  NSLog(@"Looking for folder in line %ld, %@", idx, line);
  
  if (idx >= [line length]) {
    *index = NSNotFound;
    return nil;
  }
  NSInteger lineStart = idx;
  line = [line substringFromIndex:lineStart];
  NSInteger tagStart;
	
	for (MHFoldingTagDescription *tag in tags) {		
		// check for start tag first
    tagStart = [line indexOfFirstMatch:tag.startTag];
		if (tagStart != NSNotFound) {
      *matchingTag = MHFoldingTagStartMatched;
//      NSLog(@"Matching tag at index %ld", idx);
      idx = tagStart + [tag.startTag length];
      if (tag.hasFollowingArgument) {
        while (idx<[line length]) {
          if ([line characterAtIndex:idx] == '}') {
            idx++;
            break;
          }
          idx++;
        }
      }
      //      NSLog(@"Matched start tag: %@", tag.startTag);
      *index += idx;
      MHFoldingTagDescription *returnTag = [MHFoldingTagDescription deepCopyOfTag:tag];
      returnTag.index = tagStart;
			return returnTag;
		}
    
    // check for end tag
    tagStart = [line indexOfFirstMatch:tag.endTag];
		if (tagStart != NSNotFound) {
      *matchingTag = MHFoldingTagEndMatched;
      idx = tagStart+ [tag.endTag length];
      if (tag.hasFollowingArgument) {
        while (idx<[line length]) {
          if ([line characterAtIndex:idx] == '}') {
            idx++;
            break;
          }
          idx++;
        }
      }
      *index += idx;
      MHFoldingTagDescription *returnTag = [MHFoldingTagDescription deepCopyOfTag:tag];
      returnTag.index = tagStart;
			return tag;
		}    
    
	}
//  NSLog(@"Not found");
  *index = NSNotFound;
	return nil;
}


@end
