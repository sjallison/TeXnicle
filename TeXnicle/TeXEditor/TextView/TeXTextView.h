//
//  TeXTextView.h
//  TeXEditor
//
//  Created by hewitson on 27/3/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UKTextDocGoToBox.h"




@class MHEditorRuler;
@class MHCodeFolder;
@class TeXColoringEngine;
@class TPPopupListWindowController;

@protocol TeXTextViewDelegate <NSTextViewDelegate>

-(id)project;
-(NSArray*)listOfCitations;
-(NSArray*)listOfReferences;
-(NSArray*)listOfTeXFilesPrependedWith:(NSString*)prefix;
-(NSArray*)listOfCommands;
-(BOOL)shouldSyntaxHighlightDocument;

@end

@interface TeXTextView : NSTextView <UKTextDocGoToBoxTarget> {
@private
	TPPopupListWindowController *popupList;
  
  MHEditorRuler *editorRuler;
  TeXColoringEngine *coloringEngine;
  NSString *highlightRange;
  NSColor *lineHighlightColor;
  
	// Character sets
	NSCharacterSet *newLineCharacterSet;
	NSCharacterSet *whitespaceCharacterSet;
  
  NSMutableArray *syntaxHighlightTags;
  
  NSTimer *highlightingTimer;
  
  BOOL shiftKeyOn;
  
	// Go to line
	IBOutlet UKTextDocGoToBox *goToLineController;
    
  NSMutableArray *commandList;
  NSMutableArray *beginList;
}

@property (retain) NSTimer *highlightingTimer;
@property (retain) MHEditorRuler *editorRuler;
@property (retain) TeXColoringEngine *coloringEngine;
@property (retain) NSColor *lineHighlightColor;
@property (copy) NSString *highlightRange;
@property (retain) NSMutableArray *syntaxHighlightTags;
@property (assign) BOOL shiftKeyOn;
@property (retain) NSMutableArray *commandList;
@property (retain) NSMutableArray *beginList;

- (void) setupLists;
- (void) setUpRuler;
- (void) defaultSetup;
- (void) turnOffWrapping;
- (void) updateEditorRuler;
- (void) setTypingColor:(NSColor*)aColor;
- (void) applyFontAndColor;
- (void) setWrapStyle;
- (void) handleFrameChangeNotification:(NSNotification*)aNote;

#pragma mark -
#pragma mark GoTo Box protocol methods 

- (IBAction) gotoLine:(id)sender;
-(void)	goToCharacter: (int)charNum;
-(void)	goToLine: (int)targetLineNumber;
-(void) goToRangeFrom: (int)startCh toChar: (int)endCh;

#pragma mark -
#pragma mark Control

- (IBAction) toggleControlCharacters:(id)sender;
- (IBAction) toggleInvisibleCharacters:(id)sender;
- (IBAction) toggleCommentForSelection:(id)sender;

- (IBAction) showSpellingList:(id)sender;
- (IBAction)complete:(id)sender;

#pragma mark -
#pragma mark Text Storage Observing

- (void) processEditing:(NSNotification*)aNote;
- (void) stopObservingTextStorage;
- (void) observeTextStorage;


#pragma mark -
#pragma mark Syntax highlighting

- (void) resetLineNumbers;
- (void) colorWholeDocument;
- (void) colorVisibleText;

#pragma mark -
#pragma mark KVO 
- (void) stopObserving;
- (void) observePreferences;

#pragma mark -
#pragma mark Folding

- (IBAction) unfoldSelection:(id)sender;
- (IBAction) collapseAll:(id)sender;
- (IBAction) expandAll:(id)sender;
- (void) unfoldAllInRange:(NSRange)aRange max:(NSInteger)max;
- (void) unfoldTextWithFolder:(MHCodeFolder*)aFolder;
- (void) foldTextWithFolder:(MHCodeFolder*)aFolder;
- (void) unfoldAttachment:(NSTextAttachment*)snippet atIndex:(NSNumber*)index;

#pragma mark -
#pragma mark Completion and spelling

- (void) completeFromList:(NSArray*)aList;
- (void) insertFromList:(NSArray*)aList;
- (IBAction) showSpellingList:(id)sender;
- (void) insertWordAtCurrentLocation:(NSString*)aWord;
- (void) replaceWordUpToCurrentLocationWith:(NSString*)aWord;
- (void) replaceWordAtCurrentLocationWith:(NSString*)aWord;
- (void) clearSpellingList;
- (NSArray*)userDefaultCommands;

#pragma mark -
#pragma mark Selection

- (void) selectRange:(NSRange)aRange scrollToVisible:(BOOL)scroll animate:(BOOL)animate;
- (NSInteger) lengthOfLineUpToLocation:(NSUInteger)location;
- (NSRange) rangeForCurrentParagraph;
- (NSInteger) locationOfLastWhitespaceLessThan:(NSInteger)lineWrapLength;
- (NSString*) currentLineToCursor;
- (NSRange) getVisibleRange;
- (void) selectUpToCurrentLocation;
- (void) handleSelectionChanged:(NSNotification*)aNote;
- (NSRect) highlightRectForRange:(NSRange)aRange;
- (void) clearHighlight;
- (NSRange) rangeForCurrentParagraph;
- (NSRange) rangeForCurrentWord;
- (NSString*) currentWord;
- (NSPoint) listPointForCurrentWord;

- (void) checkForMatchingBracketAfterMovingLeft;
- (void) checkForMatchingBracketAfterMovingRight;
- (void) checkForMatchingBracket:(unichar)aChar offsetFrom:(NSInteger)index by:(NSInteger)offset;
- (NSInteger)searchBackwardsForChar:(unichar)openBracket matching:(unichar)closeBracket startingAt:(NSInteger)loc;
- (NSInteger)searchForwardsForChar:(unichar)closeBracket matching:(unichar)openBracket startingAt:(NSInteger)loc;
- (NSInteger)findMatchingBracketOfType:(unichar)aChar atIndex:(NSInteger)index;
- (void) wrapLine;

- (NSInteger)cursorPosition;
- (NSInteger)lineNumber;
- (NSUInteger)characterIndexOfPoint:(NSPoint)aPoint;

#pragma mark -
#pragma mark Formatting text

- (void) insertStringBeforeAllLinesInSelection:(NSString*)aStr;
- (IBAction) reformatParagraph:(id)sender;
- (IBAction) reformatRange:(NSRange)pRange;
- (IBAction) indentSelection:(id)sender;
- (IBAction) unindentSelection:(id)sender;

- (void) insertIncludeForFile:(NSString*)aFile atLocation:(NSUInteger)location;
- (void) insertImageBlockForFile:(NSString*)aFile atLocation:(NSUInteger)location;

@end
