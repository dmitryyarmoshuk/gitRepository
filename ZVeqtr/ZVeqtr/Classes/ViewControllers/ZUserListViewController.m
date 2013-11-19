//
//  ZUserListViewController.m
//  ZVeqtr
//
//  Created by Maxim on 2/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZUserListViewController.h"
#import "ZPersonModel.h"
#import "EGOImageView.h"
#import "ZPersonProfileVC.h"

#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "CustomBadge.h"

typedef enum
{
    ListStyleFolowers,
    ListStyleFollowing,
    ListStyleFriends,
    ListStyleFriendRequests
    
} eListStyle;

@interface ZUserListViewController ()

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet CustomBadge *badgeFriendRequests;
@property (nonatomic, retain) IBOutlet UIView *friendRequestsView;

@property (nonatomic, retain) NSMutableArray *persons;
@property (nonatomic, retain) NSMutableArray *friendRequestsArray;

@property (nonatomic, retain) NSString *personId;
@property (nonatomic, assign) eListStyle listStyle;

@end

@implementation ZUserListViewController

- (ZUserModel *)userModel {
	return APP_DLG.currentUser;
}


-(id)initAsFriends:(NSString*)userId
{
    if([self init])
    {
        self.personId = userId;
        self.listStyle = ListStyleFriends;
        self.persons = [NSMutableArray array];
        self.friendRequestsArray = [NSMutableArray array];
    }
    
    return self;
}

-(id)initAsFolowers:(NSString*)userId
{
    if([self init])
    {
        self.personId = userId;
        self.listStyle = ListStyleFolowers;
        self.persons = [NSMutableArray array];
        self.friendRequestsArray = [NSMutableArray array];
    }
    
    return self;
}

-(id)initAsFollowing:(NSString*)userId
{
    if([self init])
    {
        self.personId = userId;
        self.listStyle = ListStyleFollowing;
        self.persons = [NSMutableArray array];
        self.friendRequestsArray = [NSMutableArray array];
    }
    
    return self;
}

-(id)initAsFriendRequests:(NSString*)userId
{
    if([self init])
    {
        self.personId = userId;
        self.listStyle = ListStyleFriendRequests;
        self.persons = [NSMutableArray array];
        self.friendRequestsArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc {
    self.persons = nil;
    self.personId = nil;
	[super dealloc];
}

- (void)releaseOutlets
{
	[super releaseOutlets];
	self.table = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self presentBackBarButtonItem];
    
    if(self.listStyle == ListStyleFriends)
    {
        self.title = @"Friends";
    }
    else if(self.listStyle == ListStyleFolowers)
    {
        self.title = @"Followers";
    }
    else if(self.listStyle == ListStyleFollowing)
    {
        self.title = @"Following";
    }
    else if(self.listStyle == ListStyleFriendRequests)
    {
        self.title = @"Friend requests";
    }
    
    if(self.listStyle == ListStyleFriends && [self.personId isEqualToString:APP_DLG.currentUser.ID])
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.friendRequestsView] autorelease];
    
    self.badgeFriendRequests.hidden = YES;
}

-(IBAction)btnFriendRequests_Action
{
    ZUserListViewController *ctrl = [[[ZUserListViewController alloc] initAsFriendRequests:self.personId] autorelease];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self runRequestPersons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cellApprovedFriend:(ZPersonCell*)cell
{
    NSLog(@"Approved");
    
    NSIndexPath *indexPath = [self.table indexPathForCell:cell];
    
    ZPersonModel *personModel = [self.persons objectAtIndex:indexPath.row];
    [self runRequestApproveFriend:YES userId:personModel.ID];
}

-(void)cellDeclinedFriend:(ZPersonCell*)cell;
{
    NSLog(@"Declined");
    
    NSIndexPath *indexPath = [self.table indexPathForCell:cell];
    
    ZPersonModel *personModel = [self.persons objectAtIndex:indexPath.row];
    [self runRequestApproveFriend:NO userId:personModel.ID];
}

#pragma mark - Requests

- (void)runRequestPersonsWithActionName:(NSString*)actionName resultArray:(NSMutableArray*)resultArray {
    
	if (!self.personId) {
		[super hideProgress];
		LLog(@"NO mailModel.ID");
		return;
	}
    
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
    [args setObject:self.personId forKey:@"user_id"];
    [args setObject:actionName forKey:@"action"];
    
    [super showProgress];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"friends" arguments:args];
	
    [resultArray removeAllObjects];
    
	dispatch_async(dispatch_queue_create("request.friends", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (request.error)
            {
                [APP_DLG showAlertWithMessage:request.error.localizedDescription title:@"Request error"];
                
                return;
            }
            
            NSString *responseString = [request responseString];
            NSLog(@"%@", responseString);
            NSArray *resultArr = [responseString JSONValue];
            
            for (NSDictionary *dic in resultArr)
            {
                ZPersonModel *model = [ZPersonModel modelWithDictionary:dic];
                [resultArray addObject:model];
            }
            
            if([actionName isEqualToString:@"get_friends"])
            {
                [self runRequestPersonsWithActionName:@"get_friends_requests" resultArray:self.friendRequestsArray];
            }
            else if([actionName isEqualToString:@"get_friends_requests"])
            {
                int count = self.friendRequestsArray.count;
                if(count > 0)
                {
                    self.badgeFriendRequests.hidden = NO;
                    [self.badgeFriendRequests autoBadgeSizeWithString:[NSString stringWithFormat:@"%d", count]];
                }
                else
                {
                    self.badgeFriendRequests.hidden = YES;
                }
                
                [super hideProgress];
            }
            else
            {
                [super hideProgress];
            }
            
            [self.table reloadData];
		});
	});
}

- (void)runRequestPersons
{
    NSString *actionName = @"";
    if(self.listStyle == ListStyleFriends)
    {
        actionName = @"get_friends";
    }
    else if(self.listStyle == ListStyleFolowers)
    {
        actionName = @"get_folows";
    }
    else if(self.listStyle == ListStyleFollowing)
    {
        actionName = @"get_folowing";
    }
    else if(self.listStyle == ListStyleFriendRequests)
    {
        actionName = @"get_friends_requests";
    }
    
    [self runRequestPersonsWithActionName:actionName resultArray:self.persons];
}

- (void)runRequestApproveFriend:(BOOL)value userId:(NSString*)userId
{
	NSString *action = value ? @"approve" : @"del";
	NSDictionary *args = @{@"action" : action, @"user_id" : userId};
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"friends" arguments:args];
	
	[super showProgress];
	dispatch_async(dispatch_queue_create("request.friends.make-friend", NULL), ^{
		[request startSynchronous];
		dispatch_async(dispatch_get_main_queue(),
                       ^{
				[self runRequestPersons];
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
	return self.persons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"ZPersonCell";
	ZPersonCell *cell = (ZPersonCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
	if (! cell) {
		cell = [ZPersonCell cell];
        cell.delegate = self;
        
        if(self.listStyle == ListStyleFriendRequests)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setButtonsVisible:YES];
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            [cell setButtonsVisible:NO];
        }
	}
    
    ZPersonModel *model = [self.persons objectAtIndex:indexPath.row];
    cell.labTitle.text = model.nickname != nil ? model.nickname : model.name;
    
    cell.picture.imageURL = [NSURL urlPersonProfileImageWithID:model.ID];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.listStyle != ListStyleFriendRequests)
    {
        ZPersonModel *model = [self.persons objectAtIndex:indexPath.row];
        ZPersonProfileVC *ctr = [ZPersonProfileVC controller];
        ctr.personModel = model;
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

@end
