//
//  MHControlsTabBarController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
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

#import <Foundation/Foundation.h>

extern NSString * const TPControlsTabSelectionDidChangeNotification;

@interface MHControlsTabBarController : NSViewController <NSTabViewDelegate> {
@private
  NSArray *buttons;
}

@property (unsafe_unretained) IBOutlet NSButton *projectButton;
@property (unsafe_unretained) IBOutlet NSButton *palletButton;
@property (unsafe_unretained) IBOutlet NSButton *libraryButton;
@property (unsafe_unretained) IBOutlet NSButton *outlineButton;
@property (unsafe_unretained) IBOutlet NSButton *findButton;
@property (unsafe_unretained) IBOutlet NSButton *infoButton;
@property (unsafe_unretained) IBOutlet NSButton *prefsButton;
@property (unsafe_unretained) IBOutlet NSSplitView *splitview;
@property (unsafe_unretained) IBOutlet NSTabView *tabView;

- (id)initWithMode:(BOOL)standAlone;

- (void) toggleOn:(id)except;
- (NSInteger) indexOfSelectedTab;
- (void) selectTabAtIndex:(NSInteger)index;

- (IBAction)buttonSelected:(id)sender;

- (id) buttonForTabIndex:(NSInteger)index;
- (NSInteger)tabIndexForButton:(id)sender;

#pragma mark -
#pragma mark Control

- (IBAction) showProjectTree:(id)sender;
- (void) showProjectTree;
- (IBAction) showSymbolPalette:(id)sender;
- (void) showSymbolPalette;
- (IBAction) showClippingsLibrary:(id)sender;
- (void) showClippingsLibrary;
- (IBAction) showDocumentOutline:(id)sender;
- (void) showDocumentOutline;
- (IBAction) showProjectSearch:(id)sender;
- (void) showProjectSearch;
- (IBAction) showFileInfo:(id)sender;
- (void) showFileInfo;
- (IBAction) showProjectSettings:(id)sender;
- (void) showProjectSettings;
- (IBAction) showNavigator:(id)sender;
- (IBAction) hideNavigator:(id)sender;

- (void) tearDown;

@end
