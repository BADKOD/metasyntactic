// Copyright 2010 Cyrus Najmabadi
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import "TweetViewController.h"

#import "AbstractTableViewCell.h"
#import "MetasyntacticSharedApplication.h"

@interface TweetViewController()
@property (retain) UITextView* textView;
@property (retain) UITextView* dummyTextView;
@property (retain) UILabel* label;
@property (retain) AbstractTwitterAccount* account;
@end


@implementation TweetViewController

@synthesize textView;
@synthesize dummyTextView;
@synthesize label;
@synthesize account;

- (void) dealloc {
  self.textView = nil;
  self.dummyTextView = nil;
  self.label = nil;
  self.account = nil;

  [super dealloc];
}

static const NSInteger CELL_HEIGHT = 150;
static const NSInteger MAX_TWITTER_LENGTH = 140;

- (NSString*) labelText {
  NSInteger remainder = MAX_TWITTER_LENGTH - textView.text.length;
  return [NSString stringWithFormat:LocalizedString(@"Characters Left: %d", nil), remainder];
}


- (void) enforceConstraints {
  NSString* text = textView.text;
  if (text.length > MAX_TWITTER_LENGTH) {
    text = [text substringToIndex:MAX_TWITTER_LENGTH];
    textView.text = text;
  }

  label.text = [self labelText];
}


- (void) majorRefresh {
}


- (void) minorRefresh {
}


- (id) initWithTweet:(NSString*) tweet_
             account:(AbstractTwitterAccount*) account_ {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.account = account_;

    self.textView = [[[UITextView alloc] initWithFrame:CGRectZero] autorelease];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    textView.text = tweet_;
    textView.font = [UIFont boldSystemFontOfSize:17];
    textView.delegate = self;
    textView.backgroundColor = [UIColor clearColor];
    textView.returnKeyType = UIReturnKeyDefault;

    self.label = [self createGroupedFooterLabel:[UIColor grayColor]
                                           text:[self labelText]];


    self.dummyTextView = [[[UITextView alloc] initWithFrame:CGRectZero] autorelease];

    [self.view addSubview:textView];
    [self.view addSubview:dummyTextView];

    self.title = LocalizedString(@"Tweet", nil);
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.rowHeight = CELL_HEIGHT;

    self.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Send", nil)
                                      style:UIBarButtonItemStyleDone
                                     target:self
                                     action:@selector(onSend)] autorelease];

    [self enforceConstraints];
  }

  return self;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
  return 1;
}


- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
  return 1;
}


- (UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
  UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  [cell.contentView addSubview:textView];

  return cell;
}


- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
}


- (void) loadView {
  [super loadView];

  textView.frame =
    CGRectMake(0, 0,
               self.view.frame.size.width,
               CELL_HEIGHT);

  CGRect frame = label.frame;
  frame.origin.x = textView.frame.origin.x;
  frame.origin.y = textView.frame.origin.y + textView.frame.size.height + 10;
  frame.size.width = textView.frame.size.width;
  label.frame = frame;

  [textView becomeFirstResponder];
}


- (void) dismissKeyboard {
  [dummyTextView becomeFirstResponder];
  [dummyTextView resignFirstResponder];
}


- (void) viewWillDisappear:(BOOL)animated {
  [self dismissKeyboard];
  [super viewWillDisappear:animated];
}


- (void)textViewDidChange:(UITextView *)textView {
  [self enforceConstraints];
}


- (void)textViewDidEndEditing:(UITextView *)textView_ {
  [textView_ resignFirstResponder];
}


- (UIView*)        tableView:(UITableView*) tableView
      viewForFooterInSection:(NSInteger) section {
  return [self createGroupedFooterLabelView:label];
}


- (void) onSend {
  [account sendUpdate:textView.text];
  [self dismissKeyboard];
  [self.navigationController popViewControllerAnimated:YES];
}

@end
