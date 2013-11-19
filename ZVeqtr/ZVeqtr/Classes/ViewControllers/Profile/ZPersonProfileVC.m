//
//  ZPersonProfileVC.m
//  ZVeqtr
//
//  Created by Lee Loo on 10/22/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZPersonProfileVC.h"
#import <QuartzCore/QuartzCore.h>
#import "SBJson.h"
#import "EGOImageView.h"
#import "ZPersonModel.h"
#import "ZUserModel.h"
#import "ZCommentOnMessageModel.h"
#import "ZPersonPostCell.h"
#import "ZMailDataModel.h"
#import "ZCommonRequest.h"
#import "ZListPostCell.h"
#import "ZCommentsListVC.h"
#import "OHAttributedLabel.h"
#import "ZMailListViewController.h"
#import "ZUserListViewController.h"
#import "TextTableViewCell.h"
#import "ZPersonalMessageViewController.h"


enum {
    UsrProfileSectionTemplText,
	ProfSectPosts,
	ProfSectHashtags,
	ProfSectCOUNT
};


@interface ZPersonProfileVC ()
<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) IBOutlet EGOImageView	*picture;
@property (nonatomic, retain) IBOutlet UIView		*pictureBack;
@property (nonatomic, retain) IBOutlet UILabel		*labIsFriend;
@property (nonatomic, retain) IBOutlet UILabel		*labPosts;
@property (nonatomic, retain) IBOutlet UILabel		*labFollowing;
@property (nonatomic, retain) IBOutlet UILabel		*labFollowers;
@property (nonatomic, retain) IBOutlet UILabel		*labFriends;
@property (nonatomic, retain) IBOutlet UILabel		*labScore;
@property (nonatomic, retain) IBOutlet UIImageView	*iconRatingStar;
@property (nonatomic, retain) IBOutlet OHAttributedLabel		*labEmail;
@property (nonatomic, retain) IBOutlet UIButton		*btnFollow;
@property (nonatomic, retain) IBOutlet UIButton		*btnMoreActions;
@property (nonatomic, retain) IBOutlet UIView		*headerPosts;
@property (nonatomic, retain) IBOutlet UIView		*headerHashtags;
@property (nonatomic, retain) IBOutlet UIView		*headerComment;
@property (nonatomic, retain) IBOutlet UIView		*headerCustomText;
@property (nonatomic, retain) IBOutlet UITableView	*table;

@property (nonatomic, retain) IBOutlet NSMutableArray	*customStrings;
//
@property (nonatomic, retain) NSArray	*allPosts, *allHashtags;
//
@property (nonatomic, retain) ZPersonPostCell	*controlPersonPostCell;
@property (nonatomic, retain) TextTableViewCell		*customTextCell;

@property (nonatomic, retain) NSTimer	*updateTimer;

@end


@implementation ZPersonProfileVC

- (void)releaseOutlets {
	[super releaseOutlets];
	self.picture = nil;
	self.pictureBack = nil;
	self.labIsFriend = NO;
	self.labPosts = nil;
	self.labFollowing = nil;
	self.labFollowers = nil;
	self.labFriends = nil;
	self.labScore = nil;
	self.iconRatingStar = nil;
	self.labEmail = nil;
	self.btnFollow = nil;
	self.btnMoreActions = nil;
	self.headerPosts = nil;
	self.headerHashtags = nil;
	self.headerComment = nil;
	self.table = nil;
}

- (void)dealloc {
	self.personModel = nil;
	self.commentModel = nil;
	self.userModel = nil;
	self.allPosts = nil;
	self.allHashtags = nil;
    self.customStrings = nil;
    self.controlPersonPostCell = nil;
    self.customTextCell = nil;
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.customStrings = [NSMutableArray array];
        
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font) {
		_labPosts.font = font;
		_labFollowing.font = font;
		_labFollowers.font = font;
		_labFriends.font = font;
		_labScore.font = font;
		_btnFollow.titleLabel.font = font;
		_labIsFriend.font = font;
	}
    
    self.labEmail.backgroundColor = [UIColor clearColor];
    self.labEmail.centerVertically = YES;
    self.labEmail.delegate = self;
    self.labEmail.userInteractionEnabled = YES;
    self.labEmail.automaticallyAddLinksForType = NSTextCheckingTypeLink|NSTextCheckingTypeAddress;
	
	CGSize lszFriend = _labIsFriend.frame.size;
	_labIsFriend.center = CGPointMake(lszFriend.height/2, lszFriend.width/2);
	_labIsFriend.transform = CGAffineTransformMakeRotation(-M_PI_2);
	
	self.pictureBack.layer.masksToBounds = YES;
	self.pictureBack.layer.cornerRadius = 6;
	self.pictureBack.layer.borderColor = [UIColor grayColor].CGColor;
	self.pictureBack.layer.borderWidth = 1;
	
	self.navigationItem.rightBarButtonItem = self.userModel ? nil : [super settingsBarButtonItem];
	self.navigationItem.leftBarButtonItem = [super backBarButtonItem];
	
	self.controlPersonPostCell = [ZPersonPostCell cell];
	CGRect cellFrame = self.controlPersonPostCell.frame;
	cellFrame.size.width = self.table.frame.size.width;
	self.controlPersonPostCell.frame = cellFrame;
    
    self.customTextCell = [TextTableViewCell cell];
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(tickUpdateTimer:) userInfo:nil repeats:YES];
}

