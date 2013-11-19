//
//  ZCpmmentsListVC.m
//  ZVeqtr
//
//  Created by Lee Loo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZCommentsListVC.h"
#import <QuartzCore/QuartzCore.h>
#import "ZListPostCell.h"
#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "ZMailDataModel.h"
#import "ZCommentOnMessageModel.h"
#import "ZPersonProfileVC.h"
#import "ZUserModel.h"
#import "ZThisUserProfileVC.h"
#import "ZEmojiSelViewController.h"
#import "ZImageViewerController.h"
#import "RegisterViewController.h"
#import "ZPersonalMessageViewController.h"
#import "ZPersonModel.h"

#import "HomeViewController.h"

#import "FBSession.h"

enum {
	kActionLegitPlace = 100,
	kActionLegitComment,
    kActionDeleteImage,
    kActionSaveImage,
};


@interface ZCommentsListVC () <ZListPostCellDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITableView	*table;
//	new message bar
@property (nonatomic, retain) IBOutlet UITextField	*txtNewMessage;
@property (nonatomic, retain) IBOutlet UIButton		*btnSend;
@property (nonatomic, retain) IBOutlet UIView		*toolbarMsgContainer;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView	*spinnerSendMsgProgress;
//	topic

@property (nonatomic, retain) IBOutlet UIView		*viewTopicMessage;
@property (nonatomic, retain) IBOutlet UIView		*viewTopicPictureBg;
@property (nonatomic, retain) IBOutlet EGOImageView	*viewTopicPicture;
@property (nonatomic, retain) IBOutlet UILabel		*labTopicMessage;
@property (nonatomic, retain) IBOutlet UILabel		*labTopicText;

@property (nonatomic, retain) IBOutlet UILabel		*labRating;
@property (nonatomic, retain) IBOutlet UIButton		*btnRatingLegit;

@property (retain, nonatomic) IBOutlet UIButton *fcButton;

@property (nonatomic, retain) IBOutlet UINavigationController		*texturedNavigationController;

@property (nonatomic, assign) BOOL                  profileImageLoaded;

//
@property (nonatomic, retain) NSMutableArray	*allMessages;
@property (nonatomic, retain) ZListPostCell		*controlListPostCell;
@property (nonatomic, retain) ZListPostCell		*selectedCell;

//provides logic for saving image for new comment
@property (nonatomic, retain) ZCommentOnMessageModel *newMsgModel;

@property (nonatomic, retain)   FBSession *fbSession;

@end


@implementation ZCommentsListVC
{
	NSTimer *_updateTimer;
}

-(IBAction)testAction
{
    RegisterViewController *controller = [RegisterViewController controller];
    [APP_DLG.homeViewController presentModalViewController:controller animated:YES];
    
    return;
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	self.allMessages = nil;
    self.newMsgModel = nil;
    [_fcButton release];
	[super dealloc];
}

- (void)releaseOutlets
{
	[super releaseOutlets];
	self.table = nil;
	self.txtNewMessage = nil;
	self.btnSend = nil;
	self.toolbarMsgContainer = nil;
	self.spinnerSendMsgProgress = nil;
	self.viewTopicMessage = nil;
	self.viewTopicPictureBg = nil;
    self.viewTopicPicture.delegate = nil;
	self.viewTopicPicture = nil;
	self.labTopicMessage = nil;
	self.labRating = nil;
	self.labTopicText = nil;
	self.btnRatingLegit = nil;
	self.controlListPostCell = nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[super presentBackBarButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePushNotification:) name:kDidReceivePushNotification object:nil];
	
    if([self.mailModel.privacy intValue] == 5)
    {
        self.btnRatingLegit.hidden = YES;
        self.labRating.hidden = YES;
    }
    
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font) {
		_labRating.font = font;
		_labTopicMessage.font = font;
		_labTopicText.font = font;
	}
	
	self.title = @"Comments";
	//[self.btnEmoji setTitle:@"\ue415" forState:UIControlStateNormal];
	
	_viewTopicPictureBg.layer.masksToBounds = YES;
	_viewTopicPictureBg.layer.cornerRadius = 6;
	_viewTopicPictureBg.layer.borderColor = [UIColor grayColor].CGColor;
	_viewTopicPictureBg.layer.borderWidth = 1;
    
    _viewTopicPictureBg.hidden = YES;
    self.viewTopicPicture.delegate = self;
    
	
	self.controlListPostCell = [ZListPostCell cell];
	CGRect cellFrame = self.controlListPostCell.frame;
	cellFrame.size.width = self.table.frame.size.width;
	self.controlListPostCell.frame = cellFrame;
}

