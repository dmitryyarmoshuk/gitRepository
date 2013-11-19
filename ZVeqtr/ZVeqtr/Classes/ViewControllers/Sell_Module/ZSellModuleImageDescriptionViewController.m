//
//  ZSellModuleImageDescriptionViewController.m
//  ZVeqtr
//
//  Created by Maxim on 4/5/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSellModuleImageDescriptionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "EGOImageView.h"
#import "ZUserModel.h"
#import "ZMailDataModel.h"
#import "ZCommentOnMessageModel.h"

#import "ZPersonProfileVC.h"
#import "ZUserModel.h"
#import "ZThisUserProfileVC.h"

#import "HomeViewController.h"

#import "ZImageViewerController.h"
#import "ZPersonalMessageViewController.h"
#import "ZPersonModel.h"


enum {
	kActionLegitComment,
    kActionDeleteImage,
    kActionSaveImage,
};

@interface ZSellModuleImageDescriptionViewController ()

@property (nonatomic, retain) IBOutlet UITableView	*table;

@property (nonatomic, retain) IBOutlet UIView		*toolbarMsgContainer;

@property (nonatomic, retain) IBOutlet UITextField	*txtNewMessage;
@property (nonatomic, retain) IBOutlet UIButton		*btnSend;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView	*spinnerSendMsgProgress;

@property (nonatomic, retain) IBOutlet UIView		*tableHeader;
@property (nonatomic, strong) IBOutlet EGOImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *imageBack;
@property (nonatomic, strong) IBOutlet UIView *textBack;
@property (nonatomic, strong) IBOutlet UITextView *textView;

@property (nonatomic, retain) IBOutlet UIView		*buttonsContainerView;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet UIButton *soldButton;
@property (nonatomic, strong) IBOutlet UIButton *imageButton;
@property (nonatomic, strong) IBOutlet UILabel *labelComments;

@property (nonatomic, retain) IBOutlet UINavigationController		*texturedNavigationController;

@property (nonatomic, retain) NSMutableArray	*allMessages;

@property (nonatomic, retain) ZListPostCell		*controlListPostCell;
@property (nonatomic, retain) ZListPostCell		*selectedCell;

//provides logic for saving image for new comment
@property (nonatomic, retain) ZCommentOnMessageModel *newMsgModel;

@property (nonatomic, retain) ZCommentOnMessageModel *commentToLegit;

@end

@implementation ZSellModuleImageDescriptionViewController

- (ZUserModel *)userModel
{
	return APP_DLG.currentUser;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.allMessages = nil;
    self.controlListPostCell = nil;
    self.selectedCell = nil;
    self.newMsgModel = nil;
    self.commentToLegit = nil;
    
	[super dealloc];
}