-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel shouldFollowLink:(NSTextCheckingResult*)linkInfo
{
    /*
     currentUrl = [linkInfo.URL retain];
     
     UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
     message:@"This link will open in Safari"
     delegate:self
     cancelButtonTitle:nil
     otherButtonTitles:@"Cancel", @"Yes", nil] autorelease];
     [alert show];
     */
    if(attributedLabel == self.labEmail)
    {
        [[UIApplication sharedApplication] openURL:linkInfo.URL];
        //[self.delegate notificationCellUsernameClicked:self];
    }
    
	return NO;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];

    [self requestPersonDetails:YES];
	[self reloadData];
}

-(void)requestPersonDetails:(BOOL)showLoadingView
{
    if (!self.personModel) {
		if (self.commentModel.userID) {
			[self runRequestPersonProfileWithID:self.commentModel.userID showLoadingView:showLoadingView];
		}
        else if (self.mailDataModel.userID) {
			[self runRequestPersonProfileWithID:self.mailDataModel.userID showLoadingView:showLoadingView];
		}
		else if (self.personID) {
			[self runRequestPersonProfileWithID:self.personID showLoadingView:showLoadingView];
		}
        else if(self.userModel)
        {
            [self runRequestPersonProfileWithID:self.userModel.ID showLoadingView:showLoadingView];
        }
        else if(self.username)
        {
            [self runRequestPersonProfileWithUsername:self.username showLoadingView:showLoadingView];
        }
		else {
			LLog(@"NO person ID to take from");
		}
	}
	else {
		[self runRequestPersonProfileWithID:self.personModel.ID showLoadingView:showLoadingView];
	}
}

- (void)reloadData {
	[self.table reloadData];

	//	bio picture
	NSString *userID = self.commentModel.userID;
	if (!userID) {
		userID = self.personModel.ID;
	}
	self.picture.imageURL = [NSURL urlPersonProfileImageWithID:userID];
	
	if (self.personModel) {
		_labPosts.text = self.personModel.postCount;
		_labFollowing.text = self.personModel.follow;
		_labFollowers.text = self.personModel.followers;
		_labFriends.text = self.personModel.friends;

		//	score = rate
		int rate = [self.personModel.rating intValue];
		_labScore.text = (rate == 0) ? nil : self.personModel.rating;
		_iconRatingStar.image = (rate > 0) ? [UIImage imageNamed:@"ico-profile-Star1.png"] : [UIImage imageNamed:@"ico-profile-Star2.png"];

		NSString *email = self.personModel.email;
		if (!email) {
			email = self.personModel.nickname;;
		}
		_labEmail.text = email;
		
		NSString *name = self.personModel.name;
		if (!name.length) {
			name = self.personModel.nickname;
		}
		if (!name.length) {
			name = self.personModel.email;
		}
		if (!name.length) {
			LLog(@"NONAME {{%@}}", self.personModel);
			;
		}
		self.title = name;
        if(self.userModel)
        {
            _labIsFriend.text = @"Your profile";
        }
        else
        {
            _labIsFriend.text = self.personModel.isFriend ? @"friend":@"no friend";
        }
	}
	else {
		_labPosts.text = nil;
		_labFollowing.text = nil;
		_labFollowers.text = nil;
		_labFriends.text = nil;
		_labScore.text = nil;
		_labEmail.text = nil;
		_labIsFriend.text = nil;
		LLog(@"no personModel");
	}
	
	[self validateButtons];
}

