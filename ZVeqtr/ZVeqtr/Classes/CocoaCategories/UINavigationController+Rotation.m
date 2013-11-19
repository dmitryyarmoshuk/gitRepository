//
//  UINavigationController+Rotation.m
//  ZVeqtr
//
//  Created by Maxim on 3/21/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "UINavigationController+Rotation.h"
#import "ZCommentsListVC.h"

@implementation UINavigationController (Rotation)


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[self.viewControllers lastObject] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

-(BOOL)shouldAutorotate
{
    UIViewController *lastController = [self.viewControllers lastObject];
    if([lastController isKindOfClass:[ZCommentsListVC class]])
    {
        return YES;
    }
    
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    UIViewController *lastController = [self.viewControllers lastObject];
    if([lastController isKindOfClass:[ZCommentsListVC class]])
    {
        return [lastController supportedInterfaceOrientations];
    }
    
    return UIInterfaceOrientationMaskPortrait;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end

