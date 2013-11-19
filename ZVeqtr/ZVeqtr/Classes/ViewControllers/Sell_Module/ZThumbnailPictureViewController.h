//
//  ZThumbnailPictureViewController.h
//  ZVeqtr
//
//  Created by Maxim on 4/24/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "ZGarageSaleModel.h"
#import "EGOImageView.h"

@protocol ZThumbnailPictureViewControllerDelegate;

@interface ZThumbnailPictureViewController : ZSuperViewController<EGOImageViewDelegate>

@property (nonatomic, retain) ZGarageSaleModel *garageSaleModel;

@property (nonatomic, assign) id<ZThumbnailPictureViewControllerDelegate> delegate;

@end

@protocol ZThumbnailPictureViewControllerDelegate <NSObject>

-(void)controller:(ZThumbnailPictureViewController*)controller shouldSaveImage:(UIImage*)image;

@end
