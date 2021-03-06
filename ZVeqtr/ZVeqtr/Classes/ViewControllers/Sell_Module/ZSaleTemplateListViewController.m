//
//  ZSaleTemplateListViewController.m
//  ZVeqtr
//
//  Created by Maxim on 4/25/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSaleTemplateListViewController.h"
#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "ZGarageSaleRootViewController.h"
#import "ZProductSaleDetailsViewController.h"
#import "ZGarageSaleDetailsViewController.h"

#import "ZGarageSaleModel.h"

#import "ZSaleCell.h"


@interface ZSaleTemplateListViewController ()

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSMutableArray *productsArray;
@property (nonatomic, retain) NSMutableArray *servicesArray;
@property (nonatomic, retain) NSMutableArray *garageSalesArray;

@end


@implementation ZSaleTemplateListViewController

- (void)dealloc
{
    self.productsArray = nil;
    self.servicesArray = nil;
    self.garageSalesArray = nil;
    
	[super dealloc];
}

- (void)releaseOutlets {
	[super releaseOutlets];
	self.table = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.productsArray = [NSMutableArray array];
    self.servicesArray = [NSMutableArray array];
    self.garageSalesArray = [NSMutableArray array];
    
    self.table.editing = YES;
    
    [self presentBackBarButtonItem];
    
    //self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddSale)] autorelease];
    
    self.title = @"Choose Template";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self requestTemplates];
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Requests

- (void)requestTemplates
{
    [self.productsArray removeAllObjects];
    [self.servicesArray removeAllObjects];
    [self.garageSalesArray removeAllObjects];
    
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:@"show_all" forKey:@"action"];
    [args setObject:@"1" forKey:@"is_tpl"];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    [super showProgress];
    
	dispatch_async(dispatch_queue_create("request.sale.get", NULL), ^{
        
		[request startSynchronous];
        
		dispatch_async(dispatch_get_main_queue(), ^{
            
            [super hideProgress];
            
            if (request.error)
            {
                [APP_DLG showAlertWithMessage:request.error.localizedDescription title:nil];
                
                return;
            }
            
            NSString *responseString = [request responseString];
            NSLog(@"%@", responseString);
            NSArray *resultArr = [responseString JSONValue];
            
            for (NSDictionary *dic in resultArr)
            {
                ZGarageSaleModel *model = [ZGarageSaleModel modelWithDictionary:dic];
                if([model.type isEqualToString:SALE_TYPE_PRODUCT])
                {
                    [self.productsArray addObject:model];
                }
                else if([model.type isEqualToString:SALE_TYPE_SERVICE])
                {
                    [self.servicesArray addObject:model];
                }
                else if([model.type isEqualToString:SALE_TYPE_GARAGE_SALE])
                {
                    [self.garageSalesArray addObject:model];
                }
            }
            
            [self.table reloadData];
		});
	});
}

- (void)createSaleBasedOnTemplate:(ZGarageSaleModel*)saleModel
{
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:@"make_copy" forKey:@"action"];
    [args setObject:saleModel.ID forKey:@"sale_id"];
    [args setObject:@"sale" forKey:@"type"];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    
    [super showProgress];
    
	dispatch_async(dispatch_queue_create("request.sale.get", NULL), ^{
        
		[request startSynchronous];
        
		dispatch_async(dispatch_get_main_queue(), ^{
            
            [super hideProgress];
            
            if (request.error)
            {
                [APP_DLG showAlertWithMessage:request.error.localizedDescription title:nil];
                
                return;
            }
            
            NSString *responseString = [request responseString];
            NSLog(@"%@", responseString);
            
            saleModel.ID = responseString;
            
            if([saleModel.type isEqualToString:SALE_TYPE_PRODUCT])
            {
                ZProductSaleDetailsViewController *ctrl = [ZProductSaleDetailsViewController controller];
                ctrl.garageSaleModel = saleModel;
                [self.navigationController pushViewController:ctrl animated:YES];
            }
            else if([saleModel.type isEqualToString:SALE_TYPE_SERVICE])
            {
                ZProductSaleDetailsViewController *ctrl = [ZProductSaleDetailsViewController controller];
                ctrl.garageSaleModel = saleModel;
                [self.navigationController pushViewController:ctrl animated:YES];
            }
            else if([saleModel.type isEqualToString:SALE_TYPE_GARAGE_SALE])
            {
                ZGarageSaleDetailsViewController *ctrl = [ZGarageSaleDetailsViewController controller];
                ctrl.garageSaleModel = saleModel;
                [self.navigationController pushViewController:ctrl animated:YES];
            }
		});
	});
}

