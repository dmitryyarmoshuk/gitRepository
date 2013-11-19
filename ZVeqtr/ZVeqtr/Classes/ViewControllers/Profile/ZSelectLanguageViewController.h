//
//  ZSelectLanguageViewController.h
//  ZVeqtr
//
//  Created by Maxim on 3/11/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"

@protocol ZSelectLanguageViewControllerDelegate;

@interface ZSelectLanguageViewController : ZSuperViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<ZSelectLanguageViewControllerDelegate> delegate;

-(id)initWithLanguage:(NSString*)language;

@end

@protocol ZSelectLanguageViewControllerDelegate <NSObject>
@required
-(void)controller:(ZSelectLanguageViewController*)sender didSelectLanguage:(NSString*)language;

@end