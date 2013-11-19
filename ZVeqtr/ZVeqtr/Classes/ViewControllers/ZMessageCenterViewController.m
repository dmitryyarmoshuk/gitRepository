//
//  ZMessageCenterViewController.m
//  ZVeqtr
//
//  Created by Maxim on 2/13/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZMessageCenterViewController.h"
#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "ZNotificationModel.h"
#import "ZMailListCell.h"
#import "EGOImageView.h"

#import "ZPersonProfileVC.h"
#import "ZCommentsListVC.h"

#import "ZPersonModel.h"
#import "ZMailDataModel.h"
#import "ZUserListViewController.h"
#import "ZSellModuleImageDescriptionViewController.h"
#import "ZConversationModel.h"

#import "ZVenueConversationVC.h"

#import "RegisterViewController.h"

#import "HomeViewController.h"


@interface ZMessageCenterViewController ()

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSString *lastNotificationId;
@property (nonatomic, retain) NSMutableArray *conversations;

@property (nonatomic, assign) BOOL isInitialLoading;
@property (nonatomic, retain) ZNotificationCell		*notificationCell;

@end

@implementation ZMessageCenterViewController

- (ZUserModel *)userModel {
	return APP_DLG.currentUser;
}

- (void)dealloc {
    self.notifications = nil;
    self.lastNotificationId = nil;
    self.notificationCell = nil;
    self.table.delegate = nil;
	[super dealloc];
}

- (void)releaseOutlets {
	[super releaseOutlets];
	self.table = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isInitialLoading = YES;
    [self presentBackBarButtonItem];
    self.table.tableHeaderView.hidden = YES;
    
    //self.title = @"Notifications";
    self.notifications = [NSMutableArray array];
    self.lastNotificationId = nil;
    
    self.notificationCell = [ZNotificationCell cell];
	CGRect cellFrame = self.notificationCell.frame;
	cellFrame.size.width = self.table.frame.size.width;
	self.notificationCell.frame = cellFrame;
    
    [self runRequestNotifications:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (IBAction)actGoHome
{
	[APP_DLG.navigationController dismissModalViewControllerAnimated:YES];
}
 */

#pragma mark - Requests

- (void)runRequestNotifications:(BOOL)showLoading
{
    if(showLoading)
        [super showProgress];
	else
        [self.activityView startAnimating];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"notify"];
	
    NSDictionary *args = @{@"action" : @"get_items", @"type" : self.notificationType};
    [request addPostValuesForKeys:args];
    
    if(self.lastNotificationId)
    {
        NSDictionary *args = @{@"last_id" : self.lastNotificationId};
        
        [request addPostValuesForKeys:args];
    }
    
	dispatch_async(dispatch_queue_create("request.notify", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (request.error)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot get Messages" message:request.error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
                return;
            }
            
            NSString *responseString = [request responseString];
            NSArray *resultArr = [responseString JSONValue];
            LLog(@"--->NOTIFICATIONS JSON:\n%@", resultArr);
            
            NSMutableArray *oldNotifications = [NSMutableArray arrayWithArray:self.notifications];
            [self.notifications removeAllObjects];
            for (NSDictionary *dict in resultArr)
            {
                ZNotificationModel *model = [ZNotificationModel notificationModelWithDictionary:dict];
                [self.notifications addObject:model];
            }
            
            [self.notifications addObjectsFromArray:oldNotifications];
            if(self.notifications.count > 0)
            {
                ZNotificationModel *model = [self.notifications objectAtIndex:0];
                self.lastNotificationId = model.id;
            }
            
            self.isInitialLoading = NO;
            self.table.tableHeaderView.hidden = NO;
            
            [super hideProgress];
            [self.activityView stopAnimating];
            [self.table reloadData];
            
            [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            self.userModel.unreadNotificationsCount = 0;
		});
	});
}

#pragma mark - ZNotificationCell Delegate