- (void)releaseOutlets
{
	[super releaseOutlets];
    
    self.imageBack = nil;
    self.textBack = nil;
    self.imageView = nil;
    self.textView = nil;
    self.imageButton = nil;
    self.saveButton = nil;
    self.soldButton = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePushNotification:) name:kDidReceivePushNotification object:nil];
    
    [self presentBackBarButtonItem];
 
    self.imageBack.layer.masksToBounds = YES;
    self.imageBack.layer.cornerRadius = 4;
    self.imageBack.layer.borderColor = [UIColor grayColor].CGColor;
    self.imageBack.layer.borderWidth = 1;
    
    self.textBack.layer.masksToBounds = YES;
    self.textBack.layer.cornerRadius = 4;
    self.textBack.layer.borderColor = [UIColor grayColor].CGColor;
    self.textBack.layer.borderWidth = 1;
    
    UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font) {
		self.labelComments.font = font;
	}
    
    self.title = @"Images";
    
    self.controlListPostCell = [ZListPostCell cell];
	CGRect cellFrame = self.controlListPostCell.frame;
	cellFrame.size.width = self.table.frame.size.width;
	self.controlListPostCell.frame = cellFrame;
    
    [self updateControls];
    if(!self.imageModel)
    {
        [self runRequestImageModel];
    }
    else
    {
        [self runRequestAllComments];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self subscribeForKeyboardNotifications];
    
    self.toolbarMsgContainer.hidden = self.screenState != ImageDescriptionScreenStateDefault;
    self.table.hidden = self.screenState != ImageDescriptionScreenStateDefault;
    self.labelComments.hidden = self.screenState != ImageDescriptionScreenStateDefault;
    self.imageButton.enabled = self.screenState != ImageDescriptionScreenStateEdit;
    
    
    self.textView.editable = self.screenState == ImageDescriptionScreenStateEdit;
    self.saveButton.hidden = self.screenState != ImageDescriptionScreenStateEdit;
    self.soldButton.hidden = self.screenState != ImageDescriptionScreenStateEdit;
    
    if(self.screenState == ImageDescriptionScreenStateDefault)
    {
        self.table.tableHeaderView = self.tableHeader;
        self.buttonsContainerView.backgroundColor = [UIColor lightGrayColor];
        
        _shouldScrollToBottom = YES;
        [self runRequestAllComments];
    }
    else
    {
        [self.view addSubview:self.tableHeader];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unsubscribeFromKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)updateControls
{
    if([self.imageModel.status boolValue])
        [self.soldButton setTitle:@"Mark as Unsold" forState:UIControlStateNormal];
    else
        [self.soldButton setTitle:@"Mark as Sold" forState:UIControlStateNormal];
    
    if(self.imageModel)
    {
        if(self.imageModel.image)
        {
            self.imageView.image = self.imageModel.image;
        }
        else
        {
            self.imageView.imageURL = [NSURL urlSaleImageFull:self.imageModel.urlString];
        }
        
        self.textView.text = self.imageModel.description;
    }
}