- (void)viewDidUnload {
    [self setFcButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

    _shouldScrollToBottom = YES;
    
	[super subscribeForKeyboardNotifications];
	
	[self runRequestAllComments];
    
    [self runRequestPlaceWithID:self.mailModel.ID];
    
	[_spinnerSendMsgProgress stopAnimating];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	_updateTimer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(tickUpdateTimer:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[super unsubscribeFromKeyboardNotifications];
	
	[_updateTimer invalidate];
	_updateTimer = nil;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Events

- (IBAction)fcButtonPressed:(id)sender {
    if (!_fbSession)
        self.fbSession = [[[FBSession alloc] initWithDelegate:self] autorelease];
    [_fbSession facebookLogin];
}

- (void)tickUpdateTimer:(NSTimer *)timer
{
#pragma unused (timer)
	//[self runRequestAllComments];
}

- (void)didReceivePushNotification:(NSNotification*)notification
{
    NSDictionary *params = [notification object];
    NSString * placeId = [params valueForKeyPath:@"server.place_id"];
    if(placeId != nil && [self.mailModel.ID isEqualToString:placeId])
    {
        [self runRequestAllComments];
    }
}

- (IBAction)actDeletePicture:(id)sender
{
    //[super takePicture];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete image" otherButtonTitles:nil];
    sheet.tag = kActionDeleteImage;
    [sheet showInView:self.view];
    [sheet release];
}

- (IBAction)actTakePicture:(id)sender
{
    [super takePicture];
}

- (IBAction)actOpenUserProfile:(id)sender
{
	LLog(@"");
    
    if(!self.profileImageLoaded)
    {
        ZImageViewerController *ctrl = [ZImageViewerController controller];
        ctrl.imageUrl = [NSURL urlPlaceImageWithID:self.mailModel.ID];
        ctrl.presenterViewController = self.navigationController;
        
        self.texturedNavigationController.viewControllers = [NSArray arrayWithObject:ctrl];
        [self.navigationController presentModalViewController:self.texturedNavigationController animated:YES];
        
        return;
    }
    
    if ([self.mailModel.userID isEqualToString:self.userModel.ID]) {
		ZThisUserProfileVC *ctr = [ZThisUserProfileVC controller];
		ctr.userModel = self.userModel;
		
        
        ctr.presenterViewController = self.navigationController;
        
        self.texturedNavigationController.viewControllers = [NSArray arrayWithObject:ctr];
        [self.navigationController presentModalViewController:self.texturedNavigationController animated:YES];
        
        //[self.navigationController pushViewController:ctr animated:YES];
        
        
		return;
	}
    
	ZPersonProfileVC *ctr = [[ZPersonProfileVC new] autorelease];
    ctr.mailDataModel = self.mailModel;
	//[self.navigationController pushViewController:ctr animated:YES];
    
    ctr.presenterViewController = self.navigationController;
    
    self.texturedNavigationController.viewControllers = [NSArray arrayWithObject:ctr];
    [self.navigationController presentModalViewController:self.texturedNavigationController animated:YES];
}

- (IBAction)actSend:(id)sender
{
	LLog(@"");
	
	[self sendMessage];
}

- (IBAction)actShowMessageInDetail
{
	
	ZMessageInDetailVC *ctr = [ZMessageInDetailVC controller];
	ctr.mailModel = self.mailModel;
    ctr.delegate = self;
	//[self.navigationController pushViewController:ctr animated:YES];
	
    if ([self.mailModel.userID isEqualToString:self.userModel.ID]) {
		ctr.userModel = self.userModel;
	}
    
    ctr.presenterViewController = self.navigationController;
    
    self.texturedNavigationController.viewControllers = [NSArray arrayWithObject:ctr];
    [self.navigationController presentModalViewController:self.texturedNavigationController animated:YES];
}

- (IBAction)actRatePlace:(id)sender
{
	[self.view endEditing:YES];
	
    if(![self.mailModel.userID isEqualToString:self.userModel.ID])
        //  if(YES)
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Legit Place" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Legit", nil];
        sheet.tag = kActionLegitPlace;
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	switch (actionSheet.tag) {
		case kActionLegitPlace: {
			BOOL isLegit = buttonIndex == 0;
			[self runRequestPlaceLegit:isLegit];
			break;
		}
			
        case kActionDeleteImage:
        {
            self.newMsgModel = nil;
            self.txtNewMessage.leftView = nil;
        }
            break;
        case kActionSaveImage:
        {
            if(buttonIndex == 0)
            {
                //save image
                UIImageWriteToSavedPhotosAlbum(self.selectedCell.commentPicture.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
            
            self.selectedCell = nil;
            
        }
            break;
        default:
            [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
			break;
	}//sw
}

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
	//	Example:
	NSNumber *duration = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSValue *valFrame = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect kbFrame = [valFrame CGRectValue];
	
	CGRect frame = self.view.bounds;
	frame.size.height -= UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ?  kbFrame.size.height : kbFrame.size.width;
	
	
	[UIView animateWithDuration:[duration floatValue]
					 animations:^{
						 self.viewContainer.frame = frame;
                         //self.view.frame = frame;
					 }
					 completion:^(BOOL finished) {
						 [self scrollToBottomAnimated:YES];
					 }];
	
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
	NSNumber *duration = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	[UIView animateWithDuration:[duration floatValue]
					 animations:^{
						 self.viewContainer.frame = self.view.bounds;
                         //self.view.frame = self.view.bounds;
					 }];}

#pragma mark - Actions

- (void)reloadData
{
	self.title = self.mailModel.title;
	
	self.labTopicMessage.text = self.mailModel.title;
	self.labTopicText.text = self.mailModel.descript;
	
	//	rating
	NSString *rating = self.mailModel.rating;
	const int nrate = [rating intValue];
	self.btnRatingLegit.selected = (nrate > 0);
	self.labRating.text = (nrate == 0) ? nil : rating;
    
    self.profileImageLoaded = NO;
    
	self.viewTopicPicture.imageURL = [NSURL urlPlaceImageWithID:self.mailModel.ID];
    
    self.fcButton.hidden = self.labRating.hidden = self.btnRatingLegit.hidden = [self.mailModel.privacy intValue] == 5;
    
    [self.table reloadData];
    
    if(_shouldScrollToBottom)
    {
        [self scrollToBottomAnimated:YES];
        _shouldScrollToBottom = NO;
    }
}

- (void)messageHasSentWithResult:(NSString *)result error:(NSError *)error
{
	LLog(@"COMMENT:'%@', err:'%@'", result, error);
	if (!error) {
        _shouldScrollToBottom = YES;
		[self runRequestAllComments];
	}
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
	CGRect bottRect = (CGRect){CGPointZero, self.table.contentSize};
	const CGFloat y = bottRect.size.height - 44;
	if (y > 0) {
		bottRect.size.height = 44;
		bottRect.origin.y = y;
		[self.table scrollRectToVisible:bottRect animated:animated];
	}
}

- (void)showProgress
{
    [super showProgress];
    
    if(self.navigationController.presentedViewController != nil)
    {
        UINavigationController *presentedController = (UINavigationController*)self.navigationController.presentedViewController;
        
        if([presentedController isKindOfClass:[UINavigationController class]]
           && [presentedController.visibleViewController isKindOfClass:[ZMessageInDetailVC class]])
        {
            ZMessageInDetailVC *ctrl = (ZMessageInDetailVC*)presentedController.visibleViewController;
            [ctrl showProgress];
        }
    }
}

- (void)hideProgress
{
    [super hideProgress];
    
    if(self.navigationController.presentedViewController != nil)
    {
        UINavigationController *presentedController = (UINavigationController*)self.navigationController.presentedViewController;
        if([presentedController isKindOfClass:[UINavigationController class]]
           && [presentedController.visibleViewController isKindOfClass:[ZMessageInDetailVC class]])
        {
            ZMessageInDetailVC *ctrl = (ZMessageInDetailVC*)presentedController.visibleViewController;
            [ctrl hideProgress];
            [ctrl reloadData];
        }
    }
}

#pragma mark - Requests

- (void)runRequestDeleteComment:(ZListPostCell*)cell
{
	if (!self.mailModel.ID) {
		[self hideProgress];
		LLog(@"NO mailModel.ID");
		return;
	}
	
    [self showProgress];
    
	NSDictionary *args = @{@"id" : cell.commentModel.ID, @"action" : @"del_comment"};
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"comment" arguments:args];
	
	dispatch_async(dispatch_queue_create("request.comment", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			LLog(@"%@ / err:%@ (for model:'%@')", [request responseString], request.error, self.mailModel);
			[self hideProgress];
			NSString *responseString = [request responseString];
			if([responseString isEqualToString:@"1"])
            {
                NSIndexPath *indexPath = [self.table indexPathForCell:cell];
                
                [self.table beginUpdates];
                
                [self.allMessages removeObject:cell.commentModel];
                [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                [self.table endUpdates];
            }
		});
	});
}

- (void)runRequestPlaceLegit:(BOOL)isLegit
{
    
	NSString *placeID = self.mailModel.ID;
	NSString *action = isLegit ? @"like" : @"dislike";
	NSDictionary *args = @{@"type" : @"1", @"item_id" : placeID, @"action" : action};
	
	LLog(@"legit %d; args:{{%@}}", isLegit, args);
	
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"rating" arguments:args];
	[self runRequest:request updatePlaceOrComments:YES];
}

- (void)runRequestCommentLegit:(BOOL)voteUp commentId:(NSString*)commentId
{
	if (!commentId) {
		LLog(@"NO commentToLegit");
		return;
	}
	
	NSString *action = voteUp ? @"like" : @"dislike";
	NSDictionary *args = @{@"type" : @"2", @"item_id" : commentId, @"action" : action};
	
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"rating" arguments:args];
	[self runRequest:request updatePlaceOrComments:NO];
}

