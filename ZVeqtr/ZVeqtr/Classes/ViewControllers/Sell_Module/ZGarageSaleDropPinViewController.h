//
//  ZGarageSaleDropPinViewController.h
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "ZGarageSaleModel.h"


@protocol ZGarageSaleDropPinViewControllerDelegate;

@interface ZGarageSaleDropPinViewController : ZSuperViewController

@property (nonatomic, assign) id<ZGarageSaleDropPinViewControllerDelegate> delegate;
@property (nonatomic, assign) CLLocation *location;
@property (nonatomic, retain) ZGarageSaleModel *saleModel;

@end

@protocol ZGarageSaleDropPinViewControllerDelegate <NSObject>

-(void)controller:(ZGarageSaleDropPinViewController*)controller didSelectLocation:(CLLocation*)location;

@end
