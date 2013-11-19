//
//  ZNCCategoriesVC.m
//  ZVeqtr
//
//  Created by Maxim on 19.10.13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZNCCategoriesVC.h"

#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "ZMessageCenterViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ZNCCategoriesVC ()

@end

@implementation ZNCCategoriesVC

enum
{
    eTCComments = 0,
    eTCPrivateMessages,
    eTCLegits,
    eTCSales,
    eTCFriendRequests,
    eFollowers,
    
    eTableRowCount
};

-(void)awakeFromNib
{
    /*
    _commentsSectionView.layer.masksToBounds = YES;
    _commentsSectionView.layer.cornerRadius = 4;
    _commentsSectionView.layer.borderColor = [UIColor greenColor].CGColor;
    _commentsSectionView.layer.borderWidth = 1;
    */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self presentBackBarButtonItem];
    
    self.title = @"Categories";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self runRequestNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ZUserModel *)userModel {
	return APP_DLG.currentUser;
}

#pragma mark - Requests

- (void)runRequestNotifications
{
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"notify"];
	
    NSDictionary *args = @{@"action" : @"cnt_detail"};
    
    [request addPostValuesForKeys:args];
    
	dispatch_async(dispatch_queue_create("request.notify", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
            [super hideProgress];
            
			if (request.error)
            {
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot get Notifications count" message:request.error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                */
                return;
            }
            
            NSString *responseString = [request responseString];
            NSLog(@"%@", responseString);
            NSDictionary *resultDictionary = [responseString JSONValue];
            _commentsCount = [[resultDictionary objectForKey:@"comment"] intValue];
            _messagesCount = [[resultDictionary objectForKey:@"pm"] intValue];
            _legitsCount = [[resultDictionary objectForKey:@"leggit"] intValue];
            _salesCount = [[resultDictionary objectForKey:@"sale"] intValue];
            _friendRequestsCount = [[resultDictionary objectForKey:@"friend"] intValue];
            _followersCount = [[resultDictionary objectForKey:@"folower"] intValue];
            
            if(_commentsBadge)
            {
                [_commentsBadge removeFromSuperview];
                _commentsBadge = nil;
            }
            if(_messagesBadge)
            {
                [_messagesBadge removeFromSuperview];
                _messagesBadge = nil;
            }
            if(_legitsBadge)
            {
                [_legitsBadge removeFromSuperview];
                _legitsBadge = nil;
            }
            if(_salesBadge)
            {
                [_salesBadge removeFromSuperview];
                _salesBadge = nil;
            }
            if(_friendsBadge)
            {
                [_friendsBadge removeFromSuperview];
                _friendsBadge = nil;
            }
            if(_followersBadge)
            {
                [_followersBadge removeFromSuperview];
                _followersBadge = nil;
            }
            
            
            if(_commentsCount > 0)
            {
                _commentsBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", _commentsCount]];
                [_commentsSectionView addSubview:_commentsBadge];
                _commentsBadge.frame = CGRectMake(85, 85, _commentsBadge.frame.size.width, _commentsBadge.frame.size.height);
            }

            if(_messagesCount > 0)
            {
                _messagesBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", _messagesCount]];
                [_messagesSectionView addSubview:_messagesBadge];
                _messagesBadge.frame = CGRectMake(85, 85, _messagesBadge.frame.size.width, _messagesBadge.frame.size.height);
            }
            
            if(_legitsCount > 0)
            {
                _legitsBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", _legitsCount]];
                [_legitSectionView addSubview:_legitsBadge];
                _legitsBadge.frame = CGRectMake(85, 85, _legitsBadge.frame.size.width, _legitsBadge.frame.size.height);
            }
            
            if(_salesCount > 0)
            {
                _salesBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", _salesCount]];
                [_salesSectionView addSubview:_salesBadge];
                _salesBadge.frame = CGRectMake(85, 85, _salesBadge.frame.size.width, _salesBadge.frame.size.height);
            }
            
            if(_friendRequestsCount > 0)
            {
                _friendsBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", _friendRequestsCount]];
                [_friendSectionView addSubview:_friendsBadge];
                _friendsBadge.frame = CGRectMake(85, 85, _friendsBadge.frame.size.width, _friendsBadge.frame.size.height);
            }
            
            if(_followersCount > 0)
            {
                _followersBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", _followersCount]];
                [_followersSectionView addSubview:_followersBadge];
                _followersBadge.frame = CGRectMake(85, 85, _followersBadge.frame.size.width, _followersBadge.frame.size.height);
            }
		});
	});
}

-(IBAction)commentsSection_Pressed
{
    [self openSectionWithType:@"comment" title:@"Comments and @ Mentions"];
}

-(IBAction)messagesSection_Pressed
{
    [self openSectionWithType:@"pm" title:@"Messages (Red Envelopes)"];
}

-(IBAction)legitsSection_Pressed
{
    [self openSectionWithType:@"leggit" title:@"Legits"];
}

-(IBAction)salesSection_Pressed
{
    [self openSectionWithType:@"sale" title:@"Sales"];
}

-(IBAction)friendRequestSection_Pressed
{
    [self openSectionWithType:@"friend" title:@"Friend Requests"];
}

-(IBAction)followersSection_Pressed
{
    [self openSectionWithType:@"follow" title:@"Followers"];
}

-(void)openSectionWithType:(NSString*)notificationType title:(NSString*)title
{
    ZMessageCenterViewController *ctrl = [ZMessageCenterViewController controller];
    ctrl.notificationType = notificationType;
    ctrl.title = title;
    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return eTableRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"UITableViewCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (! cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    switch (indexPath.row)
    {
        case eTCComments:
        {
            cell.textLabel.text = @"Comments and @ Mentions";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", _commentsCount];
        }
            break;
        case eTCPrivateMessages:
        {
            cell.textLabel.text = @"Messages (Red Envelopes)";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", _messagesCount];
        }
            break;
        case eTCLegits:
        {
            cell.textLabel.text = @"Legits";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", _legitsCount];
        }
            break;
        case eTCSales:
        {
            cell.textLabel.text = @"Sales";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", _salesCount];
        }
            break;
        case eTCFriendRequests:
        {
            cell.textLabel.text = @"Friend Requests";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", _friendRequestsCount];
        }
            break;
        case eFollowers:
        {
            cell.textLabel.text = @"Followers";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", _followersCount];
        }
            break;
            
        default:
            break;
    }
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *notificationType = @"";
    switch (indexPath.row) {
        case eTCComments:
        {
            notificationType = @"comment";
        }
            break;
        case eTCPrivateMessages:
        {
            notificationType = @"pm";
        }
            break;
        case eTCLegits:
        {
            notificationType = @"leggit";
        }
            break;
        case eTCSales:
        {
            notificationType = @"sale";
        }
            break;
        case eTCFriendRequests:
        {
            notificationType = @"friend";
        }
            break;
        case eFollowers:
        {
            notificationType = @"follow";
        }
            break;
        default:
            break;
    }
    
    ZMessageCenterViewController *ctrl = [ZMessageCenterViewController controller];
    ctrl.notificationType = notificationType;
    [self.navigationController pushViewController:ctrl animated:YES];
}

@end