- (void)runRequest:(ZCommonRequest *)request updatePlaceOrComments:(BOOL)updPlace
{
	[self showProgress];
    
	dispatch_async(dispatch_queue_create("request.rating", NULL), ^{
		[request startSynchronous];

		dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideProgress];
            
            NSString *responseString = [request responseString];
                        NSLog(@"%@", responseString);
            NSDictionary *returnDic = [responseString JSONValue];

            if([[returnDic objectForKey:@"status"] isEqualToString:@"ok"])
            {
                if (updPlace)
                {
                    [self runRequestPlaceWithID:self.mailModel.ID];
                }
                else {
                    [self runRequestAllComments];
                }
            }
            else if([returnDic objectForKey:@"status"])
            {
                [APP_DLG showAlertWithMessage:[returnDic objectForKey:@"status"] title:@""];
            }
            else
            {
                //[APP_DLG showAlertWithMessage:@"Can't vote on this post" title:@""];
            }
		});
	});
}

- (void)runRequestPlaceWithID:(NSString *)placeID
{
	if (placeID.length == 0)
    {
		[self hideProgress];
		LLog(@"NO placeID");
		return;
	}
	
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"place" arguments:@{@"get_ids" : placeID}];
    
	[self showProgress];
	
    dispatch_async(dispatch_queue_create("request.place.get_ids", NULL), ^{
		[request startSynchronous];
		NSString *responseString = [request responseString];
		NSError *error = request.error;
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error)
            {
				LLog(@"error:{{%@}}", error);
				return;
			}
			
			NSArray *resultArr = [responseString JSONValue];
			
			NSDictionary *resultDict = nil;
			for (NSDictionary *dict in resultArr) {
				if ([dict[@"id"] isEqualToString:placeID]) {
					resultDict = dict;
					break;
				}
			}
			
			if (resultDict) {
				ZMailDataModel *model = [ZMailDataModel mailDataModelWithDictionary:resultDict];
				if (model) {
					LLog(@"Place found: %@", model);
					[self.mailModel updateWithMailDataModel:model];
					[self reloadData];
				}
			}
			else {
				LLog(@"Response does not contain this place id(%@)", placeID);
			}
            
            [self hideProgress];
		});
	});
}