- (void)validateButtons {
	
	BOOL sameUser = [self.commentModel.userID isEqualToString:self.userModel.ID] || [self.personModel.ID isEqualToString:self.userModel.ID];
	if (sameUser) {
        _btnFollow.hidden = YES;
		
		_btnMoreActions.enabled = NO;
		_btnMoreActions.selected = NO;
	}
	else {
        _btnFollow.hidden = NO;
		_btnFollow.enabled = YES;
		BOOL follow = self.personModel && self.personModel.isFollow;
		//	unfollow?
		_btnFollow.selected = follow;

		_btnMoreActions.enabled = YES;
	}
}

- (IBAction)actGoHome {
    if(self.presenterViewController)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Events

- (void)tickUpdateTimer:(NSTimer *)timer
{
    [self requestPersonDetails:NO];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return ProfSectCOUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
        case UsrProfileSectionTemplText:
            return self.customStrings.count >= 1 ? 1 : 0;
            
		case ProfSectPosts:
			return self.allPosts.count;
			
		case ProfSectHashtags:
			return self.allHashtags.count;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger row = indexPath.row;
	UITableViewCell *cell = nil;
	
	switch (indexPath.section) {

		case ProfSectPosts: {
			static NSString *cellID = @"ZPersonPostCell";
			ZPersonPostCell *postCell = (ZPersonPostCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
			if (! postCell) {
				postCell = [ZPersonPostCell cell];
			}
			ZMailDataModel *msgModel = [self.allPosts objectAtIndex:row];
			postCell.labTitle.text = msgModel.title;
			postCell.labText.text = msgModel.descript;
			if (msgModel.hasImage)
            {
                postCell.picBack.hidden = NO;
				postCell.picture.imageURL = [NSURL urlPlaceImageWithID:msgModel.ID];
			}
			else
            {
                postCell.picBack.hidden = YES;
				postCell.picture.image = nil;
			}
			
			cell = postCell;
			break;
		}
            
        case UsrProfileSectionTemplText: {
			
            NSString *cellID = [NSString stringWithFormat:@"TextTableViewCell%d", indexPath.row];
			
			TextTableViewCell *textCell = (TextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
			if (!textCell) {
				textCell = [[[NSBundle mainBundle] loadNibNamed:@"TextTableViewCell" owner:nil options:nil] lastObject];
                textCell.textLabel.textAlignment = UITextAlignmentCenter;
			}
            
            NSString *customString = [self.customStrings objectAtIndex:indexPath.row];
            [textCell updateDataWithText:customString];
            
            cell = textCell;
		}
            break;
			
		case ProfSectHashtags: {
			static NSString *cellID = @"cellHashtags";
			cell = [tableView dequeueReusableCellWithIdentifier:cellID];
			if (! cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
				UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
				if (font) {
					cell.textLabel.font = font;
				}
			}
			cell.textLabel.text = [NSString stringWithFormat:@"#%@", [self.allHashtags objectAtIndex:row]];
			break;
		}
	}

	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	switch (section) {
		case ProfSectPosts:
			return self.headerPosts;
			
		case ProfSectHashtags:
			return self.headerHashtags;
            
        case UsrProfileSectionTemplText:
            return self.headerCustomText;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 22;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {

		case ProfSectPosts: {
			ZMailDataModel *msgModel = [self.allPosts objectAtIndex:indexPath.row];
			return [self.controlPersonPostCell heightWithText:msgModel.descript hasImage:[msgModel hasImage]];
		}
			
		case ProfSectHashtags:
			return 44;
            
        case UsrProfileSectionTemplText: {
            
			CGFloat h = [self.customTextCell heightForText:[self.customStrings objectAtIndex:indexPath.row] isSwitchVisible:NO];
			h = MAX(h, 44);
			return h + 5;
		}
	}
	return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.section) {
			
		case ProfSectPosts: {
			ZMailDataModel *msgModel = [self.allPosts objectAtIndex:indexPath.row];
			ZCommentsListVC *ctr = [ZCommentsListVC controller];
			ctr.mailModel = msgModel;
			ctr.userModel = self.userModel;
			[self.navigationController pushViewController:ctr animated:YES];
			break;
		}
        case ProfSectHashtags:
        {
            NSString *hashtag = [self.allHashtags objectAtIndex:indexPath.row];
			ZMailListViewController *ctrl = [[[ZMailListViewController alloc] initWithPersonId:self.userModel.ID hashtag:hashtag] autorelease];
            [self.navigationController pushViewController:ctrl animated:YES];
			break;
		}
			
	}//sw
}


#pragma mark - Actions

-(void)sendInstanceMessage_Action
{
    ZPersonalMessageViewController *ctrl = [ZPersonalMessageViewController controller];
    ctrl.userModel = self.userModel;
    ctrl.personModel = self.personModel;
    ctrl.previousController = self;
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)postsButton_Clicked
{
    ZMailListViewController *ctrl = [[[ZMailListViewController alloc] initWithPersonId:self.personModel.ID] autorelease];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)friendsButton_Clicked
{
    ZUserListViewController *ctrl = [[[ZUserListViewController alloc] initAsFriends:self.personModel.ID] autorelease];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)folowersButton_Clicked
{
    ZUserListViewController *ctrl = [[[ZUserListViewController alloc] initAsFolowers:self.personModel.ID] autorelease];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)folowingButton_Clicked
{
    ZUserListViewController *ctrl = [[[ZUserListViewController alloc] initAsFollowing:self.personModel.ID] autorelease];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)actFollow:(id)sender {
	LLog(@"");
	
	if (!self.personModel) {
		LLog(@"NO person");
		return;
	}
	
	//	friends.php?action=unfollow&user_id=&sess_id=
	
	NSString *follow = self.personModel.isFollow ? @"unfollow" : @"follow";
	[self runRequestFollow:follow personID:self.personModel.ID];
}

- (IBAction)actSettings {
	LLog(@"");
	
//	SettingsViewController *ctr = [SettingsViewController controller];
//	[self.navigationController pushViewController:ctr animated:YES];
	
	[self actMoreActions:nil];
}

- (IBAction)actMoreActions:(id)sender {
	
	if (!self.personModel) {
		LLog(@"NO personModel");
		return;
	}

	UIActionSheet *sheet = nil;
	NSString *commentID = self.commentModel.ID;
	if (commentID) {
		sheet = [[UIActionSheet alloc] initWithTitle:@"More Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
				 @"Legit",
				 @"Try Again",
                 @"Personal message",
				 @"Block",
				 @"Unblock",
				 (self.personModel.isFriend ? @"Friends no More" : @"Make a Friend"),
				 nil];
	}
	else {
		sheet = [[UIActionSheet alloc] initWithTitle:@"More Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                 @"Personal message",
				 @"Block",
				 @"Unblock",
				 (self.personModel.isFriend ? @"Friends no More" : @"Make a Friend"),
				 nil];
	}
	[sheet showInView:self.view];
	[sheet release];
}

//	UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	NSString *commentID = self.commentModel.ID;
	if (!commentID) {
		LLog(@"NO comment");
		// move index
		buttonIndex += 2;
	}

	
	switch (buttonIndex) {
		case 0:
			[self runRequestLikeUser:YES];
			break;
			
		case 1:
			[self runRequestLikeUser:NO];
			break;
            
        case 2:
			[self sendInstanceMessage_Action];
			break;
			
		case 3:
			[self runRequestBlockUser:YES];
			break;
			
		case 4:
			[self runRequestBlockUser:NO];
			break;
			
		case 5:
			[self runRequestMakeFriend:!self.personModel.isFriend];
			break;
			
		default:
			break;
	}
}

#pragma mark - Requests

- (void)runRequestPersonProfileWithID:(NSString *)userID showLoadingView:(BOOL)showLoadingView
{
	ZCommonRequest *rq = [ZCommonRequest requestPersonProfileWithID:userID];
	
    if(showLoadingView)
        [super showProgress];
    
	dispatch_async(dispatch_queue_create("request.profile", NULL), ^{
		[rq startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[super hideProgress];
			[self handlePersonProfileRequest:rq];
		});
	});
}

- (void)runRequestPersonProfileWithUsername:(NSString *)username showLoadingView:(BOOL)showLoadingView
{
	ZCommonRequest *rq = [ZCommonRequest requestPersonProfileWithUsername:username];
	
    if(showLoadingView)
        [super showProgress];
    
	dispatch_async(dispatch_queue_create("request.profile", NULL), ^{
		[rq startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[super hideProgress];
			[self handlePersonProfileRequest:rq];
		});
	});
}

