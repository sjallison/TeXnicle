//
//  TPSyntaxError.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TPSyntaxError.h"
#import "RegexKitLite.h"

@implementation TPSyntaxError

@synthesize line;
@synthesize message;

+ (id) errorWithMessageLine:(NSString*)aLine
{
  return [[[TPSyntaxError alloc] initWithMessageLine:aLine] autorelease];
}

- (id) initWithMessageLine:(NSString*)aLine
{
  self = [super init];
  if (self) {
    
    self.line = [NSNumber numberWithInteger:NSNotFound];
    self.message = @"";
    
    [self parseMessageLine:aLine];
    
  }
  return self;
}

- (void) parseMessageLine:(NSString*)aLine
{
  NSArray *comps = [aLine captureComponentsMatchedByRegex:@"line ([0-9]*):(.*)"];
  if ([comps count] >= 2) {
    self.line = [NSNumber numberWithInteger:[[comps objectAtIndex:1] integerValue]];
  }
  if ([comps count] >= 3) {
    self.message = [comps objectAtIndex:2];
  }
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"line %@: %@", self.line, self.message];
}

- (NSAttributedString*)attributedString
{
  NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
  
  // line number
  NSMutableAttributedString *lineNumber = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"line %@: ", self.line]] autorelease];
  [lineNumber addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(0, [lineNumber length])];
  [str appendAttributedString:lineNumber];

  // message 
  NSMutableAttributedString *messageString = [[[NSMutableAttributedString alloc] initWithString:self.message] autorelease];
  [messageString addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0, [messageString length])];
  [str appendAttributedString:messageString];
  
  return str;
}

@end