- (void)runRequestAllComments
{
	if (!self.mailModel.ID) {
		[self hideProgress];
		LLog(@"NO mailModel.ID");
		return;
	}
	
	NSDictionary *args = @{@"place_id" : self.mailModel.ID};
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"comment" arguments:args];
	
	dispatch_async(dispatch_queue_create("request.comment", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			LLog(@"%@ / err:%@ (for model:'%@')", [request responseString], request.error, self.mailModel);
			
			NSString *responseString = [request responseString];
			NSArray *arrRawData = [responseString JSONValue];
			NSMutableArray *allMessages = [NSMutableArray arrayWithCapacity:[arrRawData count]];
			
			for (NSDictionary *dict in arrRawData)
            {
				ZCommentOnMessageModel *msgModel = [ZCommentOnMessageModel modelWithDictionary:dict];
				
                if (msgModel)
                {
					[allMessages addObject:msgModel];
				}
			}
            
			self.mailModel.countComments = [NSString stringWithFormat:@"%d", allMessages.count];
			
			self.allMessages = allMessages;
			[self reloadData];
		});
	});
}

- (void)sendMessage
{
	//iphone/comment.php?sess_id={session id}&add=1&place_id={id place}&text={текст сообщения}
	NSString *message = [self.txtNewMessage.text trimWhitespace];
	if (message.length > 0 || self.newMsgModel) {
		
		[_spinnerSendMsgProgress startAnimating];
		
		ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"comment"];
		[request setPostValue:@"1" forKey:@"add"];
		[request setPostValue:self.mailModel.ID forKey:@"place_id"];
		[request setPostValue:message forKey:@"text"];
        
        if(self.newMsgModel)
            [request setFile:[self.newMsgModel pathPicture] forKey:@"image"];
		
		dispatch_async(dispatch_queue_create("request.comment", NULL), ^{
			
			LLog(@"'%@';", message);
			[request startSynchronous];
			
			dispatch_async(dispatch_get_main_queue(), ^{
                
				[_spinnerSendMsgProgress stopAnimating];
				
				self.txtNewMessage.text = nil;
                self.newMsgModel = nil;
                self.txtNewMessage.leftView = nil;
				
				[self messageHasSentWithResult:[request responseString] error:[request error]];
			});
			
		});
	}
	
	[APP_DLG invalidateMap];
}

