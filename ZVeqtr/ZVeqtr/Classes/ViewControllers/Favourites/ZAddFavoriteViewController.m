//
//  ZAddFavoriteViewController.m
//  ZVeqtr
//
//  Created by Maxim on 1/24/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZAddFavoriteViewController.h"
#import "ZPersonModel.h"
#import "ZFavoriteFilterModel.h"
#import "ZDateComponents.h"

@interface ZAddFavoriteViewController ()

@property (nonatomic, retain) IBOutlet UILabel		*labDescript;
@property (nonatomic, retain) IBOutlet UILabel		*labDateFilter;
@property (nonatomic, retain) IBOutlet UILabel		*labName;
@property (nonatomic, retain) IBOutlet UITextField	*textName;

@end

@implementation ZAddFavoriteViewController

- (ZUserModel *)userModel {
	return APP_DLG.currentUser;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Save filter";
    [self presentSaveBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
    if(!self.model)
    {
        self.labDescript.text = @"This search query will be saved in Favorites.\nTime Filter for this search:";

    }
    else
    {
        self.filterName = self.model.title;
        self.labDescript.text = @"Time Filter for this search:";
    }
    
    self.labDateFilter.text = [[self userModel].dateComponents stringRepresentation];
    self.labName.text = @"Please enter a name for this search:";
    
    self.textName.text = self.filterName;
    [self.textName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.filterName = nil;
    self.filterType = nil;
    self.model = nil;
    
	[super dealloc];
}

- (void)releaseOutlets {
	[super releaseOutlets];
	self.textName = nil;
	self.labDescript = nil;
}

#pragma mark -

- (IBAction)actSave
{
    if(!self.model)
    {
        self.model = [[ZFavoriteFilterModel new] autorelease];
        self.model.id = [[NSProcessInfo processInfo] globallyUniqueString];
        self.model.type = self.filterType;
        self.model.dateComponents = [[self userModel] dateComponents];
        self.model.searchText = self.filterName;
        self.model.zipPlace = self.selectedZipPlace;
    }
    
    self.model.title = self.textName.text;
    [[self userModel] addFavoriteFilterModel:self.model];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