- (void)handlePersonProfileRequest:(ZCommonRequest *)rq {
	
	NSDictionary *resultDict = [[rq responseString] JSONValue];
	
	if (resultDict.count) {
		LLog(@"%@", resultDict);
	}
	else {
		LLog(@"resp:'%@'; err:'%@'", [rq responseString], rq.error);
	}
	
	if (!rq.error) {
		ZPersonModel *personModel = [ZPersonModel modelWithID:self.commentModel.userID];
		[personModel updateWithDetailedInfoDictionary:resultDict];
		self.personModel = personModel;
		
		self.allHashtags = personModel.hashtags;
		self.allPosts = personModel.latestPosts;
		
        [self.customStrings removeAllObjects];
        for(NSString *str in self.personModel.customFields)
        {
            [self.customStrings addObject:str];
        }
        
		[self reloadData];
	}
}

- (void)runRequestFollow:(NSString *)follow personID:personID {
	
	NSDictionary *args = @{@"action" : follow,	@"user_id" : personID };
	LLog(@"args:{{%@}}", args);
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"friends" arguments:args];
	[super showProgress];
	dispatch_async(dispatch_queue_create("request.friends.follow", NULL), ^{
		[request startSynchronous];
		dispatch_async(dispatch_get_main_queue(), ^{
			LLog(@"resp:'%@'; err:'%@'", [request responseString], request.error);
			[super hideProgress];
			
			if (!request.error) {
				NSDictionary *resultDict = [[request responseString] JSONValue];
				if ([resultDict isKindOfClass:[NSDictionary class]]) {
					NSString *status = resultDict[@"status"];
					if ([status isEqualToString:@"error"]) {
						NSString *errMsg = resultDict[@"msg"];
						LLog(@"err msg: '%@'", errMsg);
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Performe Action" message:errMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
						[alert show];
						[alert release];
					}
					else if ([status isEqualToString:@"ok"]) {
						self.personModel.isFollow = !self.personModel.isFollow;
						[self validateButtons];
					}
					else {
						LLog(@"wrong status: '%@'", status);
					}
				}
				else {
					LLog(@"wrong response");
				}
			}
			
			//	update
			[self runRequestPersonProfileWithID:self.personModel.ID showLoadingView:YES];
		});
	});
}

