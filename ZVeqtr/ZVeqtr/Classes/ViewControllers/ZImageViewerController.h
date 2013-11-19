//
//  ZImageViewerController.h
//  ZVeqtr
//
//  Created by Maxim on 2/5/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "EGOImageView.h"


@interface ZImageViewerController : ZSuperViewController<EGOImageViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, retain) NSURL *imageUrl;

@end