-(void)notificationCellUsernameClicked:(ZNotificationCell*)cell
{
    NSLog(@"%@", cell.notificationModel.nickname);
    
    if([cell.notificationModel.creatorId isEqualToString:[self userModel].ID])
    {
        //current user
        ZPersonProfileVC *ctr = [ZPersonProfileVC controller];
        ctr.userModel = [self userModel];
        [self.navigationController pushViewController:ctr animated:YES];
    }
    else
    {
        ZPersonModel *personModel = [ZPersonModel modelWithID:cell.notificationModel.creatorId];
        
        ZPersonProfileVC *ctr = [ZPersonProfileVC controller];
        ctr.personModel = personModel;
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

-(void)notificationCellPostClicked:(ZNotificationCell*)cell
{
    if([cell.notificationModel.actionType isEqualToString:kNTFriendRequest])
    {
        ZUserListViewController *ctrl = [[ZUserListViewController alloc] initAsFriendRequests:APP_DLG.currentUser.ID];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
    else if([cell.notificationModel.actionType isEqualToString:kNTCommentSale])
    {
        ZSellModuleImageDescriptionViewController *ctrl = [ZSellModuleImageDescriptionViewController controller];
        ctrl.imageModelId = cell.notificationModel.postId;
        ctrl.screenState = ImageDescriptionScreenStateDefault;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
    else if([cell.notificationModel.actionType isEqualToString:kNTFriendFollowers])
    {
        if([cell.notificationModel.creatorId isEqualToString:[self userModel].ID])
        {
            //current user
            ZPersonProfileVC *ctr = [ZPersonProfileVC controller];
            ctr.userModel = [self userModel];
            [self.navigationController pushViewController:ctr animated:YES];
        }
        else
        {
            ZPersonModel *personModel = [ZPersonModel modelWithID:cell.notificationModel.creatorId];
            
            ZPersonProfileVC *ctr = [ZPersonProfileVC controller];
            ctr.personModel = personModel;
            [self.navigationController pushViewController:ctr animated:YES];
        }
    }
    else if([cell.notificationModel.actionType isEqualToString:kNTComments] ||
            [cell.notificationModel.actionType isEqualToString:kNTPrivateMessages] ||
            [cell.notificationModel.actionType isEqualToString:kNTLegitComments] ||
            [cell.notificationModel.actionType isEqualToString:kNTLegitPosts]
            )
    {
        ZMailDataModel *mailModel = [ZMailDataModel modelWithID:cell.notificationModel.postId];
        
        ZCommentsListVC *ctr = [ZCommentsListVC controller];
        ctr.mailModel = mailModel;
        ctr.userModel = self.userModel;
        [self.navigationController pushViewController:ctr animated:YES];
    }
    else if([cell.notificationModel.actionType isEqualToString:kNTCommentConversation] ||
            [cell.notificationModel.actionType isEqualToString:kNTLegitCommentsConversation] ||
            [cell.notificationModel.actionType isEqualToString:kNTLegitConversation]
            )
    {
        NSLog(@"ID=%@",cell.notificationModel.postId);
        ZConversationModel *model = [ZConversationModel modelWithID:cell.notificationModel.postId];
        
        ZVenueConversationVC *ctr = [ZVenueConversationVC controller];
        ctr.conversationModel = model;
        [self.navigationController pushViewController:ctr animated:YES];        
    }
}

-(void)notificationCellToMapButtonClicked:(ZNotificationCell*)cell
{
    ZNotificationModel *model = cell.notificationModel;
    if([model.actionType isEqualToString:kNTComments]
       || [model.actionType isEqualToString:kNTPrivateMessages]
       || [model.actionType isEqualToString:kNTLegitPosts]
       || [model.actionType isEqualToString:kNTLegitComments]
       )
    {
        ZMailDataModel *mailModel = [ZMailDataModel modelWithID:model.postId];
        [APP_DLG.homeViewController showConversationOnMap:mailModel];
    }
    else if([model.actionType isEqualToString:kNTCommentConversation]
            || [model.actionType isEqualToString:kNTLegitConversation]
            || [model.actionType isEqualToString:kNTLegitCommentsConversation])
    {
        ZVenueModel *venueModel = [ZVenueModel modelWithID:model.postId];
        [APP_DLG.homeViewController showVenueOnMap:venueModel];
    }
    else if([model.actionType isEqualToString:kNTCommentSale])
    {
        ZGarageSaleModel *garageSale = [ZGarageSaleModel modelWithID:model.postId];
        [APP_DLG.homeViewController showSaleOnMap:garageSale];
    }
}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (([scrollView contentOffset].y + scrollView.frame.size.height) == [scrollView contentSize].height)
    {
        /*
        if(numberOfProductsForCurrentSearch > self.products.count)
        {
            [self loadProductsForPage:self.products.count/10+1 showLoading:NO];
        }
         */
        //[self runRequestNotifications:NO];
        
        return;
	}
	if ([scrollView contentOffset].y == scrollView.frame.origin.y)
    {
        [self runRequestNotifications:NO];
        
        return;
	}
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isInitialLoading)
        return 0;
    
	return self.notifications.count > 0 ? self.notifications.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.notifications.count > 0)
    {
        ZNotificationCell *cell = nil;
        
        static NSString *cellID = @"ZNotificationCell";
        cell = (ZNotificationCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        if (! cell) {
            cell = [ZNotificationCell cell];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        ZNotificationModel *notificationModel = [self.notifications objectAtIndex:indexPath.row];
        [cell setNotificationModel:notificationModel];
        
        return cell;
    }
    
    static NSString *cellID = @"UITableViewCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (! cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    cell.textLabel.text = @"No notifications";
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
    ZMailDataModel *model = [self.mails objectAtIndex:indexPath.row];
    ZCommentsListVC *ctr = [ZCommentsListVC controller];
    ctr.mailModel = model;
    ctr.userModel = self.userModel;
    [self.navigationController pushViewController:ctr animated:YES];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.notifications.count > 0)
    {
        ZNotificationModel *notificationModel = [self.notifications objectAtIndex:indexPath.row];
        
        return [self.notificationCell heightWithNotificationModel:notificationModel];
    }

    return tableView.rowHeight;
}

@end
