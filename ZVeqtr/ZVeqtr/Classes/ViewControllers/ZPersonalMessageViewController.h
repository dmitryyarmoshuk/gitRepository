//
//  ZPersonalMessageViewController.h
//  ZVeqtr
//
//  Created by Maxim on 3/8/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSuperViewController.h"
#import "NewMessageViewController.h"

@class ZUserModel;
@class ZPersonModel;

@interface ZPersonalMessageViewController : ZSuperViewController
<NewMessageViewControllerDelegate>
{
	BOOL updatedPosition;
    BOOL _userCoordinateMode;
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, retain) ZPersonModel  *personModel;
@property (nonatomic, retain) ZUserModel	*userModel;
@property (nonatomic, retain) UIViewController *previousController;

- (void)invalidateMap;

-(void)showPinOnCoordinate:(CLLocationCoordinate2D)coordinate;

@end
