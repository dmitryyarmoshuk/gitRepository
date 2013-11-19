//
//  ZProductSalePreviewViewController.m
//  ZVeqtr
//
//  Created by Maxim on 4/7/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZProductSalePreviewViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "ZSellImageModel.h"
#import "ZGarageSaleModel.h"
#import "ZSaleImagesTable.h"
#import "ZGarageSaleDetailsViewController.h"
#import "ZProductSaleDetailsViewController.h"
#import "ZSellModuleImageDescriptionViewController.h"

#import "InAppPurchaseManager.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

@interface ZProductSalePreviewViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *companyLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *launchButton;

@property (nonatomic, strong) IBOutlet ZSaleImagesTable *imagesTable;

@property (nonatomic, strong) NSMutableArray *saleImages;

@end

@implementation ZProductSalePreviewViewController

- (void)dealloc
{
    self.garageSaleModel = nil;
    self.saleImages = nil;
	[super dealloc];
}

- (void)releaseOutlets
{
	[super releaseOutlets];
    
    self.nameLabel = nil;
    self.dateLabel = nil;
    self.toolbar = nil;
    self.descriptionLabel = nil;
    self.imagesTable = nil;
    self.scrollView = nil;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _linkLabel.centerVertically = YES;
    _linkLabel.textAlignment = UITextAlignmentLeft;
    //self.labMessage.delegate = self;
    _linkLabel.userInteractionEnabled = YES;
    _linkLabel.automaticallyAddLinksForType = NSTextCheckingTypeLink;
    _linkLabel.numberOfLines = 0;
    
    self.title = self.garageSaleModel.typeName;
    self.saleImages = [NSMutableArray array];
    self.imagesTable.delegate = self;
    
    if(self.isReadonly)
    {
        self.toolbar.hidden = YES;
        self.scrollView.frame = self.view.bounds;
    }
    else if([self.garageSaleModel.publish boolValue])
    {
        self.launchButton.title = @"End Sale";
    }
    else
    {
        self.launchButton.title = @"Launch";
    }
    
    [ZSellImageModel clearAllCachedImages];
    
    /*
     self.textViewBack.layer.masksToBounds = YES;
     self.textViewBack.layer.cornerRadius = 4;
     self.textViewBack.layer.borderColor = [UIColor grayColor].CGColor;
     self.textViewBack.layer.borderWidth = 1;
     */
    
    [self updateData];
    [self requestAllImages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionNotificationReceived:) name:NOTIFICATION_PURCHASE object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateData
{
    int offsetY = self.nameLabel.frame.origin.y;
    
    {
        NSString *firstLabelText = self.garageSaleModel.name;
        
        if(self.garageSaleModel.location && self.garageSaleModel.location.length > 0)
        {
            firstLabelText = [firstLabelText stringByAppendingFormat:@", %@", self.garageSaleModel.location];
        }
        
        self.nameLabel.text = firstLabelText;
        CGSize size = [self calculateSizeForLabel:self.nameLabel];
        self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, offsetY, size.width, size.height);
        offsetY += size.height + 10;
    }
    
    {
        if(self.garageSaleModel.company && self.garageSaleModel.company.length > 0)
        {
            self.companyLabel.text = self.garageSaleModel.company;
            CGSize size = [self calculateSizeForLabel:self.companyLabel];
            self.companyLabel.frame = CGRectMake(self.companyLabel.frame.origin.x, offsetY, size.width, size.height);
            offsetY += size.height + 10;
        }
        else
            self.companyLabel.text = @"";
    }
    
    {
        if(self.garageSaleModel.timePeriod && self.garageSaleModel.timePeriod.length > 0)
        {
            self.dateLabel.text = self.garageSaleModel.timePeriod;
            
            CGSize size = [self calculateSizeForLabel:self.dateLabel];
            self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x, offsetY, size.width, size.height);
            offsetY += size.height + 10;
        }
        else
            self.dateLabel.text = @"";

    }
    
    {
        if(self.garageSaleModel.description && self.garageSaleModel.description.length > 0)
        {
            self.descriptionLabel.text = self.garageSaleModel.description;
            
            CGSize size = [self calculateSizeForLabel:self.descriptionLabel];
            self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, offsetY, size.width, size.height);
            offsetY += size.height + 10;
        }
        else
            self.descriptionLabel.text = @"";
        

    }
    
    {
        if(self.garageSaleModel.website && self.garageSaleModel.website.length > 0)
        {
            NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:self.garageSaleModel.website];
            
            _linkLabel.attributedText = attrStr;
            
            _linkLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, offsetY, _linkLabel.frame.size.width, 20);
            offsetY += 20;
        }
        else
        {
            
            NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:@""];
            
            _linkLabel.attributedText = attrStr;
            _linkLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, offsetY, _linkLabel.frame.size.width, 0);
        }
    }
    
    
    {
        self.imagesTable.frame = CGRectMake(0, offsetY, self.imagesTable.frame.size.width, 0);
        [self.imagesTable reloadImages:self.saleImages];
        offsetY += self.imagesTable.frame.size.height + 10;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, offsetY);
}

