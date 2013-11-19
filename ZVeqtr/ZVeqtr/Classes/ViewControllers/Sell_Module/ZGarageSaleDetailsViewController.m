//
//  ZGarageSaleDetailsViewController.m
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZGarageSaleDetailsViewController.h"

#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "TextInputCell.h"
#import "ZSellModuleAddImageViewController.h"

@interface ZGarageSaleDetailsViewController ()

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *saleDate;

@end

@implementation ZGarageSaleDetailsViewController

enum {
	kSectionName,
    kSectionDate,
    kSectionCounts
};

- (void)dealloc
{
    self.name = nil;
    self.saleDate = nil;
    
	[super dealloc];
}

- (void)releaseOutlets
{
	[super releaseOutlets];
}

- (void)viewDidLoad
{
    self.commonSectionInitialIndex = kSectionCounts;
    
    [super viewDidLoad];
}

-(void)updateData
{
    [super updateData];
    
    self.name = self.garageSaleModel.name;
    self.saleDate = self.garageSaleModel.startTime;
    
    [self.table reloadData];
}

-(BOOL)checkSale
{
    if(!self.name || [self.name isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation" message:@"Name field couldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    
    
    NSTimeInterval saleInterval = [self.endTime timeIntervalSinceDate:self.startTime];
    if(saleInterval < 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation" message:@"Start time can't be less then End time" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    
    if(saleInterval > 60 * 60 * 24)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation" message:@"Time interval for sale can't longer than 24 hours" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    
    /*
    if(!self.startTime)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation" message:@"Start time field couldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    
    if(!self.endTime)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation" message:@"End time field couldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    
    if(!self.location || [self.location isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation" message:@"Location field couldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    */
    
    if(!self.locationCoordinates)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation" message:@"Coordintates field couldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    
    /*
    if(!self.description || [self.description isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation" message:@"Description field couldn't be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    */
    
    return YES;
}

#pragma mark - Events

- (IBAction)save_Action
{
    [self finishEditing];
    if(![self checkSale])
    {
        return;
    }
    
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    if(self.garageSaleModel.ID == nil)
    {
        [args setObject:@"add" forKey:@"action"];
    }
    else
    {
        [args setObject:@"update" forKey:@"action"];
        [args setObject:self.garageSaleModel.ID forKey:@"sale_id"];
    }
    
    [args setObject:@"sale" forKey:@"type"];
    [args setObject:self.publish forKey:@"publish"];
    
    if(self.name)
        [args setObject:self.name forKey:@"title"];
    
    if(self.description)
        [args setObject:self.description forKey:@"description"];
    
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:self.saleDate];
    
    if(self.startTime)
    {
        NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:self.startTime];
        
        [timeComponents setYear:[dateComponents year]];
        [timeComponents setMonth:[dateComponents month]];
        [timeComponents setDay:[dateComponents day]];
        
        self.startTime = [calendar dateFromComponents:timeComponents];
        [args setObject:[self.dateFormatter stringFromDate:self.startTime] forKey:@"date_start"];
    }
    if(self.endTime)
    {
        NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:self.endTime];
        [timeComponents setYear:[dateComponents year]];
        [timeComponents setMonth:[dateComponents month]];
        [timeComponents setDay:[dateComponents day]];
        
        self.endTime = [calendar dateFromComponents:timeComponents];
        
        [args setObject:[self.dateFormatter stringFromDate:self.endTime] forKey:@"date_end"];
    }
    if(self.locationCoordinates)
    {
        [args setObject:[NSNumber numberWithFloat:self.locationCoordinates.coordinate.latitude] forKey:@"lat"];
        [args setObject:[NSNumber numberWithFloat:self.locationCoordinates.coordinate.longitude]  forKey:@"lon"];
    }
    
    if(self.location)
        [args setObject:self.location forKey:@"location"];
    
    [super showProgress];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    
	dispatch_async(dispatch_queue_create("request.friends", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
            [super hideProgress];
			
            if (request.error)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot submit information" message:request.error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
                return;
            }
            
            NSString *responseString = [request responseString];
            NSLog(@"%@", responseString);
            
            self.garageSaleModel.ID = responseString;
            [self.garageSaleModel applyDictionary:args updateId:NO];
            
            [APP_DLG invalidateMap];
            
            ZSellModuleAddImageViewController *ctrl = [ZSellModuleAddImageViewController controller];
            ctrl.garageSaleModel = self.garageSaleModel;
            [self.navigationController pushViewController:ctrl animated:YES];
		});
	});
}