- (void)deleteSaleTemplate:(NSIndexPath*)indexPath
{
    NSMutableArray *array = nil;
    if(indexPath.section == 0)
    {
        array = self.productsArray;
        // model = [self.productsArray objectAtIndex:indexPath.row];
    }
    else if(indexPath.section == 1)
    {
        array = self.servicesArray;
        //model = [self.servicesArray objectAtIndex:indexPath.row];
    }
    else
    {
        array = self.garageSalesArray;
        // model = [self.garageSalesArray objectAtIndex:indexPath.row];
	}
    
    ZGarageSaleModel *model = [array objectAtIndex:indexPath.row];
    
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:@"delete" forKey:@"action"];
    [args setObject:model.ID forKey:@"sale_id"];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    
    [super showProgress];
    
	dispatch_async(dispatch_queue_create("request.sale.delete", NULL), ^{
		[request startSynchronous];
        
		dispatch_async(dispatch_get_main_queue(), ^{
            
            [super hideProgress];
            
            if (request.error)
            {
                [APP_DLG showAlertWithMessage:request.error.localizedDescription title:nil];
                
                return;
            }
            
            NSString *responseString = [request responseString];
            NSLog(@"%@", responseString);
            
            [array removeObject:model];
            [self.table beginUpdates];
            
            [self.table  deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [self.table endUpdates];
		});
	});
}

#pragma mark - Actions

-(void)actionAddSale
{
  //  ZGarageSaleRootViewController *ctrl = [ZGarageSaleRootViewController controller];
    //[self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark - Table View

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return @"Products";
    }
    else if( section == 1)
    {
        return @"Services";
    }
    
    return @"Garage Sales";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0)
    {
        return self.productsArray.count;
    }
    else if( section == 1)
    {
        return self.servicesArray.count;
    }
    
    return self.garageSalesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"ZSaleCell";
    
    ZSaleCell *cell = (ZSaleCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [ZSaleCell cell];
    }
    
    ZGarageSaleModel *model = nil;
    if(indexPath.section == 0)
    {
        model = [self.productsArray objectAtIndex:indexPath.row];
    }
    else if(indexPath.section == 1)
    {
        model = [self.servicesArray objectAtIndex:indexPath.row];
    }
    else
    {
        model = [self.garageSalesArray objectAtIndex:indexPath.row];
	}
    
    cell.labelName.text = model.name;
    cell.labelDescription.text = model.description;
    
    /*
    if([model.publish boolValue])
    {
        cell.labelStatus.text = @"Active";
        cell.labelStatus.textColor = [UIColor greenColor];
    }
    else
    {
        cell.labelStatus.text = @"Draft";
        cell.labelStatus.textColor = [UIColor grayColor];
    }
    */
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
    
    ZGarageSaleModel *model = nil;
    if(indexPath.section == 0)
    {
        model = [self.productsArray objectAtIndex:indexPath.row];
    }
    else if(indexPath.section == 1)
    {
        model = [self.servicesArray objectAtIndex:indexPath.row];
    }
    else
    {
        model = [self.garageSalesArray objectAtIndex:indexPath.row];
	}
    
    [self createSaleBasedOnTemplate:model];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
        [self deleteSaleTemplate:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

@end
