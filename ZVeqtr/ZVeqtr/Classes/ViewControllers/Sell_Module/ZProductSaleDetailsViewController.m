//
//  ZProductSaleDetailsViewController.m
//  ZVeqtr
//
//  Created by Maxim on 4/7/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZProductSaleDetailsViewController.h"

#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "TextInputCell.h"
#import "ZSellModuleAddImageViewController.h"
#import "ZThumbnailPictureViewController.h"


@interface ZProductSaleDetailsViewController ()

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *company;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *tag1;
@property (nonatomic, retain) NSString *tag2;
@property (nonatomic, retain) NSString *tag3;
@property (nonatomic, retain) NSString *tag4;
@property (nonatomic, retain) NSString *tag5;

@end

@implementation ZProductSaleDetailsViewController

enum {
	kSectionName,
	kSectionCompany,
    kSectionThumbnail,
    kSectionWebsite,
    kSectionPhone,
    kSectionHashtags,
    kSectionDate,
    
    kSectionCounts
};

- (void)dealloc
{
	[super dealloc];
}

- (void)releaseOutlets
{
	[super releaseOutlets];
}

- (void)viewDidLoad
{
    self.commonSectionInitialIndex = kSectionCounts;
    self.garageSaleModel.thumbnailImage = nil;
    
    [super viewDidLoad];
}

-(void)updateData
{
    [super updateData];
    
    self.name = self.garageSaleModel.name;
    self.company = self.garageSaleModel.company;
    self.tag1 = self.garageSaleModel.tag1;
    self.tag2 = self.garageSaleModel.tag2;
    self.tag3 = self.garageSaleModel.tag3;
    self.tag4 = self.garageSaleModel.tag4;
    self.tag5 = self.garageSaleModel.tag5;
    self.website = self.garageSaleModel.website;
    self.phone = self.garageSaleModel.phone;
    
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
    
    [args setObject:self.garageSaleModel.type forKey:@"type"];
    [args setObject:self.publish forKey:@"publish"];
    
    
    if(self.name)
        [args setObject:self.name forKey:@"title"];
    if(self.company)
        [args setObject:self.company forKey:@"company"];
    if(self.website)
        [args setObject:self.website forKey:@"website"];
    if(self.phone)
        [args setObject:self.phone forKey:@"phone"];
    if(self.tag1)
        [args setObject:self.tag1 forKey:@"tag1"];
    if(self.tag2)
        [args setObject:self.tag2 forKey:@"tag2"];
    if(self.tag3)
        [args setObject:self.tag3 forKey:@"tag3"];
    if(self.tag4)
        [args setObject:self.tag4 forKey:@"tag4"];
    if(self.tag5)
        [args setObject:self.tag5 forKey:@"tag5"];
    
    if(self.description)
        [args setObject:self.description forKey:@"description"];
    if(self.startTime)
        [args setObject:[self.dateFormatter stringFromDate:self.startTime] forKey:@"date_start"];
    if(self.endTime)
        [args setObject:[self.dateFormatter stringFromDate:self.endTime] forKey:@"date_end"];
    
    if(self.locationCoordinates)
    {
        [args setObject:[NSNumber numberWithFloat:self.locationCoordinates.coordinate.latitude] forKey:@"lat"];
        [args setObject:[NSNumber numberWithFloat:self.locationCoordinates.coordinate.longitude]  forKey:@"lon"];
    }
    
    if(self.location)
        [args setObject:self.location forKey:@"location"];
    
    [super showProgress];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    
    if(self.garageSaleModel.thumbnailImage)
    {
        [request setFile:[self.garageSaleModel pathPicture] forKey:@"image"];
    }
    
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
            
            self.garageSaleModel.ID = responseString;// [ZGarageSaleModel modelWithID:responseString];
            [self.garageSaleModel applyDictionary:args updateId:NO];
            
            [APP_DLG invalidateMap];
            
            ZSellModuleAddImageViewController *ctrl = [ZSellModuleAddImageViewController controller];
            ctrl.garageSaleModel = self.garageSaleModel;
            [self.navigationController pushViewController:ctrl animated:YES];
		});
	});
}

#pragma mark - Delegate ZTumbnailPictureViewController

-(void)controller:(ZThumbnailPictureViewController*)controller shouldSaveImage:(UIImage*)image
{
    self.garageSaleModel.thumbnailImage = image;
}

#pragma mark - Delegate UITextField

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == kSectionName)
    {
        self.name = textField.text;
    }
    else if(textField.tag == kSectionCompany)
    {
        self.company = textField.text;
    }
    else if(textField.tag == kSectionWebsite)
    {
        self.website = textField.text;
    }
    else if(textField.tag == kSectionPhone)
    {
        self.phone = textField.text;
    }
    else if(textField.tag == kSectionHashtags)
    {
        if([textField.placeholder isEqualToString:@"Hashtag 1"])
        {
            self.tag1 = textField.text;
        }
        else if([textField.placeholder isEqualToString:@"Hashtag 2"])
        {
            self.tag2 = textField.text;
        }
        else if([textField.placeholder isEqualToString:@"Hashtag 3"])
        {
            self.tag3 = textField.text;
        }
        else if([textField.placeholder isEqualToString:@"Hashtag 4"])
        {
            self.tag4 = textField.text;
        }
        else if([textField.placeholder isEqualToString:@"Hashtag 5"])
        {
            self.tag5 = textField.text;
        }
    }
    
    [super textFieldDidEndEditing:textField];
}