#pragma mark - MFMailComposeViewController Delegate

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

//	image picker's result handler
- (void)savePicture:(UIImage *)picture
{
    if(!self.newMsgModel)
        self.newMsgModel = [[ZCommentOnMessageModel alloc] init];
    
	self.newMsgModel.image = [picture scaleAndRotate];
    
    UIButton *buttonView = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonView setBackgroundImage:self.newMsgModel.image forState:UIControlStateNormal];
    [buttonView addTarget:self action:@selector(actDeletePicture:) forControlEvents:UIControlEventTouchUpInside];
    buttonView.frame = CGRectMake(0, 0, 20, 20);
    self.txtNewMessage.leftView = buttonView;
    [self.txtNewMessage setLeftViewMode:UITextFieldViewModeAlways];
}

-(void)openUserProfileForUsername:(NSString*)username
{
	if ([username isEqualToString:self.userModel.username]) {
		ZThisUserProfileVC *ctr = [ZThisUserProfileVC controller];
		ctr.userModel = self.userModel;
		
        ctr.presenterViewController = self.texturedNavigationController;
        
        self.texturedNavigationController.viewControllers = [NSArray arrayWithObject:ctr];
        [self presentModalViewController:self.texturedNavigationController animated:YES];
        
		return;
	}
    
	ZPersonProfileVC *ctr = [[ZPersonProfileVC new] autorelease];
    ctr.username = username;
    ctr.presenterViewController = self.texturedNavigationController;
    
    self.texturedNavigationController.viewControllers = [NSArray arrayWithObject:ctr];
    [self.navigationController presentModalViewController:self.texturedNavigationController animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0];
	
	return YES;
}

