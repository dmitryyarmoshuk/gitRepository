//
//  ZSellModuleAddImageViewController.m
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSellModuleAddImageViewController.h"
#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "ZSellImageModel.h"
#import "ZSellImageCell.h"
#import "ZSellModuleImageDescriptionViewController.h"
#import "ZGarageSaleDropPinViewController.h"

@interface ZSellModuleAddImageViewController ()


@property (nonatomic, retain) IBOutlet UITableView *table;

@property (nonatomic, retain) NSMutableDictionary *images;
@property (nonatomic, retain) ZSellImageModel *currentImageModel;

@property (nonatomic, assign) int currentSubmitIndex;

@end

@implementation ZSellModuleAddImageViewController

enum {
	kSectionName,
	kSectionDate,
    kSectionLocation,
    kSectionPickOnMap,
    kSectionDescription,
    
    kSectionCounts
};

- (void)dealloc
{
    self.garageSaleModel = nil;
    self.images = nil;
    self.currentImageModel = nil;
    
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
    [self presentSaveBarButtonItem];
    
    self.title = @"Images";
    
    self.images = [NSMutableDictionary dictionaryWithCapacity:10];
    [ZSellImageModel clearAllCachedImages];
    
    [self requestAllImages];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.table reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)savePicture:(UIImage *)picture
{
    self.currentImageModel.image = [picture scaleAndRotate];
    [self.images setObject:self.currentImageModel forKey:self.currentImageModel.position];
    self.currentImageModel = nil;
    
    [self.table reloadData];
}

#pragma mark - Services

-(void)requestAllImages
{
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:@"get_images" forKey:@"action"];
    [args setObject:self.garageSaleModel.ID forKey:@"sale_id"];
    
    [super showProgress];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    
	dispatch_async(dispatch_queue_create("request.sale.get_images", NULL), ^{
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
                ZSellImageModel *model = [ZSellImageModel modelWithDictionary:dic];
                model.garageSaleModel = self.garageSaleModel;
                [self.images setObject:model forKey:model.position];
            }
            
            [self.table reloadData];
		});
	});
}

-(void)processSubmitingImages
{
    if(self.currentSubmitIndex == 1)
    {
        [self showProgress];
    }
    else if(self.currentSubmitIndex > 10)
    {
        [self hideProgress];
        [self imageSubmittingDidFinished];
        return;
    }
    
    ZSellImageModel *model = [self.images objectForKey:[NSString stringWithFormat:@"%d", self.currentSubmitIndex]];
    
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    if(model == nil)
    {
        self.currentSubmitIndex++;
        [self processSubmitingImages];
        return;
    }
    else if(model.isNew && !model.isDeleted)
    {
        [args setObject:@"add_image" forKey:@"action"];
        [args setObject:self.garageSaleModel.ID forKey:@"sale_id"];
        [args setObject:model.position forKey:@"pos"];
        [args setObject:model.status forKey:@"status"];
        if(!model.description)
            model.description = @"";
        [args setObject:model.description forKey:@"description"];
    }
    else if(!model.isNew && model.isDeleted)
    {
        [args setObject:@"del_image" forKey:@"action"];
        [args setObject:self.garageSaleModel.ID forKey:@"sale_id"];
        [args setObject:model.position forKey:@"pos"];
    }
    else if(!model.isNew && !model.isDeleted)
    {
        [args setObject:@"update_image" forKey:@"action"];
        [args setObject:self.garageSaleModel.ID forKey:@"sale_id"];
        [args setObject:model.position forKey:@"pos"];
        [args setObject:model.status forKey:@"status"];
        
        if(!model.description)
            model.description = @"";
        [args setObject:model.description forKey:@"description"];
    }
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    
    if(!model.isDeleted && model.image)
    {
        [request setFile:[model pathPicture] forKey:@"image"];
    }
    
	dispatch_async(dispatch_queue_create("request.friends", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
            
			if (request.error)
            {
               [APP_DLG showAlertWithMessage:request.error.localizedDescription title:nil];
                
                [self hideProgress];
                
                return;
            }
            
            NSString *responseString = [request responseString];
            NSLog(@"%@", responseString);
            
            model.ID = responseString;
            model.isNew = NO;
            
            self.currentSubmitIndex++;
            [self processSubmitingImages];
		});
	});
}

#pragma mark - Events

-(void)imageSubmittingDidFinished
{
    ZGarageSaleDropPinViewController *ctrl = [ZGarageSaleDropPinViewController controller];
    ctrl.saleModel = self.garageSaleModel;
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)actSave
{
    self.currentSubmitIndex = 1;
    [self processSubmitingImages];
}

-(void)takePicture_Action:(UIButton*)button
{
    NSString *position = [NSString stringWithFormat:@"%d", button.tag];
    self.currentImageModel = [self.images objectForKey:position];
    if(!self.currentImageModel)
    {
        self.currentImageModel = [ZSellImageModel newModel];
        self.currentImageModel.garageSaleModel = self.garageSaleModel;
        self.currentImageModel.position = position;
    }
    else
    {
        self.currentImageModel.isDeleted = NO;
    }
    
    [self takePicture];
}

-(void)deletePicture_Action:(UIButton*)button
{
    NSString *position = [NSString stringWithFormat:@"%d", button.tag];
    self.currentImageModel = [self.images objectForKey:position];
    self.currentImageModel.isDeleted = YES;
    self.currentImageModel.image = nil;
    self.currentImageModel.description = @"";
    self.currentImageModel = nil;
    
    [self.table reloadData];
}

#pragma mark - Delegate/Data source Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellID = [NSString stringWithFormat:@"ZSellImageCell%d", indexPath.row];
    
    ZSellImageCell *cell = (ZSellImageCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [ZSellImageCell cell];
        cell.buttonRemoveImage.tag = indexPath.row+1;
        cell.buttonChooseImage.tag = indexPath.row+1;
        
        [cell.buttonChooseImage addTarget:self action:@selector(takePicture_Action:) forControlEvents:UIControlEventTouchUpInside];
        [cell.buttonRemoveImage addTarget:self action:@selector(deletePicture_Action:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.tag = indexPath.row;
    ZSellImageModel *model = [self.images objectForKey:[NSString stringWithFormat:@"%d", indexPath.row+1]];
    
    [cell updateWithSellImage:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
    
     ZSellImageModel *model = [self.images objectForKey:[NSString stringWithFormat:@"%d", indexPath.row+1]];
    if(model && !model.isDeleted)
    {
        ZSellModuleImageDescriptionViewController *ctrl = [ZSellModuleImageDescriptionViewController controller];
        ctrl.imageModel = model;
        ctrl.screenState = ImageDescriptionScreenStateEdit;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

@end
