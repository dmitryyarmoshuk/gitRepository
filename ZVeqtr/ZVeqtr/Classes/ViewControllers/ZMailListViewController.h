//
//  ZMailListViewController.h
//  ZVeqtr
//
//  Created by Maxim on 2/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"


@interface ZMailListViewController : ZSuperViewController<UITableViewDataSource, UITableViewDelegate>


-(id)initWithPersonId:(NSString*)personId;

-(id)initWithPersonId:(NSString*)personId hashtag:(NSString*)hashtag;

@end
