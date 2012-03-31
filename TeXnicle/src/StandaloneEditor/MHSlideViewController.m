//
//  MHSlideViewController.m
//  SlidePanel
//
//  Created by Martin Hewitson on 31/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "MHSlideViewController.h"

@implementation MHSlideViewController

@synthesize contentView;
@synthesize sidePanel;
@synthesize mainPanel;
@synthesize rightSided;

- (void) awakeFromNib
{
  _sidePanelisVisible = YES;
  self.rightSided = YES;
}

- (IBAction)togglePanel:(id)sender
{
  if (!_sidePanelisVisible) {
    // slide in 
    [self slideInAnimate:YES];
  } else {
    // slide out
    [self slideOutAnimate:YES];
  }
}

- (void) slideInAnimate:(BOOL)animate
{
  if (_sidePanelisVisible)
    return;
  
  NSRect sr = [sidePanel frame];
  NSRect mr = [mainPanel frame];
  NSRect fr = [contentView frame];
  NSRect nsr;
  NSRect nmr;
  CGFloat w = sr.size.width;
  // slide in 
  if (self.rightSided) {
    nsr = NSMakeRect(fr.size.width-w, sr.origin.y, sr.size.width, sr.size.height);
    nmr = NSMakeRect(0, mr.origin.y, fr.size.width-w, mr.size.height);
  } else {
    nsr = NSMakeRect(0, sr.origin.y, sr.size.width, sr.size.height);
    nmr = NSMakeRect(w, mr.origin.y, fr.size.width-w, mr.size.height);
  }
  if (animate) {
    [[sidePanel animator] setFrame:nsr];
    [[mainPanel animator] setFrame:nmr];
  } else {
    [sidePanel setFrame:nsr];
    [mainPanel setFrame:nmr];
  }
  _sidePanelisVisible = YES;
}

- (void) slideOutAnimate:(BOOL)animate
{
  if (!_sidePanelisVisible)
    return;
  
  NSRect sr = [sidePanel frame];
  NSRect mr = [mainPanel frame];
  NSRect fr = [contentView frame];
  NSRect nsr;
  NSRect nmr;
  CGFloat w = sr.size.width;
  // slide out
  if (self.rightSided) {
    nsr = NSMakeRect(fr.size.width+1, sr.origin.y, sr.size.width, sr.size.height);
    nmr = NSMakeRect(0, mr.origin.y, fr.size.width, mr.size.height);
  } else {
    nsr = NSMakeRect(-w, sr.origin.y, sr.size.width, sr.size.height);
    nmr = NSMakeRect(0, mr.origin.y, fr.size.width, mr.size.height);
  }
  if (animate) {
    [[sidePanel animator] setFrame:nsr];
    [[mainPanel animator] setFrame:nmr];
  } else {
    [sidePanel setFrame:nsr];
    [mainPanel setFrame:nmr];
  }
  _sidePanelisVisible = NO;
}

@end
