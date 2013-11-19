//
//  ZVenueConversationListVC.m
//  ZVeqtr
//
//  Created by Maxim on 6/21/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZVenueConversationListVC.h"
#import "ZVenueModel.h"
#import "ZConversationModel.h"
//#import "EGOImageView.h"

#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "ZVenueConversationDetailsVC.h"
#import "ZVenueConversationVC.h"

#import "ZListPostCell.h"

@interface ZVenueConversationListVC ()

@property (nonatomic, retain) NSMutableArray *conversations;

@end

@implementation ZVenueConversationListVC

- (ZUserModel *)userModel {
	return APP_DLG.currentUser;
}

- (void)dealloc {
    self.conversations = nil;
	[super dealloc];
}

- (void)releaseOutlets
{
	[super releaseOutlets];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.conversations = [NSMutableArray array];
    
    [self presentBackBarButtonItem];
    
    self.title = self.venueModel.name; //nil;//@"Conversations";
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(btnAddConversation_Action)] autorelease];
}

-(void)btnAddConversation_Action
{
    ZVenueConversationDetailsVC *ctrl = [ZVenueConversationDetailsVC controller];
    ctrl.venueModel = self.venueModel;
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self runRequestConversations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Requests

- (void)runRequestConversations
{
    //venues.php?sess_id=[sid]&action=get_convers&venue_id=[venue_id]
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    NSDictionary *timefilter = [self.userModel dateFilterArguments];
    if (timefilter) {
//		[args addEntriesFromDictionary:timefilter];
        args[@"from_date"] = timefilter[@"from_date"];
	}
    
    [args setObject:self.venueModel.ID forKey:@"venue_id"];
    [args setObject:@"get_convers" forKey:@"action"];
    
    NSLog(@"args=(%@)",args);
    
    [super showProgress];
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"venues" arguments:args];
	
    [self.conversations removeAllObjects];
    
	dispatch_async(dispatch_queue_create("request.friends", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
            [super hideProgress];
            
			if (request.error)
            {
                [APP_DLG showAlertWithMessage:request.error.localizedDescription title:@"Request error"];
                
                return;
            }
            
            NSString *responseString = [request responseString];
            NSLog(@"respons=(%@)", responseString);
            NSArray *resultArr = [responseString JSONValue];
            
            for (NSDictionary *dic in resultArr)
            {
                ZConversationModel *model = [ZConversationModel modelWithDictionary:dic];
                [self.conversations addObject:model];
            }
            
            [_table reloadData];
		});
	});
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.conversations.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 57;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"ZPersonCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
	if (! cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
    ZConversationModel *model = [self.conversations objectAtIndex:indexPath.row];
    cell.textLabel.text = model.title;
    
	NSLog(@">>>%@",model.name);
	return cell;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ZListPostCell *cell = nil;
	
	static NSString *cellID = @"ZListPostCell";
	cell = (ZListPostCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
	if (! cell) {
		cell = [ZListPostCell cell];
        cell.isDirectMessage = NO; //zs
	}
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    cell.isVenueMessage = NO;
    
    ZConversationModel *model = [self.conversations objectAtIndex:indexPath.row];
    cell.labMessage.hidden = YES;
    cell.picture.imageURL = [NSURL urlPersonProfileImageWithID:model.user_id];
    
	return cell;
}
 */


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZConversationModel *model = [self.conversations objectAtIndex:indexPath.row];
    
    ZVenueConversationVC *vc = [ZVenueConversationVC controller];
    vc.conversationModel = model;
    vc.venueModel = self.venueModel;
    vc.index = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
    
    /*
    if(self.listStyle != ListStyleFriendRequests)
    {
        ZPersonModel *model = [self.persons objectAtIndex:indexPath.row];
        ZPersonProfileVC *ctr = [ZPersonProfileVC controller];
        ctr.personModel = model;
        [self.navigationController pushViewController:ctr animated:YES];
    }
    */
}

@end
