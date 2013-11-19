//
//  EditTextViewController
//  Peek
//
//  Created by Pavel on 29.06.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import "EditTextViewController.h"


@interface EditTextViewController()
//	outlets
@property (nonatomic, retain) IBOutlet UITextView *textView;
@end


@implementation EditTextViewController

@synthesize index;

- (void)releaseOutlets {
	[super releaseOutlets];
	self.textView = nil;
    self.userModel = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font) {
		self.textView.font = font;
	}

	[super presentBackBarButtonItem];
    [super presentSaveBarButtonItem];
	
	self.title = @"Custom Text";
    
    NSString *key = [NSString stringWithFormat:@"ln%d", index];
	
	NSString *_text = [self.userModel.customFields objectForKey:key];
	if (_text && [_text length] > 0) {
		self.textView.text = _text;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.navigationController.navigationBarHidden) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self.textView becomeFirstResponder];
}

- (IBAction)backPressed {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actSave
{
	NSString *key = [NSString stringWithFormat:@"ln%d", index];
	
    [self.userModel.customFields setObject:self.textView.text forKey:key];
    
	[[NSUserDefaults standardUserDefaults] setObject:self.textView.text forKey:key];
	
	[self backPressed];
}

#pragma mark -
#pragma mark Notifications

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    // the keyboard is showing so resize the table's height
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
    [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.size.height -= UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ?  keyboardRect.size.height : keyboardRect.size.width;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    // the keyboard is hiding reset the table's height
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
    [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.size.height += UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ?  keyboardRect.size.height : keyboardRect.size.width;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}

@end