#pragma mark - Delegate/Data source Table View

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kSectionName:
        {
            if([self.garageSaleModel.type isEqualToString:SALE_TYPE_PRODUCT])
                return @"Name of product:";
            else if([self.garageSaleModel.type isEqualToString:SALE_TYPE_SERVICE])
                return @"Name of service:";
            else
                return @"";
        }
            break;
        case kSectionCompany:
        {
            return @"Company:";
        }
            break;
        case kSectionThumbnail:
        {
            return @"Thumbnail:";
        }
            break;
        case kSectionWebsite:
        {
            return @"Website:";
        }
            break;
        case kSectionPhone:
        {
            return @"Phone:";
        }
            break;
        case kSectionHashtags:
        {
            return @"Hashtags:";
        }
            break;
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
            break;
        case kSectionCompany:
        {
            return 1;
        }
            break;
        case kSectionThumbnail:
        case kSectionWebsite:
        case kSectionPhone:
        {
            return 1;
        }
            break;
        case kSectionHashtags:
        {
            return 6;
        }
            break;
        case kSectionDate:
            return 2;
        default:
            return [super tableView:tableView numberOfRowsInSection:section];
            break;
    }
    
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
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
        case kSectionCompany:
        {
            static NSString *cellID = @"kSectionCompany";
            
            TextInputCell *cell = (TextInputCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (!cell)
            {
                cell = [TextInputCell cell];
                cell.textField.placeholder = @"Company";
                cell.textField.delegate = self;
                cell.textField.tag = kSectionCompany;
            }
            
            cell.textField.text = self.company;
            
            return cell;
        }
            break;
        case kSectionThumbnail:
        {
            static NSString *cellID = @"kSectionThumbnail";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (! cell) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            cell.textLabel.text = @"Thumbnail";
            
            return cell;
        }
            break;
        case kSectionWebsite:
        {
            static NSString *cellID = @"kSectionWebsite";
            
            TextInputCell *cell = (TextInputCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (!cell)
            {
                cell = [TextInputCell cell];
                cell.textField.placeholder = @"Website";
                cell.textField.delegate = self;
                cell.textField.tag = kSectionWebsite;
            }
            
            cell.textField.text = self.website;
            
            return cell;
        }
            break;
        case kSectionPhone:
        {
            static NSString *cellID = @"kSectionPhone";
            
            TextInputCell *cell = (TextInputCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (!cell)
            {
                cell = [TextInputCell cell];
                cell.textField.placeholder = @"Phone";
                cell.textField.delegate = self;
                cell.textField.tag = kSectionPhone;
            }
            
            cell.textField.text = self.phone;
            
            return cell;
        }
            break;
        case kSectionHashtags:
        {
            static NSString *cellID = @"kSectionHashtags";
            
            TextInputCell *cell = (TextInputCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (!cell)
            {
                cell = [TextInputCell cell];
                cell.textField.placeholder = [NSString stringWithFormat:@"Hashtag %d", indexPath.row+1];
                cell.textField.delegate = self;
                cell.textField.tag = kSectionHashtags;
            }
            
            switch (indexPath.row+1) {
                case 1:
                    cell.textField.text = self.tag1;
                    break;
                case 2:
                    cell.textField.text = self.tag2;
                    break;
                case 3:
                    cell.textField.text = self.tag3;
                    break;
                case 4:
                    cell.textField.text = self.tag4;
                    break;
                case 5:
                    cell.textField.text = self.tag5;
                    break;
                    
                default:
                    break;
            }
            
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
                cell.textLabel.text = @"Start Time";
                if(self.startTime)
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.startTime];
                else
                    cell.detailTextLabel.text = @"";
            }
            else if(indexPath.row == 1)
            {
                cell.textLabel.text = @"End Time";
                if(self.endTime)
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.endTime];
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
        case kSectionCompany:
        {
        }
            break;
        case kSectionThumbnail:
        {
            ZThumbnailPictureViewController *ctrl = [ZThumbnailPictureViewController controller];
            ctrl.garageSaleModel = self.garageSaleModel;
            ctrl.delegate = self;
            [self.navigationController pushViewController:ctrl animated:YES];
        }
            break;
        case kSectionWebsite:
        {
        }
            break;
        case kSectionPhone:
        {
        }
            break;
        case kSectionHashtags:
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
                if(self.startTime)
                    [self.datePicker setDate:self.startTime];
                else
                    [self.datePicker setDate:[NSDate date]];
                
                self.datePicker.tag = 1;
                self.dateTitleItem.title = @"Start Time";
            }
            else if(indexPath.row == 1)
            {
                if(self.endTime)
                    [self.datePicker setDate:self.endTime];
                else
                    [self.datePicker setDate:[NSDate date]];
                self.datePicker.tag = 2;
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