#pragma mark - Like/Unlike // Block/Unblock
//	aka: legit / try again
- (void)runRequestLikeUser:(BOOL)like {
	
	NSString *commentID = self.commentModel.ID;
	if (!commentID) {
		LLog(@"NO comment");
		return;
	}
	
	NSString *action = like ? @"like" : @"dislike";
	
	NSDictionary *args = @{@"action":action, @"item_id":commentID, @"type":@"2"};
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"rating" arguments:args];

	[super showProgress];
	dispatch_async(dispatch_queue_create("request.rating.(dis)like", NULL), ^{
		[request startSynchronous];
		LLog(@"resp:'%@'; err:'%@'", [request responseString], request.error);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self runRequestPersonProfileWithID:self.personModel.ID showLoadingView:YES];
		});
	});
}

- (void)runRequestBlockUser:(BOOL)blockUser {
	
	NSString *action = blockUser ? @"block" : @"unblock";
	NSDictionary *args = @{@"action" : action, @"user_id" : self.personModel.ID};
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"friends" arguments:args];
	
	[super showProgress];
	dispatch_async(dispatch_queue_create("request.friends.(un)block", NULL), ^{
		[request startSynchronous];
		LLog(@"resp:'%@'; err:'%@'", [request responseString], request.error);
		BOOL shouldGoHome = blockUser && (request.error == nil);
		dispatch_async(dispatch_get_main_queue(), ^{
			if (shouldGoHome) {
				[super hideProgress];
				[APP_DLG invalidateMap];
				[APP_DLG goHome];
			}
			else {
				[self runRequestPersonProfileWithID:self.personModel.ID showLoadingView:YES];
			}
		});
	});
}

- (void)runRequestMakeFriend:(BOOL)isFriend {
	
	NSString *action = isFriend ? @"add" : @"del";
	NSDictionary *args = @{@"action" : action, @"user_id" : self.personModel.ID};
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"friends" arguments:args];
	
	[super showProgress];
	dispatch_async(dispatch_queue_create("request.friends.make-friend", NULL), ^{
		[request startSynchronous];
		BOOL shouldGoHome = NO;
		dispatch_async(dispatch_get_main_queue(), ^{
			if (shouldGoHome) {
				[super hideProgress];
				[APP_DLG invalidateMap];
				[APP_DLG goHome];
			}
			else {
				//	this updates friend's status
				[self runRequestPersonProfileWithID:self.personModel.ID showLoadingView:YES];
			}
		});
	});
}

@end