#pragma mark - ZListPostCellDelegate

- (void)listPostCellDidClickMessageImage:(ZListPostCell *)listPostCell
{
    ZImageViewerController *ctrl = [ZImageViewerController controller];
    ctrl.imageUrl = [NSURL urlFullMailImageWithID:listPostCell.commentModel.ID];
    ctrl.presenterViewController = self.navigationController;
    
    self.texturedNavigationController.viewControllers = [NSArray arrayWithObject:ctrl];
    [self.navigationController presentModalViewController:self.texturedNavigationController animated:YES];
}

- (void)listPostCellDidClickUsername:(ZListPostCell *)listPostCell
{
    NSLog(@"Username");
    NSString *message = self.txtNewMessage.text;
    if(!message)
        message = @"";
    
    message = [message stringByAppendingFormat:@"@%@", listPostCell.commentModel.username];
    self.txtNewMessage.text = message;
}

- (void)listPostCellDidClickMail:(ZListPostCell *)listPostCell
{
    ZPersonalMessageViewController *ctrl = [ZPersonalMessageViewController controller];
    ctrl.userModel = self.userModel;
    ctrl.personModel = [ZPersonModel modelWithID:listPostCell.commentModel.userID];
    ctrl.previousController = self;
    [self.navigationController pushViewController:ctrl animated:YES];
    
    [ctrl showPinOnCoordinate:self.mailModel.coordinate];
}

- (void)listPostCell:(ZListPostCell *)listPostCell didClickUsernameLink:(NSString*)username
{
    NSLog(@"%@", username);
    [self openUserProfileForUsername:username];
}

- (void)listPostCellDidClickFlag:(ZListPostCell *)listPostCell
{
    NSLog(@"Flag");
    if ([MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Veqtr mail"];
        [mailViewController setMessageBody:@"<Predefined message>" isHTML:NO];
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"info@bartsoft.com"]];
        [self presentModalViewController:mailViewController animated:YES];
        [mailViewController release];
    }
    else
    {
        NSLog(@"Device is unable to send email in its current state.");
    }
}

- (void)listPostCellDidClickToMap:(ZListPostCell *)listPostCell
{
    [APP_DLG.homeViewController showConversationOnMap:self.mailModel];
}

- (void)listPostCellDidClickVoteUp:(ZListPostCell *)listPostCell
{
    [self runRequestCommentLegit:YES commentId:listPostCell.commentModel.ID];
}

- (void)listPostCellDidClickVoteDown:(ZListPostCell *)listPostCell
{
    [self runRequestCommentLegit:NO commentId:listPostCell.commentModel.ID];
}

- (void)listPostCellDidTouched:(ZListPostCell *)listPostCell
{
    [self closeMenuOnAllExceptCell:listPostCell];
}

- (BOOL)listPostCellShouldShowMenu:(ZListPostCell *)listPostCell
{
    return YES;
}

