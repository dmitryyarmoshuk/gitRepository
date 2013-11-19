//
//  ZBaseSaleDetailsViewController.h
//  ZVeqtr
//
//  Created by Maxim on 4/7/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "ZGarageSaleModel.h"
#import "ZGarageSaleDropPinViewController.h"

@interface ZBaseSaleDetailsViewController : ZSuperViewController<UITextFieldDelegate, ZGarageSaleDropPinViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) ZGarageSaleModel *garageSaleModel;

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIView *dateView;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *dateTitleItem;

@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, assign) CLLocation *locationCoordinates;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *publish;

@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@property (nonatomic, retain) UITextField *currentResponder;

@property (nonatomic, assign) int commonSectionInitialIndex;

-(void)updateData;
-(void)finishEditing;

@end
