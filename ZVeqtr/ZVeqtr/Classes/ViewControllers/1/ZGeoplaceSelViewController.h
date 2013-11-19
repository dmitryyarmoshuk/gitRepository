//
//  ZGeoplaceSelViewController.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/30/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"

@protocol ZGeoplaceSelViewControllerDelegate;

@interface ZGeoplaceSelViewController : ZSuperViewController
<UITableViewDataSource, UITableViewDelegate>
{}
@property (nonatomic, retain) NSArray *allGeoplaces;
@property (nonatomic, retain) NSString	*message;
@property (nonatomic, retain) NSString	*textInfo;
@property (nonatomic, assign) id<ZGeoplaceSelViewControllerDelegate> delegate;
@end


@protocol ZGeoplaceSelViewControllerDelegate <NSObject>
@required
- (void)geoplaceSelViewController:(ZGeoplaceSelViewController *)geoplaceSelViewController didSelectZipPlace:(NSDictionary *)dictZipPlace;
@optional
- (void)geoplaceSelViewControllerDidCancel:(ZGeoplaceSelViewController *)geoplaceSelViewController;
@end
