//
//  ZBaseSaleDetailsViewController.m
//  ZVeqtr
//
//  Created by Maxim on 4/7/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZBaseSaleDetailsViewController.h"
#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "TextInputCell.h"
#import "ZSellModuleAddImageViewController.h"

@interface ZBaseSaleDetailsViewController ()

@end

@implementation ZBaseSaleDetailsViewController

enum {
    kSectionLocation,
    kSectionPickOnMap,
    kSectionDescription,
    
    kCommonSectionCounts
};

- (void)dealloc
{
    self.dateFormatter = nil;
    self.garageSaleModel = nil;
    self.startTime = nil;
    self.endTime = nil;
    self.location = nil;
    self.description = nil;
    self.currentResponder = nil;
    
	[super dealloc];
}

- (void)releaseOutlets
{
	[super releaseOutlets];
	self.table = nil;
    self.dateView = nil;
    self.datePicker = nil;
    self.dateTitleItem = nil;
}

-(void)loadView
{
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"ZBaseSaleDetailsViewController" owner:self options:nil] objectAtIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self presentBackBarButtonItem];
    
    self.title = self.garageSaleModel.typeName;
    
    self.dateFormatter = [[NSDateFormatter new] autorelease];
    //self.dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    //self.dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    
    self.dateView.hidden = YES;
    
    //self.datePicker.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-7*60*60];
    
    [self updateData];
}

-(void)updateData
{
    self.description = self.garageSaleModel.description;
    self.location = self.garageSaleModel.location;
    self.startTime = self.garageSaleModel.startTime;
    self.endTime = self.garageSaleModel.endTime;
    self.locationCoordinates = self.garageSaleModel.locationCoordinate;
    self.publish = self.garageSaleModel.ID == nil ? @"0" : self.garageSaleModel.publish;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
    [self subscribeForKeyboardNotifications];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self unsubscribeFromKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)finishEditing
{
    [self.currentResponder resignFirstResponder];
    [self datePicker_DoneAction];
}

#pragma mark - Events

- (IBAction)save_Action
{
    //for overriding
}

- (IBAction)datePicker_DoneAction
{
    if(self.dateView.hidden)
        return;
    
    if(self.datePicker.tag == 1)
    {
        self.startTime = self.datePicker.date;
    }
    else if(self.datePicker.tag == 2)
    {
        self.endTime = self.datePicker.date;
    }
    
    self.dateView.hidden = YES;
    self.table.frame = self.view.bounds;
    
    [self.table reloadData];
}

- (IBAction)datePicker_CancelAction
{
    self.dateView.hidden = YES;
    self.table.frame = self.view.bounds;
}

#pragma mark - Delegate ZGarageSaleDropPinViewController

-(void)controller:(ZGarageSaleDropPinViewController*)controller didSelectLocation:(CLLocation*)location
{
    self.locationCoordinates = location;
    [self.table reloadData];
}

#pragma mark - Delegate UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.currentResponder = textField;
    if(!self.dateView.hidden)
    {
        self.table.frame = self.view.bounds;
        self.dateView.hidden = YES;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == kSectionLocation + self.commonSectionInitialIndex)
    {
        self.location = textField.text;
    }
    else if(textField.tag == kSectionDescription + self.commonSectionInitialIndex)
    {
        self.description = textField.text;
    }
}

#pragma mark - Delegate/Data source Table View

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
	//	Example:
	//	NSNumber *duration = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	//	NSValue *valFrame = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
	//	CGRect kbFrame = [valFrame CGRectValue];
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration
					 animations:^{
                         CGRect frame = self.table.frame;
                         frame.size.height -= UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ?  keyboardRect.size.height : keyboardRect.size.width;
                         self.table.frame = frame;
					 }
                     completion:^(BOOL finished)
     {
         [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.currentResponder.tag] atScrollPosition:UITableViewScrollPositionNone animated:YES];
     }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
	[UIView animateWithDuration:animationDuration
					 animations:^{
                         CGRect frame = self.table.frame;
                         frame.size.height += UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ?  keyboardRect.size.height : keyboardRect.size.width;
                         self.table.frame = frame;
					 }];
}

#pragma mark - Delegate/Data source Table View

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section - self.commonSectionInitialIndex)
    {
        case kSectionLocation:
        {
            return @"Location:";
        }
            break;
        case kSectionPickOnMap:
        {
            return @"or Pick on Map:";
        }
            break;
        case kSectionDescription:
        {
            return @"Description:";
        }
            break;
        default:
            break;
    }
    
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return kCommonSectionCounts + self.commonSectionInitialIndex;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
    switch (indexPath.section - self.commonSectionInitialIndex) {
        case kSectionLocation:
        {
            static NSString *cellID = @"TextInputCell";
            TextInputCell *cell = (TextInputCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            if (! cell) {
                cell = [TextInputCell cell];
                cell.textField.placeholder = @"Location";
                cell.textField.delegate = self;
                cell.textField.tag = kSectionLocation + self.commonSectionInitialIndex;
            }
            
            cell.textField.text = self.location;
            
            return cell;
        }
            break;
        case kSectionPickOnMap:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"kSectionTime"];
            if (! cell) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"kSectionTime"] autorelease];
                
                UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
                if (font) {
                    cell.textLabel.font = font;
                }
                
                cell.detailTextLabel.numberOfLines = 0;
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            cell.textLabel.text = @"Coordinates";
            if(self.locationCoordinates)
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", self.locationCoordinates.coordinate.latitude, self.locationCoordinates.coordinate.longitude];
                cell.detailTextLabel.textColor = [UIColor colorWithRed:51.0f/255.0f green:102.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
            }
            else
            {
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                cell.detailTextLabel.text = @"Required";
            }
            
        }
            break;
        case kSectionDescription:
        {
            static NSString *cellID = @"kSectionDescription";
            TextInputCell *cell = (TextInputCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            if (! cell) {
                cell = [TextInputCell cell];
                cell.textField.placeholder = @"Description";
                cell.textField.delegate = self;
                cell.textField.tag = kSectionDescription + self.commonSectionInitialIndex;
            }
            
            cell.textField.text = self.description;
            
            return cell;
        }
            break;
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
    
    [self finishEditing];
    
    switch (indexPath.section - self.commonSectionInitialIndex) {
        case kSectionPickOnMap:
        {
            // cell.textLabel.text = @"Garage Sale";
            ZGarageSaleDropPinViewController *ctrl = [ZGarageSaleDropPinViewController controller];
            ctrl.delegate = self;
            ctrl.location = self.locationCoordinates;
            [self.navigationController pushViewController:ctrl animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
