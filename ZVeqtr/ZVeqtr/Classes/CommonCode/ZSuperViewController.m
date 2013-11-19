//
//  ZSuperViewController.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/15/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "SVProgressHUD.h"


@interface ZSuperViewController ()
@property (nonatomic, retain) UIView *superProgressView;
@end

@implementation ZSuperViewController

+ (id)controller {
	return [[self new] autorelease];
}

-  (void)viewDidUnload {
	[super viewDidUnload];
	[self releaseOutlets];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self releaseOutlets];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	LLog(@"==========================>>");
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
	LLog(@"==========================<<");
}

- (void)presentEmptyBackBarButtonItem {
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
}

- (UIBarButtonItem *)backBarButtonItem {
	return [self barButtonItemWithImageNamed:@"bbi-Back.png" action:@selector(actGoBack)];
}

- (void)presentBackBarButtonItem {
	self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
}

- (UIBarButtonItem *)saveBarButtonItem {
	return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(actSave)] autorelease];
	return [self barButtonItemWithImageNamed:@"btn-Save.png" action:@selector(actSave)];
}

- (void)presentSaveBarButtonItem {
	self.navigationItem.rightBarButtonItem = [self saveBarButtonItem];
}

- (UIBarButtonItem *)settingsBarButtonItem {
	return [self barButtonItemWithImageNamed:@"btn-Setting.png" action:@selector(actSettings)];
}

- (UIBarButtonItem *)homeBarButtonItem {
	return [self barButtonItemWithImageNamed:@"btn-Home.png" action:@selector(actGoHome)];
}

- (UIBarButtonItem *)barButtonItemWithImageNamed:(NSString *)imageName action:(SEL)action {
	UIImage *img = [UIImage imageNamed:imageName];
	if (!img) {
		return nil;
	}
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	[btn setImage:img forState:UIControlStateNormal];
	btn.frame = (CGRect){CGPointZero, img.size};
	return [[[UIBarButtonItem alloc] initWithCustomView:btn] autorelease];
}




- (IBAction)actGoBack
{
    if(self.presenterViewController)
    {
        [self.presenterViewController dismissViewControllerAnimated:YES completion:nil];
    }
	else if (self.navigationController)
    {
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
    {
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (IBAction)actGoHome
{
	[APP_DLG goHome];
}

- (IBAction)actSave
{
	
}

- (IBAction)actSettings
{
	
}

- (IBAction)actEdit
{
    
}

- (IBAction)actDone
{
    
}

- (void)releaseOutlets
{
	self.superProgressView = nil;
}

#pragma mark - Progress

- (void)showProgress
{
	if (self.superProgressView)
    {
		return;
	}
	
	UIView *grayView = [[UIView alloc] initWithFrame:self.view.bounds];
	grayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
	self.superProgressView = grayView;
	[self.view addSubview:grayView];
	[grayView release];
	
	[SVProgressHUD showWithStatus:nil];
}

- (void)hideProgress {
	[SVProgressHUD dismiss];
	
	[self.superProgressView removeFromSuperview];
	self.superProgressView = nil;
}

@end







#pragma mark - Keyboard Notifications

@implementation ZSuperViewController (Keyboard)

- (void)subscribeForKeyboardNotifications {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
	[nc addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
	[nc addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
	[nc addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)unsubscribeFromKeyboardNotifications {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[nc removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[nc removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
	//	Example:
	//	NSNumber *duration = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	//	NSValue *valFrame = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
	//	CGRect kbFrame = [valFrame CGRectValue];
}

- (void)keyboardDidShowNotification:(NSNotification *)notification {
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
}

- (void)keyboardDidHideNotification:(NSNotification *)notification {
}

@end





#pragma mark - Taking a Picture

@implementation ZSuperViewController (TakePicture)

- (void)takePicture {
	
	BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	BOOL hasLibrary= [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
	
	if (!hasCamera && !hasLibrary) {
		LLog(@"Neither cam nor lib");
		return;
	}
	
	UIActionSheet *sheet = hasCamera ?
	[[UIActionSheet alloc] initWithTitle:@"Choose a Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Camera", @"From Library", nil] :
	[[UIActionSheet alloc] initWithTitle:@"Choose a Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Library", nil];
	
	sheet.tag = 999;
	[sheet showInView:self.view];
//  [sheet showInView:self.viewContainer];
	[sheet release];
}


#pragma mark - UIActionSheet
//-   (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	if (actionSheet.tag != 999) {
		return;
	}
	
	UIImagePickerController *picker = [UIImagePickerController new];
	picker.delegate = self;
	
	BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	picker.sourceType = (hasCamera && buttonIndex == 0) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
	
	[self.navigationController presentModalViewController:picker animated:YES];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissModalViewControllerAnimated:YES];
	
	UIImage *picture = info[UIImagePickerControllerEditedImage];
	if (!picture) {
		picture = info[UIImagePickerControllerOriginalImage];
		[self savePicture:picture];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)savePicture:(UIImage *)picture {
	LLog(@"Override this (picture:%@)", picture);
}

@end