-(void)closeMenuOnAllExceptCell:(ZListPostCell *)listPostCell
{
    for (int section = 0; section < [self.table numberOfSections]; section++) {
        for (int row = 0; row < [self.table numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            ZListPostCell* cell = (ZListPostCell*)[self.table cellForRowAtIndexPath:cellPath];
            //do stuff with 'cell'
            
            if(![cell.commentModel.ID isEqualToString:listPostCell.commentModel.ID])
            {
                NSLog(@"%@: hide", cell.commentModel.ID);
                [cell showMenu:NO animated:YES];
            }
            else
            {
                NSLog(@"%@: skip", cell.commentModel.ID);
            }
        }
    }
}

#pragma mark - TableView

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

#pragma mark - Delegate - ZMessageInDetailVC

-(void)controller:(ZMessageInDetailVC*)controller shouldLegitPlace:(BOOL)shouldLegitPlace
{
    [self runRequestPlaceLegit:shouldLegitPlace];
}

#pragma mark - EGOImageView Delegate

- (void)imageViewLoadedImage:(EGOImageView*)imageView
{
    self.viewTopicPictureBg.hidden = NO;
}

- (void)imageViewFailedToLoadImage:(EGOImageView*)imageView error:(NSError*)error
{
    LLog(@"Failed to load image");
    if(!self.profileImageLoaded)
    {
        self.viewTopicPicture.imageURL = [NSURL urlPersonProfileImageWithID:self.mailModel.userID];
        self.profileImageLoaded = YES;
    }
    else
        self.viewTopicPictureBg.hidden = YES;
}

#pragma mark - delegate for FaceBookSeccion

- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date
{
    NSString *msg = [NSString stringWithFormat:@"%@ / %@",self.title,self.labTopicText.text];
    NSURL *url = self.viewTopicPicture.imageURL;
    NSString *surl = [url absoluteString];
    //NSLog(@"fb_im_url=%@",surl);
    
    [_fbSession publishImageFBStream:msg imageUrl:surl];
}

- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date withInfo:(NSDictionary*)result
{
    //NSLog(@"-delegate:token:%@",token);
    //NSLog(@"-delegate:date:%@",date);
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.allMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ZListPostCell *cell = nil;
	
	static NSString *cellID = @"ZListPostCell";
	cell = (ZListPostCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
	if (! cell) {
		cell = [ZListPostCell cell];
		cell.delegate = self;
        cell.isDirectMessage = [self.mailModel.privacy intValue] == 5;
	}
	
	ZCommentOnMessageModel *msgModel = [self.allMessages objectAtIndex:indexPath.row];
    NSLog(@"rat=%@ id=%@ us_id=%@",msgModel.rating,msgModel.ID,msgModel.userID);
	[cell setCommentModel:msgModel];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ZCommentOnMessageModel *msgModel = [self.allMessages objectAtIndex:indexPath.row];
	return [self.controlListPostCell heightWithCommentModel:msgModel andInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZListPostCell *cell = (ZListPostCell*)[tableView cellForRowAtIndexPath:indexPath];
    [self closeMenuOnAllExceptCell:cell];
    
    if(cell.isMenuOpened)
    {
        [cell showMenu:NO animated:YES];
    }
    else
    {
        [cell showMenu:YES animated:YES];
    }
    
    return;
    
    ZCommentOnMessageModel *msgModel = [self.allMessages objectAtIndex:indexPath.row];
	if ([msgModel.userID isEqualToString:self.userModel.ID]) {
		ZThisUserProfileVC *ctr = [ZThisUserProfileVC controller];
		ctr.userModel = self.userModel;
		
        ctr.presenterViewController = self.texturedNavigationController;
        
        self.texturedNavigationController.viewControllers = [NSArray arrayWithObject:ctr];
        [self presentModalViewController:self.texturedNavigationController animated:YES];
        
        //[self.navigationController pushViewController:ctr animated:YES];
        
        
		return;
	}
    
	ZPersonProfileVC *ctr = [[ZPersonProfileVC new] autorelease];
    ctr.commentModel = msgModel;

    ctr.presenterViewController = self.texturedNavigationController;
    
    self.texturedNavigationController.viewControllers = [NSArray arrayWithObject:ctr];
    [self.navigationController presentModalViewController:self.texturedNavigationController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return YES;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZListPostCell *cell = (ZListPostCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell showMenu:NO animated:YES];
    //[self closeMenuOnAllExceptCell:nil];
    
    return @"Delete";
}
*/


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZListPostCell *cell = (ZListPostCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    BOOL shouldShowDeleteButton = !cell.isMenuOpened;
    [self closeMenuOnAllExceptCell:nil];
    
    if([cell.commentModel.userID isEqualToString:[self userModel].ID] && shouldShowDeleteButton)
        return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        ZListPostCell *cell = (ZListPostCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        [self runRequestDeleteComment:cell];
    }
}

@end
