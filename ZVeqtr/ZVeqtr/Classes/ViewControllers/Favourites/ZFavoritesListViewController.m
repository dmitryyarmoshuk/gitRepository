//
//  ZFavoritesListViewController.m
//  ZVeqtr
//
//  Created by Maxim on 1/24/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZFavoritesListViewController.h"
#import "ZPersonModel.h"
#import "ZFavoriteFilterModel.h"
#import "ZDateComponents.h"
#import "ZAddFavoriteViewController.h"


@interface ZFavoritesListViewController ()

@property (nonatomic, retain) ZFavoriteFilterModel *selectedFilter;

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, retain) NSMutableArray *arrayFilters;

@end

@implementation ZFavoritesListViewController

- (ZUserModel *)userModel {
	return APP_DLG.currentUser;
}

- (void)dealloc {
    self.arrayFilters = nil;
	[super dealloc];
}

- (void)releaseOutlets {
	[super releaseOutlets];
	self.table = nil;
	self.segmentControl = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Favorites";
    self.navigationItem.leftBarButtonItem = [super homeBarButtonItem];
    self.navigationItem.rightBarButtonItem = [super editButtonItem];
    
    self.arrayFilters = [[self userModel] allFavouriteFiltersForType:[self currentFilterType]];
    [self.table reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self.table reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
-(NSString*)currentFilterType
{
    NSInteger selectedScope = self.segmentControl.selectedSegmentIndex;
    if(selectedScope == 0)
        return FILTER_TYPE_LOCATION;
    else if(selectedScope == 1)
        return FILTER_TYPE_USER;
    
    return FILTER_TYPE_HASHTAG;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.table setEditing:editing animated:animated];
}

#pragma mark -

//	image picker's result handler
- (void)savePicture:(UIImage *)picture {
	
	UIImage *image = [picture scaleAndRotate];
	self.selectedFilter.image = image;
    
    [self.table reloadData];
}

#pragma mark -

-(IBAction)segmentValueChanged:(UISegmentedControl*)segmControl
{
    self.arrayFilters = [[self userModel] allFavouriteFiltersForType:[self currentFilterType]];
    [self.table reloadData];
}

#pragma mark - ZFavoriteCell delegate

-(void)pictureButtonClickedInCell:(ZFavoriteCell*)cell
{
    if(self.editing)
    {
        NSIndexPath *indexPath = [self.table indexPathForCell:cell];
        
        self.selectedFilter = [self.arrayFilters objectAtIndex:indexPath.row];
        [super takePicture];
        //TODO:
        //Change picture
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.arrayFilters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"cellID";
	ZFavoriteCell *cell = [self.table dequeueReusableCellWithIdentifier:cellID];
	if (!cell) {
		cell = [[ZFavoriteCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
		[cell autorelease];
		cell.detailTextLabel.numberOfLines = 0;
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.delegate = self;
	}
    
    ZFavoriteFilterModel *model = [self.arrayFilters objectAtIndex:indexPath.row];
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Time Filter: %@", [model.dateComponents stringRepresentation]];
    
    UIImage *iFilter = model.image;
    cell.filterImage.image = iFilter ? iFilter : [UIImage imageNamed:@"btn-takepic1-boy.png"];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
    
    ZFavoriteFilterModel *model = [self.arrayFilters objectAtIndex:indexPath.row];
    
    if(self.editing)
    {
        ZAddFavoriteViewController *ctrl = [ZAddFavoriteViewController controller];
        ctrl.model = model;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
    else if(self.delegate && [self.delegate respondsToSelector:@selector(favoriteListController:didSelectedFilterModel:)])
    {
        [self.delegate favoriteListController:self didSelectedFilterModel:model];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFavoriteFilterModel *model = [self.arrayFilters objectAtIndex:indexPath.row];
    [[self userModel] deleteFavoriteFilterModel:model];
    [self.arrayFilters removeObject:model];
    
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

@end
