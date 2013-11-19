//
//  ZProductSalePreviewViewController.h
//  ZVeqtr
//
//  Created by Maxim on 4/7/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "ZSaleImagesTable.h"

@class OHAttributedLabel;
@class ZGarageSaleModel;

@interface ZProductSalePreviewViewController : ZSuperViewController<ZSaleImagesTableDelegate>
{
       __weak IBOutlet UIActivityIndicatorView *_activityIndicator;
    __weak IBOutlet UIBarButtonItem *_launchButton;
    __weak IBOutlet OHAttributedLabel	*_linkLabel;
}

@property (nonatomic, retain) ZGarageSaleModel *garageSaleModel;
@property (nonatomic, assign) BOOL isReadonly;

@end
