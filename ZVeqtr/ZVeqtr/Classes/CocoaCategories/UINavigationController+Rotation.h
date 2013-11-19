//
//  UINavigationController+Rotation.h
//  ZVeqtr
//
//  Created by Maxim on 3/21/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Rotation)

-(BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end