-(CGSize)calculateSizeForLabel:(UILabel*)label
{
    CGSize maxSz = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    
    return [label.text sizeWithFont:label.font constrainedToSize:maxSz lineBreakMode:label.lineBreakMode];
}

-(void)publishSale:(BOOL)value
{
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:@"update" forKey:@"action"];
    [args setObject:self.garageSaleModel.ID forKey:@"sale_id"];
    [args setObject:self.garageSaleModel.type forKey:@"type"];
    [args setObject:value ? @"1" : @"0" forKey:@"publish"];
    
    [super showProgress];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    
	dispatch_async(dispatch_queue_create("request.friends", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
            [super hideProgress];
            
			if (request.error)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot submit information" message:request.error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
                return;
            }
            
            [APP_DLG invalidateMap];
            
            [APP_DLG showAlertWithMessage:@"Sale has been launched successfully. It will take some time before it will be published on the map." title:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
		});
	});
}

-(void)createTemplateAction
{
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:@"make_copy" forKey:@"action"];
    [args setObject:self.garageSaleModel.ID forKey:@"sale_id"];
    [args setObject:@"tpl" forKey:@"type"];
    
    [super showProgress];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    
	dispatch_async(dispatch_queue_create("request.friends", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
            [super hideProgress];
            
			if (request.error)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot submit information" message:request.error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
                return;
            }
            
            NSString *message = [NSString stringWithFormat:@"%@ was added to templates", self.garageSaleModel.name];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
		});
	});
}

#pragma mark - Notification

-(void)transactionNotificationReceived:(NSNotification*)notification
{
    NSMutableDictionary *dic = (NSMutableDictionary*)[notification userInfo];
    if([dic objectForKey:@"error"])
    {
        NSError *error = [dic objectForKey:@"error"];
        [APP_DLG showAlertWithMessage:[error localizedDescription] title:nil];
    }
    else
    {
        [self publishSale:YES];
    }
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:NOTIFICATION_PURCHASE];
    _launchButton.enabled = YES;
    [_activityIndicator stopAnimating];
}

#pragma mark - Events

-(IBAction)editSale_Action:(id)sender
{
    UIViewController *controller = nil;
    NSArray *array = self.navigationController.viewControllers;
    for(UIViewController *ctrl in array)
    {
        if([ctrl isKindOfClass:[ZGarageSaleDetailsViewController class]] || [ctrl isKindOfClass:[ZProductSaleDetailsViewController class]])
        {
            controller = ctrl;
            break;
        }
    }
    
    if(controller)
    {
        [self.navigationController popToViewController:controller animated:YES];
    }
    else if([self.garageSaleModel.type isEqualToString:SALE_TYPE_GARAGE_SALE])
    {
        ZGarageSaleDetailsViewController *ctrl = [ZGarageSaleDetailsViewController controller];
        ctrl.garageSaleModel = self.garageSaleModel;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

-(IBAction)launchSale_Action:(id)sender
{
    if([self.garageSaleModel.publish boolValue])
    {
        [self publishSale:NO];
    }
    else
    {
        _launchButton.enabled = NO;
        [_activityIndicator startAnimating];
        
        [[InAppPurchaseManager sharedManager] purchaseProductWithIdentifier:[ZGarageSaleModel inAppPurchaseIdForSaleType:self.garageSaleModel.type]];
    }
}

-(IBAction)createTemplate_Action:(id)sender
{
    [self createTemplateAction];
}

#pragma mark - Delegate ZSaleImagesTable

-(void)table:(ZSaleImagesTable*)table didSelectImage:(ZSellImageModel*)imageModel
{
    ZSellModuleImageDescriptionViewController *ctrl = [ZSellModuleImageDescriptionViewController controller];
    ctrl.screenState = self.isReadonly ? ImageDescriptionScreenStateDefault : ImageDescriptionScreenStatePreview;
    ctrl.imageModel = imageModel;
    [self.navigationController pushViewController:ctrl animated:YES];
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
                [self.saleImages addObject:model];
            }
            
            [self updateData];
		});
	});
}

@end