- (IBAction)datePicker_DoneAction
{
    if(self.dateView.hidden)
        return;
    
    if(self.datePicker.tag == 1)
    {
        self.saleDate = self.datePicker.date;
    }
    else if(self.datePicker.tag == 2)
    {
        self.startTime = self.datePicker.date;
    }
    else if(self.datePicker.tag == 3)
    {
        self.endTime = self.datePicker.date;
    }
    
    self.dateView.hidden = YES;
    self.table.frame = self.view.bounds;
    
    [self.table reloadData];
}

#pragma mark - Delegate UITextField

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == kSectionName)
    {
        self.name = textField.text;
    }
    
    [super textFieldDidEndEditing:textField];
}

#pragma mark - Delegate/Data source Table View

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case kSectionName:
        {
            return @"Name of sale:";
        }
        case kSectionDate:
        {
            return @"Date:";
        }
            break;
        default:
            return [super tableView:tableView titleForHeaderInSection:section];
            break;
    }
    
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kSectionName:
        {
            return 1;
        }
        case kSectionDate:
            return 3;
        default:
            return [super tableView:tableView numberOfRowsInSection:section];
    }
    
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case kSectionName:
        {
            static NSString *cellID = @"kSectionName";
            
            TextInputCell *cell = (TextInputCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (!cell)
            {
                cell = [TextInputCell cell];
                cell.textField.placeholder = @"Required";
                cell.textField.delegate = self;
                cell.textField.tag = kSectionName;
            }
            
            cell.textField.text = self.name;
                
            return cell;
        }
            break;
        case kSectionDate:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kSectionDate"];
            if (! cell) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"kSectionDate"] autorelease];
                
                UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
                if (font) {
                    cell.textLabel.font = font;
                }
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            if(indexPath.row == 0)
            {
                cell.textLabel.text = @"Date";
                if(self.saleDate)
                {
                    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.saleDate];
                }
                else
                    cell.detailTextLabel.text = @"";
            }
            else if(indexPath.row == 1)
            {
                cell.textLabel.text = @"Start Time";
                if(self.startTime)
                {
                    [self.dateFormatter setDateFormat:@"HH:mm':00'"];
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.startTime];
                }
                else
                    cell.detailTextLabel.text = @"";
            }
            else if(indexPath.row == 2)
            {
                cell.textLabel.text = @"End Time";
                if(self.endTime)
                {
                    [self.dateFormatter setDateFormat:@"HH:mm':00'"];
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.endTime];
                }
                else
                    cell.detailTextLabel.text = @"";
            }
            
            return cell;
        }
            break;
        default:
        {
            return [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
            
            break;
    }
    
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
    
    [self finishEditing];
    
    switch (indexPath.section) {
        case kSectionName:
        {
        }
            break;
        case kSectionDate:
        {
            // cell.textLabel.text = @"Service";
            
            self.dateView.frame = CGRectMake(0, self.view.frame.size.height - self.dateView.frame.size.height, self.dateView.frame.size.width, self.dateView.frame.size.height);
            
            self.dateView.hidden = NO;
            
            CGRect frame = self.table.frame;
            frame.size.height = self.view.frame.size.height - self.dateView.frame.size.height;
            self.table.frame = frame;
            
            [self.table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
            
            if(indexPath.row == 0)
            {
                if(self.saleDate)
                    [self.datePicker setDate:self.saleDate];
                else
                    [self.datePicker setDate:[NSDate date]];
                
                self.datePicker.tag = 1;
                self.datePicker.datePickerMode = UIDatePickerModeDate;
                self.dateTitleItem.title = @"Date";
            }
            else if(indexPath.row == 1)
            {
                if(self.startTime)
                    [self.datePicker setDate:self.startTime];
                else
                    [self.datePicker setDate:[NSDate date]];
                
                self.datePicker.tag = 2;
                self.datePicker.datePickerMode = UIDatePickerModeTime;
                self.dateTitleItem.title = @"Start Time";
            }
            else if(indexPath.row == 2)
            {
                if(self.endTime)
                    [self.datePicker setDate:self.endTime];
                else
                    [self.datePicker setDate:[NSDate date]];
                self.datePicker.tag = 3;
                self.datePicker.datePickerMode = UIDatePickerModeTime;
                self.dateTitleItem.title = @"End Time";
            }
        }
            break;

        default:
        {
            return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
            
            break;
    }
}

@end