- (void)didReceivePushNotification:(NSNotification*)notification
{
    //NSDictionary *params = [notification object];
    //NSString * placeId = [params valueForKeyPath:@"server.place_id"];
    //if(placeId != nil && [self.mailModel.ID isEqualToString:placeId])
    {
        [self runRequestAllComments];
    }
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

#pragma mark - MFMailComposeViewController Delegate

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

//	image picker's result handler
- (void)savePicture:(UIImage *)picture {
	
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}

#pragma mark - ZListPostCellDelegate

- (void)listPostCellDidClickMessageImage:(ZListPostCell *)listPostCell
{
    /*
     self.selectedCell = listPostCell;
     
     UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Open", nil];
     sheet.tag = kActionSaveImage;
     [sheet showInView:self.view];
     [sheet release];
     */
    
    ZImageViewerController *ctrl = [ZImageViewerController controller];
    ctrl.imageUrl = [NSURL urlFullMailImageWithID:listPostCell.commentModel.ID];
    //ctrl.presenterViewController = self.navigationController;
    
    [self.navigationController pushViewController:ctrl animated:YES];
    
    //self.texturedNavigationController.viewControllers = [NSArray arrayWithObject:ctrl];
    //[self.navigationController presentModalViewController:self.texturedNavigationController animated:YES];
}

- (void)listPostCellDidClickUsername:(ZListPostCell *)listPostCell
{
    NSLog(@"Username");
}

- (void)listPostCellDidClickMail:(ZListPostCell *)listPostCell
{
    ZPersonalMessageViewController *ctrl = [ZPersonalMessageViewController controller];
    ctrl.userModel = self.userModel;
    ctrl.personModel = [ZPersonModel modelWithID:listPostCell.commentModel.userID];
    ctrl.previousController = self;
    [self.navigationController pushViewController:ctrl animated:YES];
    
    [ctrl showPinOnCoordinate:self.imageModel.garageSaleModel.coordinate];
}

- (void)listPostCellDidClickFlag:(ZListPostCell *)listPostCell
{
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
    [APP_DLG.homeViewController showSaleOnMap:self.imageModel.garageSaleModel];
}

- (void)listPostCellDidClickVoteUp:(ZListPostCell *)listPostCell
{
    //[self runRequestCommentLegit:YES];
}

- (void)listPostCellDidClickVoteDown:(ZListPostCell *)listPostCell
{
    [self runRequestCommentLegit:NO];
}
 
- (void)listPostCellDidTouched:(ZListPostCell *)listPostCell
{
    [self closeMenuOnAllExceptCell:listPostCell];
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

- (void)listPostCell:(ZListPostCell *)listPostCell didClickUsernameLink:(NSString*)username
{
    NSLog(@"%@", username);
    [self openUserProfileForUsername:username];
}

- (BOOL)listPostCellShouldShowMenu:(ZListPostCell *)listPostCell
{
    return NO;
}

#pragma mark - Events

-(IBAction)actSold
{
    if([self.imageModel.status boolValue])
        self.imageModel.status = @"0";
    else
        self.imageModel.status = @"1";
    
    [self updateControls];
}

-(IBAction)actSave
{
    self.imageModel.description = self.textView.text;
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneEditing
{
    [self.textView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
}

-(IBAction)actOpenImage
{
    ZImageViewerController *ctrl = [ZImageViewerController controller];
    ctrl.imageUrl = [NSURL urlSaleImageFull:self.imageModel.urlString];
    [self.navigationController pushViewController:ctrl animated:YES];
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
    [self.txtNewMessage resignFirstResponder];
    [super takePicture];
}

- (IBAction)actSend:(id)sender
{
	LLog(@"");
    [self.txtNewMessage resignFirstResponder];
	
	[self sendMessage];
}

- (IBAction)actShowMessageInDetail
{
    /*
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
     */
}

#pragma mark - Requests

- (void)runRequestImageModel
{
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:@"get_image_info" forKey:@"action"];
    [args setObject:self.imageModelId forKey:@"sale_item_id"];
    
    [super showProgress];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    
	dispatch_async(dispatch_queue_create("request.sale.get_image_info", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[super hideProgress];
			if (request.error)
            {
                [APP_DLG showAlertWithMessage:request.error.localizedDescription title:nil];
                
                return;
            }
            
            NSString *responseString = [request responseString];
            NSLog(@"%@", responseString);
            NSDictionary *dic = [responseString JSONValue];
            
            self.imageModel = [ZSellImageModel modelWithDictionary:dic];
            [self runRequestAllComments];
            [self updateControls];
		});
	});
}

- (void)runRequestAllComments
{
	if (!self.imageModel.ID) {
		[self hideProgress];
		LLog(@"NO mailModel.ID");
		return;
	}
	
	NSDictionary *args = @{@"sale_item_id" : self.imageModel.ID};
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"comment" arguments:args];
	
	dispatch_async(dispatch_queue_create("request.comment", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			NSString *responseString = [request responseString];
			NSArray *arrRawData = [responseString JSONValue];
			NSMutableArray *allMessages = [NSMutableArray arrayWithCapacity:[arrRawData count]];
			
			for (NSDictionary *dict in arrRawData) {
				
				ZCommentOnMessageModel *msgModel = [ZCommentOnMessageModel modelWithDictionary:dict];
				if (msgModel) {
					[allMessages addObject:msgModel];
				}
			}
			
			self.allMessages = allMessages;
			[self reloadData];
		});
	});
}

