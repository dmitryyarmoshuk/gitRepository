//
//  NewMessageViewController.m
//  Peek
//
//  Created by Pavel on 16.09.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import "NewMessageViewController.h"
#import "ZNewMessageModel.h"
#import "SBJson.h"


@interface NewMessageViewController ()
//	outlets
@property (nonatomic, retain) IBOutlet UITextField			*fieldTitle;
@property (nonatomic, retain) IBOutlet UITextView			*textView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem		*buttonClear;
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segmentPrivacy;
@property (nonatomic, retain) NSString	*imagePath;
@property (nonatomic, retain) NSString	*txtSubject;
@property (nonatomic, retain) NSString	*txtMessageBody;

@end
	
	
@implementation NewMessageViewController

- (void)dealloc {
	self.imagePath = nil;
	self.txtSubject = nil;
	self.txtMessageBody = nil;
	[super dealloc];
}

- (void)releaseOutlets {
	[super releaseOutlets];
	self.fieldTitle = nil;
	self.textView = nil;
	self.buttonClear = nil;
	self.segmentPrivacy = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self buttonClearPressed];
	
    self.segmentPrivacy.hidden = self.isDirectMessage;
    
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font) {
		_fieldTitle.font = font;
		_textView.font = font;
	}

	
	self.title = @"New Message";

	[super presentBackBarButtonItem];
	[super presentSaveBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.navigationController.navigationBarHidden) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}

	//	restore text if any
	_fieldTitle.text = self.txtSubject;
	_textView.text = self.txtMessageBody;

	[_fieldTitle becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	//	save text
	self.txtSubject = [_fieldTitle.text trimWhitespace];
	self.txtMessageBody = [_textView.text trimWhitespace];
}

#pragma mark -

- (void)openPhotoController:(BOOL)isCamera {

	UIImagePickerController *controller = [[UIImagePickerController new] autorelease];
	controller.sourceType = isCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
	((UIImagePickerController *)controller).delegate = self;
	
	
	[self presentModalViewController:controller animated:YES];
}

#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
		
		[self openPhotoController:YES];
		
	} else if (buttonIndex == 1) {
		
		[self openPhotoController:NO];
		
	}
}

#pragma mark - Actions

- (IBAction)buttonClearPressed {
	
	NSString *path = [@"image.jpg" docPath];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if ([fm fileExistsAtPath:path]) {
		[fm removeItemAtPath:path error:nil];
	}
	
	self.imagePath = nil;
	_buttonClear.enabled = NO;
}

- (IBAction)buttonCameraPressed {
	
	[self.view endEditing:YES];
	
	//	save text
	self.txtSubject = [_fieldTitle.text trimWhitespace];
	self.txtMessageBody = [_textView.text trimWhitespace];

	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
									  @"Take Photo", @"Choose Existing", nil];
		
		[actionSheet showInView:self.navigationController.view];
		[actionSheet release];
	}
	else {
		
		[self openPhotoController:NO];
	}
}

- (IBAction)backPressed {
	[self.delegate newMessageViewControllerDidCancel:self];
}

- (IBAction)actSave {
	[self savePressed];
}

- (IBAction)savePressed {
	
	ZNewMessageModel *model = [[ZNewMessageModel new] autorelease];
	model.title		= [_fieldTitle.text trimWhitespace];
	model.message	= [_textView.text trimWhitespace],
	model.privacy	= [NSString stringWithFormat:@"%d", _segmentPrivacy.selectedSegmentIndex];
	model.imagePath = self.imagePath;
	[self.delegate newMessageViewController:self didFinishWithNewMessageModel:model];
}


#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissModalViewControllerAnimated:YES];
	
	[super showProgress];
	
	UIImage *img = info[UIImagePickerControllerOriginalImage];
	
	BOOL isCamera = (picker.sourceType == UIImagePickerControllerSourceTypeCamera);
	if (isCamera) {
		UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	}
	
	UIImage *updatedImage = [img scaleAndRotate];
	
	self.imagePath = [@"image.jpg" docPath];
	
	[UIImageJPEGRepresentation(updatedImage, 0.8) writeToFile:self.imagePath atomically:YES];
	
	_buttonClear.enabled = YES;
	
	if (!isCamera) {
		//	stop progress
		[super hideProgress];
	}
	
	//	restore text
	_fieldTitle.text = self.txtSubject;
	_textView.text = self.txtMessageBody;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	[super hideProgress];
	
	if (error) {
		[APP_DLG showAlertWithMessage:error.localizedDescription title:@"Request error"];
	}

	//	restore text
	_fieldTitle.text = self.txtSubject;
	_textView.text = self.txtMessageBody;
}


@end
