//
//  ZMessageInDetailVC.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/24/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"

@class EGOImageView;
@class ZMailDataModel;
@class ZUserModel;

@protocol ZMessageInDetailVCDelegate;

@interface ZMessageInDetailVC : ZSuperViewController<UIGestureRecognizerDelegate>
{}

@property (nonatomic, retain) ZMailDataModel	*mailModel;
@property (nonatomic, retain) ZUserModel		*userModel;
@property (nonatomic, assign) id<ZMessageInDetailVCDelegate> delegate;

- (void)reloadData;

@end

@protocol ZMessageInDetailVCDelegate <NSObject>
@required
-(void)controller:(ZMessageInDetailVC*)controller shouldLegitPlace:(BOOL)shouldLegitPlace;

@end