- (void)sendMessage
{
    NSString *message = [self.txtNewMessage.text trimWhitespace];
    
	if (message.length > 0 || self.newMsgModel)
    {
		[self.spinnerSendMsgProgress startAnimating];
		
		ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"comment"];
		[request setPostValue:@"1" forKey:@"add"];
		[request setPostValue:self.imageModel.ID forKey:@"sale_item_id"];
		[request setPostValue:message forKey:@"text"];
        
        if(self.newMsgModel)
            [request setFile:[self.newMsgModel pathPicture] forKey:@"image"];
		
		dispatch_async(dispatch_queue_create("request.comment", NULL), ^{
			
			LLog(@"'%@';", message);
			[request startSynchronous];
			
			dispatch_async(dispatch_get_main_queue(), ^{
                
				[self.spinnerSendMsgProgress stopAnimating];
				
				self.txtNewMessage.text = nil;
                self.newMsgModel = nil;
                self.txtNewMessage.leftView = nil;
				
				[self messageHasSentWithResult:[request responseString] error:[request error]];
			});
			
		});
	}
}

- (void)runRequestCommentLegit:(BOOL)voteUp
{
	NSString *commentID = self.commentToLegit.ID;
	if (!commentID) {
		LLog(@"NO commentToLegit");
		return;
	}
	
	NSString *action = voteUp ? @"like" : @"dislike";
	NSDictionary *args = @{@"type" : @"2", @"item_id" : commentID, @"action" : action};
	
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"rating" arguments:args];
	[self runRequest:request updatePlaceOrComments:NO];
}

- (void)runRequest:(ZCommonRequest *)request updatePlaceOrComments:(BOOL)updPlace
{
	[self showProgress];
    
	dispatch_async(dispatch_queue_create("request.rating", NULL), ^{
		[request startSynchronous];
        
		dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *responseString = [request responseString];
            NSLog(@"%@", responseString);
            
			[self hideProgress];
			{
				[self runRequestAllComments];
			}
		});
	});
}

- (void)runRequestDeleteComment:(ZListPostCell*)cell
{
    [self showProgress];
    
	NSDictionary *args = @{@"id" : cell.commentModel.ID, @"action" : @"del_comment"};
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"comment" arguments:args];
	
	dispatch_async(dispatch_queue_create("request.comment", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
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

#pragma mark -

- (void)messageHasSentWithResult:(NSString *)result error:(NSError *)error {
	LLog(@"COMMENT:'%@', err:'%@'", result, error);
	if (!error) {
        _shouldScrollToBottom = YES;
		[self runRequestAllComments];
	}
}

#pragma mark -

- (void)tickUpdateTimer:(NSTimer *)timer {
#pragma unused (timer)
	[self runRequestAllComments];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
	CGRect bottRect = (CGRect){CGPointZero, self.table.contentSize};
	const CGFloat y = bottRect.size.height - 44;
	if (y > 0) {
		bottRect.size.height = 44;
		bottRect.origin.y = y;
		[self.table scrollRectToVisible:bottRect animated:animated];
	}
}

- (void)reloadData
{    
    [self.table reloadData];
    
    if(_shouldScrollToBottom)
    {
        [self scrollToBottomAnimated:YES];
        _shouldScrollToBottom = NO;
    }
}

#pragma mark - Delegate UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	switch (actionSheet.tag) {
			
		case kActionLegitComment: {
			BOOL isLegit = buttonIndex == 0;
			[self runRequestCommentLegit:isLegit];
			self.commentToLegit = nil;
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


#pragma mark - Delegate UITextView

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
}

#pragma mark - Notifications

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
	//	Example:
	//	NSNumber *duration = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	//	NSValue *valFrame = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
	//	CGRect kbFrame = [valFrame CGRectValue];
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
    
    [UIView animateWithDuration:animationDuration
					 animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y -= keyboardRect.size.height;
                         self.view.frame = frame;
					 }
                     completion:^(BOOL finished)
     {
     }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    
    //CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
	[UIView animateWithDuration:animationDuration
					 animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = 0;
                         self.view.frame = frame;
					 }];
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
        //cell.isDirectMessage = [self.mailModel.privacy intValue] == 5;
	}
	
	ZCommentOnMessageModel *msgModel = [self.allMessages objectAtIndex:indexPath.row];
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
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return YES;
}

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
