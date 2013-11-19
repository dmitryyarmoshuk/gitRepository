//
//  TimeFilterViewController.m
//  Peek
//
//  Created by Pavel on 16.09.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import "TimeFilterViewController.h"
#import "ZUserModel.h"
#import "ASIFormDataRequest.h"
#import "ZDateComponents.h"


@interface TimeFilterViewController ()
<UIAlertViewDelegate>
@property (nonatomic, retain) IBOutlet UIView	*viewTimeFilter;
@property (nonatomic, retain) IBOutlet UIView	*viewTimeSince;
@property (nonatomic, retain) IBOutlet UIView	*viewTimeRange;

@property (nonatomic, retain) IBOutlet UIPickerView *timeFilterPickerView;
@property (nonatomic, retain) IBOutlet UIDatePicker *pickerTimeSince;
@property (nonatomic, retain) IBOutlet UIDatePicker *pickerTimeRangeTo;
@property (nonatomic, retain) IBOutlet UIDatePicker *pickerTimeRangeFrom;

@property (nonatomic, retain) IBOutlet UISegmentedControl	*segModeSelector;
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segFromToDateSelector;
@end


typedef enum : NSUInteger {
	TFSectionHours,
	TFSectionDays,
	TFSectionMonths,
	TFSectionYears,
	TFSectionCOUNT
} TFSection;


#pragma mark -

@implementation TimeFilterViewController

- (void)releaseOutlets {
	[super releaseOutlets];
	self.viewTimeFilter = nil;
	self.viewTimeSince = nil;
	self.viewTimeRange = nil;
}

- (void)dealloc {
	self.userModel = nil;
	[super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Time Filter";
	
	[super presentBackBarButtonItem];
	[super presentSaveBarButtonItem];
	

	const CGFloat y = CGRectGetMaxY(self.segModeSelector.frame);
	const CGFloat w = self.view.bounds.size.width;
	const CGFloat h = CGRectGetMaxY(self.view.bounds) - y;
	const CGRect invFrame = CGRectMake(0, y, w, h);
	for (UIView *v in [self allSubcontainers]) {
		v.frame = invFrame;
		[self.view addSubview:v];
	}
	
	[self selectFromToDateSection:0 animated:NO];
	
	self.viewTimeFilter.hidden = NO;
	self.viewTimeSince.hidden = YES;
	self.viewTimeRange.hidden = YES;
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.navigationController.navigationBarHidden) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
	
	[self applyDateComponents:self.userModel.dateComponents animated:NO];
}

- (NSArray *)allSubcontainers {
	return @[self.viewTimeFilter, self.viewTimeSince, self.viewTimeRange];
}

#pragma mark - Actions

- (IBAction)actSelectSection:(UISegmentedControl *)sender {
	[self selectSection:sender.selectedSegmentIndex];
}

- (void)selectSection:(TimeFilter)sect {
	self.segModeSelector.selectedSegmentIndex = sect;
	NSUInteger i=0;
	for (UIView *v in [self allSubcontainers]) {
		v.hidden = (sect != i++);
	}
}

- (IBAction)actSelectFromToDate:(UISegmentedControl *)sender {
	[self selectFromToDateSection:sender.selectedSegmentIndex animated:YES];
}

- (void)selectFromToDateSection:(NSUInteger)sect animated:(BOOL)animated {
	switch (sect) {
		case 0:
			if (self.pickerTimeRangeTo.superview) {
				[UIView transitionFromView:self.pickerTimeRangeTo
									toView:self.pickerTimeRangeFrom
								  duration:animated ? 0.3 : -1
								   options:UIViewAnimationOptionTransitionFlipFromLeft
								completion:^(BOOL finished) {
									
								}];
			}
			break;
			
		case 1:
			if (self.pickerTimeRangeFrom.superview) {
				[UIView transitionFromView:self.pickerTimeRangeFrom
									toView:self.pickerTimeRangeTo
								  duration:animated ? 0.3 : -1
								   options:UIViewAnimationOptionTransitionFlipFromRight
								completion:^(BOOL finished) {
									
								}];
			}
			break;
			
		default:
			break;
	}
}

- (void)actSave {
	LLog(@"%@", [self readDateComponents]);

	self.userModel.dateComponents = [self readDateComponents];
	[self.userModel saveDateComponents];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)actGoBack {
	[self actSave];
	return;
	
	ZDateComponents *dc = [self readDateComponents];
	if ([dc isEqual:self.userModel.dateComponents]) {
		[super actGoBack];
		return;
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
													message:@"You have unsaved changes, would you like to save them first?"
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"Save and close", @"Don't save", nil];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	LLog(@"%d", buttonIndex);
	if (buttonIndex == alertView.cancelButtonIndex) {
		return;
	}
	if (buttonIndex == 1) {
		[self actSave];
		return;
		
	}
	
	[super actGoBack];
}


#pragma mark - UIPickerViewDelegate - filter hours/days/months/years

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return TFSectionCOUNT;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

	NSInteger number = 0;
	switch (component) {
		case TFSectionHours:	number = 24;	break;
		case TFSectionDays:		number = 30;	break;
		case TFSectionMonths:	number = 12;	break;
		case TFSectionYears:	number = 5;		break;
	}
	
	return number;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	return [NSString stringWithFormat:@"%d", row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
}


#pragma mark - 

- (void)applyDateComponents:(ZDateComponents *)components  animated:(BOOL)animated {
	
	[self.timeFilterPickerView selectRow:components.hours  inComponent:TFSectionHours  animated:animated];
	[self.timeFilterPickerView selectRow:components.days   inComponent:TFSectionDays   animated:animated];
	[self.timeFilterPickerView selectRow:components.months inComponent:TFSectionMonths animated:animated];
	[self.timeFilterPickerView selectRow:components.years  inComponent:TFSectionYears  animated:animated];
	
	[self.pickerTimeSince setDate:components.dateSince ? components.dateSince : [NSDate date] animated:animated];
	[self.pickerTimeRangeFrom setDate:components.dateRangeFrom ? components.dateRangeFrom : [NSDate date] animated:animated];
	[self.pickerTimeRangeTo setDate:components.dateRangeTo ? components.dateRangeTo : [NSDate date] animated:animated];
	
	NSUInteger n = components.activeTimeFilter < 3 ? components.activeTimeFilter : 0;
	[self selectSection:n];
}

- (ZDateComponents *)readDateComponents {
	
	ZDateComponents *components = [ZDateComponents new];
	
	components.hours	= [self.timeFilterPickerView selectedRowInComponent:TFSectionHours];
	components.days		= [self.timeFilterPickerView selectedRowInComponent:TFSectionDays];
	components.months	= [self.timeFilterPickerView selectedRowInComponent:TFSectionMonths];
	components.years	= [self.timeFilterPickerView selectedRowInComponent:TFSectionYears];
	components.dateSince		= self.pickerTimeSince.date;
	components.dateRangeFrom	= self.pickerTimeRangeFrom.date;
	components.dateRangeTo		= self.pickerTimeRangeTo.date;
	components.activeTimeFilter = self.segModeSelector.selectedSegmentIndex;

	return components;
}

@end
