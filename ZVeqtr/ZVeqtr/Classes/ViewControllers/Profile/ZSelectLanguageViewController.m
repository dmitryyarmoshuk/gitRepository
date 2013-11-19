//
//  ZSelectLanguageViewController.m
//  ZVeqtr
//
//  Created by Maxim on 3/11/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSelectLanguageViewController.h"

#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "ZMailDataModel.h"
#import "ZMailListCell.h"
#import "EGOImageView.h"
#import "ZCommentsListVC.h"

@interface ZSelectLanguageViewController ()

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSMutableArray *languages;
@property (nonatomic, retain) NSString *currentLanguage;

@end

@implementation ZSelectLanguageViewController

- (ZUserModel *)userModel {
	return APP_DLG.currentUser;
}

-(id)initWithLanguage:(NSString*)language
{
    if(self = [super init])
    {
        self.currentLanguage = language;
    }
    
    return self;
}

- (void)dealloc {
    self.languages = nil;
    self.currentLanguage = nil;
    self.delegate = nil;
	[super dealloc];
}

- (void)releaseOutlets {
	[super releaseOutlets];
	self.table = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.languages = [NSMutableArray array];
    
    [self presentBackBarButtonItem];
    [self presentSaveBarButtonItem];
    
    self.title = @"Languages";
    
    [self runRequestAllLanguages];
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

- (IBAction)actSave
{
	[self.delegate controller:self didSelectLanguage:self.currentLanguage];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Requests

- (void)runRequestAllLanguages
{
    /*
	if (!self.personId) {
		[super hideProgress];
		LLog(@"NO mailModel.ID");
		return;
	}
    
    [super showProgress];
	
	NSDictionary *args = @{@"by_user" : self.personId};
    
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
                [APP_DLG showAlertWithMessage:request.error.localizedDescription title:nil];
                
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
     */
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.languages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellID = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (! cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
    }
    
    NSString *language = [self.languages objectAtIndex:indexPath.row];
    cell.textLabel.text = language;
    
    cell.accessoryType = [self.currentLanguage isEqualToString:language] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
    
    self.currentLanguage = [self.languages objectAtIndex:indexPath.row];
    [self.table reloadData];

}

@end
