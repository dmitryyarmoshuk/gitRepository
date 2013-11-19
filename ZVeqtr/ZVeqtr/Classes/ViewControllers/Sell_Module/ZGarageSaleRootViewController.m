//
//  ZGarageSaleRootViewController.m
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZGarageSaleRootViewController.h"
#import "ZGarageSaleDetailsViewController.h"
#import "ZProductSaleDetailsViewController.h"
#import "ZSaleTemplateListViewController.h"


@interface ZGarageSaleRootViewController ()

@property (nonatomic, retain) IBOutlet UITableView *table;

@end

@implementation ZGarageSaleRootViewController

enum {
	kRowProduct,
	kRowService,
	kRowGarageSale,
    
    kRowCounts
};

- (void)dealloc
{
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
    self.title = @"Sell";
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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return kRowCounts;
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"cellID";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (! cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
		
		UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
		if (font) {
			cell.textLabel.font = font;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case kRowProduct:
            {
                cell.textLabel.text = @"Product";
            }
                break;
            case kRowService:
            {
                cell.textLabel.text = @"Service";
            }
                break;
            case kRowGarageSale:
            {
                cell.textLabel.text = @"Garage Sale";
            }
                break;
            default:
                break;
        }
    }
    else
    {
        cell.textLabel.text = @"From Template";
    }

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
    
    ZGarageSaleModel *garageSaleModel = [ZGarageSaleModel modelWithID:nil];
    
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case kRowProduct:
            {
                garageSaleModel.type = SALE_TYPE_PRODUCT;
                
                ZProductSaleDetailsViewController *ctrl = [ZProductSaleDetailsViewController controller];
                ctrl.garageSaleModel = garageSaleModel;
                [self.navigationController pushViewController:ctrl animated:YES];
            }
                break;
            case kRowService:
            {
                garageSaleModel.type = SALE_TYPE_SERVICE;
                
                ZProductSaleDetailsViewController *ctrl = [ZProductSaleDetailsViewController controller];
                ctrl.garageSaleModel = garageSaleModel;
                [self.navigationController pushViewController:ctrl animated:YES];
            }
                break;
            case kRowGarageSale:
            {
                garageSaleModel.type = SALE_TYPE_GARAGE_SALE;
                
                ZGarageSaleDetailsViewController *ctrl = [ZGarageSaleDetailsViewController controller];
                ctrl.garageSaleModel = garageSaleModel;
                [self.navigationController pushViewController:ctrl animated:YES];
            }
                break;
            default:
                break;
        }
    }
    else
    {
        ZSaleTemplateListViewController *ctrl = [ZSaleTemplateListViewController controller];
        
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

@end
