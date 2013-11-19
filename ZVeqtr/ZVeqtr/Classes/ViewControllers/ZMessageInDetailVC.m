//
//  ZMessageInDetailVC.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/24/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZMessageInDetailVC.h"

#import "EGOImageView.h"
#import "ZMailDataModel.h"
#import "ZPersonProfileVC.h"
#import "ZThisUserProfileVC.h"


@interface ZMessageInDetailVC ()

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet EGOImageView	*viewTopicPicture;
@property (nonatomic, retain) IBOutlet EGOImageView	*viewUserPicture;
@property (nonatomic, retain) IBOutlet UIButton		*buttonTopicScore;
@property (nonatomic, retain) IBOutlet UILabel		*labTopicMessage;
@property (nonatomic, retain) IBOutlet UILabel		*labTopicText;

@end


@implementation ZMessageInDetailVC

- (void)dealloc
{
	[super dealloc];
}

- (void)releaseOutlets
{
	[super releaseOutlets];

    self.scrollView = nil;
    self.viewTopicPicture = nil;
    self.viewUserPicture = nil;
    self.buttonTopicScore = nil;
    self.labTopicMessage = nil;
    self.labTopicText = nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    [self presentBackBarButtonItem];
    
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font) {
		self.buttonTopicScore.titleLabel.font = font;
		_labTopicMessage.font = font;
		_labTopicText.font = font;
	}
    
    [self.scrollView setCanCancelContentTouches:NO];
    
    self.scrollView.maximumZoomScale = 4.0;
    self.scrollView.minimumZoomScale = 0.25;
    
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self reloadData];
}

- (void)reloadData
{	
	self.title = self.mailModel.title;
	self.labTopicMessage.text = self.mailModel.title;
	self.labTopicText.text = self.mailModel.descript;
	[self.buttonTopicScore setTitle:self.mailModel.rating forState:UIControlStateNormal];
	
	//	topic picture
	self.viewTopicPicture.imageURL = [NSURL urlPlaceImageWithID:self.mailModel.ID];
	
	//	user's profile picture
	self.viewUserPicture.imageURL = [NSURL urlPersonProfileImageWithID:self.mailModel.userID];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(actImageLongPress:)];
    recognizer.minimumPressDuration = 1;
    recognizer.delegate = self;
    [self.viewTopicPicture addGestureRecognizer:recognizer];
}

#pragma mark - UIGesture Recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Events

- (IBAction)actShowMsgAuthor:(id)sender
{
	if (self.userModel)
    {
		ZThisUserProfileVC *ctr = [ZThisUserProfileVC controller];
		ctr.userModel = self.userModel;
		[self.navigationController pushViewController:ctr animated:YES];
	}
	else
    {
		ZPersonProfileVC *ctr = [ZPersonProfileVC controller];
		ctr.personID = self.mailModel.userID;
		[self.navigationController pushViewController:ctr animated:YES];
	}
}

- (IBAction)actRatePlace:(id)sender {
	[self.view endEditing:YES];
	
    if(![self.mailModel.userID isEqualToString:self.userModel.ID])
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Legit Place" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Legit", nil];
        sheet.tag = 0;
        [sheet showInView:self.view];
        [sheet release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You cannot legit yourself" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
    }
}

- (IBAction)actImageLongPress:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Save Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", nil];
        sheet.tag = 1;
        [sheet showInView:self.view];
        [sheet release];
    }
}

- (IBAction)actSaveImage
{
	UIImageWriteToSavedPhotosAlbum(self.viewTopicPicture.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo;
{
    if(!error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Image was successfully saved to Photo Library" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - Delegate - UIScrollView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:0];
}

#pragma mark - Delegate - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
    if(actionSheet.tag == 0)
    {
        [self.delegate controller:self shouldLegitPlace:YES];
    }
    else if(actionSheet.tag == 1)
    {
        [self actSaveImage];
    }
}

@end
