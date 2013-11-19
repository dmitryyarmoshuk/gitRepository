//
//  ZMailListViewController.m
//  ZVeqtr
//
//  Created by Maxim on 2/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZMailListViewController.h"

#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "ZMailDataModel.h"
#import "ZMailListCell.h"
#import "EGOImageView.h"
#import "ZCommentsListVC.h"

@interface ZMailListViewController ()

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSMutableArray *mails;
@property (nonatomic, retain) NSString *personId;
@property (nonatomic, retain) NSString *hashtag;

@end

@implementation ZMailListViewController

- (ZUserModel *)userModel {
	return APP_DLG.currentUser;
}

-(id)initWithPersonId:(NSString*)personId;
{
    if([self init])
    {
        self.personId = personId;
        self.mails = [NSMutableArray array];
    }
    
    return self;
}

-(id)initWithPersonId:(NSString*)personId hashtag:(NSString*)hashtag
{
    if([self init])
    {
        self.personId = personId;
        self.hashtag = hashtag;
        self.mails = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc {
    self.mails = nil;
    self.personId = nil;
	[super dealloc];
}

- (void)releaseOutlets {
	[super releaseOutlets];
	self.table = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self presentBackBarButtonItem];
    self.title = @"Posts";
    
    [self runRequestAllMails];
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

#pragma mark - Requests

- (void)runRequestAllMails {
	if (!self.personId) {
		[super hideProgress];
		LLog(@"NO mailModel.ID");
		return;
	}
    
    [super showProgress];
	
	NSMutableDictionary *args = [NSMutableDictionary dictionary
                                 ];
    [args setObject:self.personId forKey:@"by_user"];
    if(self.hashtag)
    {
        [args setObject:self.hashtag forKey:@"find"];
    }
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"place"];
	
    NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithCapacity:8];

	if (args) {
		[arguments addEntriesFromDictionary:args];
	}
    
	[request addPostValuesForKeys:arguments];
    
    [self.mails removeAllObjects];
    
	dispatch_async(dispatch_queue_create("request.place", NULL), ^{
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
            LLog(@"--->MAIL JSON:\n%@", resultArr);
            for (NSDictionary *dict in resultArr)
            {
                ZMailDataModel *model = [ZMailDataModel mailDataModelWithDictionary:dict];
                 [self.mails addObject:model];
            }
            
            [super hideProgress];
            [self.table reloadData];
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
	return self.mails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"ZMailListCell";
	ZMailListCell *cell = (ZMailListCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
	if (! cell) {
		cell = [ZMailListCell cell];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
    ZMailDataModel *model = [self.mails objectAtIndex:indexPath.row];
    cell.labTitle.text = model.title;
    //cell.labNickname.text = model.descript;
    
    if(model.hasImage)
        cell.picture.imageURL = [NSURL urlPlaceImageWithID:model.ID];
	else
        cell.picture.imageURL = [NSURL urlPersonProfileImageWithID:model.userID];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
    
    ZMailDataModel *model = [self.mails objectAtIndex:indexPath.row];
    ZCommentsListVC *ctr = [ZCommentsListVC controller];
    ctr.mailModel = model;
    ctr.userModel = self.userModel;
    [self.navigationController pushViewController:ctr animated:YES];
}


@end
