//
//  ZThisUserProfileVC.m
//  ZVeqtr
//
//  Created by Lee Loo on 10/22/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZThisUserProfileVC.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ZVeqtr.h"
#import "SBJson.h"
#import "EGOImageView.h"
#import "ZPersonModel.h"
#import "ZPersonPostCell.h"
#import "ZMailDataModel.h"
#import "ZCommonRequest.h"
#import "ZLocationModel.h"
#import "EditTextViewController.h"
#import "TextTableViewCell.h"
#import "ZCommentsListVC.h"
#import "ZSmartTextView.h"
#import "ZUserModel.h"

#import "ZMailListViewController.h"
#import "ZUserListViewController.h"

#import "FBSession.h"

enum {
    UsrProfileSectionSettings = 0,
	UsrProfileSectionTemplText = 1,
	//UsrProfileSectionFavoriteLocation,
	UsrProfileSectionPosts = 2,
	UsrProfileSectionHashtags = 3,
	UsrProfileSectionCOUNT
};

enum  {
	kProfilePublic = 0,
	kProfilePrivate = 1
};

@interface ZThisUserProfileVC ()
<UITableViewDataSource, UITableViewDelegate, ZSmartTextViewDelegate, UIActionSheetDelegate, UITextFieldDelegate>
@property (nonatomic, retain) IBOutlet EGOImageView	*picture;
@property (nonatomic, retain) IBOutlet UIImageView	*iconScore;
@property (nonatomic, retain) IBOutlet UIView		*pictureBack;
@property (nonatomic, retain) IBOutlet UILabel		*labPosts;
@property (nonatomic, retain) IBOutlet UILabel		*labFollowing;
@property (nonatomic, retain) IBOutlet UILabel		*labFollowers;
@property (nonatomic, retain) IBOutlet UILabel		*labFriends;
@property (nonatomic, retain) IBOutlet UILabel		*labScore;
@property (nonatomic, retain) IBOutlet UITextField	*tfEmail;
@property (nonatomic, retain) IBOutlet UIButton		*btnTakePicture;
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segmPublicPrivate;
//	sections' headers
@property (nonatomic, retain) IBOutlet UIView		*headerPosts;
@property (nonatomic, retain) IBOutlet UIView		*headerHashtags;
@property (nonatomic, retain) IBOutlet UIView		*headerSettings;
@property (nonatomic, retain) IBOutlet UIView		*headerTemplateText;
@property (nonatomic, retain) IBOutlet UIView		*headerFavorite;
@property (nonatomic, assign) IBOutlet UILabel		*headerTemplateTextLab;
@property (nonatomic, assign) IBOutlet UILabel		*headerFavoriteLab;
@property (nonatomic, assign) IBOutlet UILabel		*headerSettingsLabel;

@property (nonatomic, retain) IBOutlet UITableView	*table;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*spinner;
//
@property (nonatomic, retain) NSArray	*allPosts;
@property (nonatomic, retain) NSArray	*allHashtags;
@property (nonatomic, retain) NSArray	*allFavoriteLocations;
@property (nonatomic, assign) CGRect	frameTextOriginal;
@property (nonatomic, retain) ZPersonPostCell	*controlPersonPostCell;
@property (nonatomic, retain) NSURL		*imageUrlToRemove;

@property (nonatomic, assign) BOOL		isCommentsApnEnabled;
@property (nonatomic, assign) BOOL		isPlaceCommentApnEnabled;
@property (nonatomic, assign) BOOL		isApnEnabled;
@property (nonatomic, assign) BOOL		currentLocationVisible;
@property (nonatomic, assign) BOOL		googleMapVisible;

@property (nonatomic, retain) NSString		*defaultLanguage;
@property (nonatomic, retain) NSString		*fbUsername;

@property (nonatomic, retain) TextTableViewCell		*customTextCell;
@property (nonatomic, assign) BOOL isFacebookEnabled;

@property (nonatomic, retain)   FBSession *fbSession;
@property (nonatomic, retain)   UIImage *fbImage;
@property (nonatomic, assign)   BOOL loadFBImage;

@property (retain, nonatomic) IBOutlet UIImageView *testImageView;


//@property (nonatomic, retain) FBProfilePictureView	*fbPictView; //zsf

@end


#pragma mark -

@implementation ZThisUserProfileVC {
	BOOL hasUnsavedPicture;
}

- (void)dealloc {
	self.allPosts = nil;
	self.allHashtags = nil;
	self.allFavoriteLocations = nil;
	self.userModel = nil;
	self.imageUrlToRemove = nil;
    self.controlPersonPostCell = nil;
    self.customTextCell = nil;
    
    self.fbSession = nil;
    self.fbImage = nil;
    
    [_testImageView release];
	[super dealloc];
}

- (void)releaseOutlets {
	[super releaseOutlets];
	self.picture = nil;
	self.pictureBack = nil;
	self.labPosts = nil;
	self.labFollowing = nil;
	self.labFollowers = nil;
	self.labFriends = nil;
	self.labScore = nil;
	self.tfEmail = nil;
	self.btnTakePicture = nil;
	self.segmPublicPrivate = nil;
	self.headerPosts = nil;
	self.headerHashtags = nil;
	self.headerTemplateText = nil;
	self.headerFavorite = nil;
	self.table = nil;
	self.spinner = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font) {
		_labPosts.font = font;
		_labFollowing.font = font;
		_labFollowers.font = font;
		_labFriends.font = font;
		_labScore.font = font;
		_headerTemplateTextLab.font = font;
		_headerFavoriteLab.font = font;
	}
	
	[self.spinner stopAnimating];
	
	self.pictureBack.layer.masksToBounds = YES;
	self.pictureBack.layer.cornerRadius = 6;
	self.pictureBack.layer.borderColor = [UIColor grayColor].CGColor;
	self.pictureBack.layer.borderWidth = 1;
    self.picture.delegate = self;
	
	self.navigationItem.rightBarButtonItem = [super saveBarButtonItem];
	self.navigationItem.leftBarButtonItem = [super homeBarButtonItem];

	self.controlPersonPostCell = [ZPersonPostCell cell];
    self.customTextCell = [TextTableViewCell cell];
    
	CGRect cellFrame = self.controlPersonPostCell.frame;
	cellFrame.size.width = self.table.frame.size.width;
	self.controlPersonPostCell.frame = cellFrame;
    
    [self runUserSettingsRequestWithUserID:self.userModel.ID];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	[self runPersonProfileRequestWithUserID:self.userModel.ID];
	
	//	load all locations
	self.allFavoriteLocations = self.userModel.allFavouriteLocations;
	
	[self reloadData];
}

#pragma mark -

- (void)reloadData
{
    self.isCommentsApnEnabled = self.userModel.isCommentsApnEnabled;
    self.isPlaceCommentApnEnabled = self.userModel.isPlaceCommentApnEnabled;
    self.isApnEnabled = self.userModel.isApnEnabled;
    self.currentLocationVisible = self.userModel.currentLocationVisible;
    BOOL g = self.userModel.googleMapVisible;
    self.googleMapVisible = self.userModel.googleMapVisible;
    self.defaultLanguage = self.userModel.defaultLanguage;
    self.fbUsername = self.userModel.facebookUsername;
    
	[self.table reloadData];
	
	if (self.userModel.extendedModel) {
		_labPosts.text = self.userModel.extendedModel.postCount;
		_labFollowing.text = self.userModel.extendedModel.follow;
		_labFollowers.text = self.userModel.extendedModel.followers;
		_labFriends.text = self.userModel.extendedModel.friends;
		//	score image and value
		int nscore = [self.userModel.extendedModel.rating intValue];
		NSString *icoName = (nscore <= 0) ? @"ico-profile-Star2.png" : @"ico-profile-Star1.png";
		_iconScore.image = [UIImage imageNamed:icoName];
		_labScore.text = nscore == 0 ? nil : self.userModel.extendedModel.rating;
        self.isFacebookEnabled = self.userModel.facebookUsername != nil && self.userModel.facebookUsername.length > 0;
	}
	else {
		_labPosts.text = nil;
		_labFollowing.text = nil;
		_labFollowers.text = nil;
		_labFriends.text = nil;
		_labScore.text = nil;
		LLog(@"no personModel");
	}
    
	self.tfEmail.text = self.userModel.extendedModel.email;
	
	self.segmPublicPrivate.selectedSegmentIndex = self.userModel.isPublic ? kProfilePublic : kProfilePrivate;
	
//	NSString *name = self.userModel.username ? self.userModel.username : self.userModel.realname;
	self.title = @"You";
	
	UIImage *iuser = self.userModel.image;
	self.picture.placeholderImage = iuser ? iuser : [UIImage imageNamed:@"btn-takepic1-boy.png"];
	if (!hasUnsavedPicture) {
		self.picture.imageURL = [NSURL urlPersonProfileImageWithID:self.userModel.ID];
	}
}

#pragma mark - Actions

- (IBAction)actGoHome
{
    if(self.presenterViewController)
    {
        [self dismissModalViewControllerAnimated:YES];
//        CGRect frame = self.view.frame;
//        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)actSwPrivatePublic:(UISegmentedControl *)sender
{
	[self.view endEditing:YES];
	self.userModel.isPublic = sender.selectedSegmentIndex == kProfilePublic;
}

- (void)actSave
{
	[self.view endEditing:YES];
    [self.userModel saveUser];
	[self runRequestSaveUser];
}

- (IBAction)actTakePicture:(id)sender
{
	[self.view endEditing:YES];
	[super takePicture];
}

- (IBAction)postsButton_Clicked
{
    ZMailListViewController *ctrl = [[[ZMailListViewController alloc] initWithPersonId:self.userModel.ID] autorelease];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)friendsButton_Clicked
{
    ZUserListViewController *ctrl = [[[ZUserListViewController alloc] initAsFriends:self.userModel.ID] autorelease];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)folowersButton_Clicked
{
    ZUserListViewController *ctrl = [[[ZUserListViewController alloc] initAsFolowers:self.userModel.ID] autorelease];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)folowingButton_Clicked
{
    ZUserListViewController *ctrl = [[[ZUserListViewController alloc] initAsFollowing:self.userModel.ID] autorelease];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)callFacebook
{
    //    NSLog(@">>>>Call Facebook_Beg<<<<");
    //  [self loginToFacebook];
   // [self publishFBStream];
    //    NSLog(@">>>>Call Facebook_End<<<<");
}

//	image picker's result handler
- (void)savePicture:(UIImage *)picture {
	
	hasUnsavedPicture = YES;
    NSLog(@"-save pic-1");
	UIImage *image = [picture scaleAndRotate];
	self.userModel.image = image;
    
	if (self.picture.imageURL) {
		self.imageUrlToRemove = self.picture.imageURL;
	}
	self.picture.imageURL = nil;
	self.picture.image = image;
    NSLog(@"-save pic-2");
    
}

#pragma mark - EGOImageView delegate

- (void)imageLoaderDidLoad:(NSNotification*)notification
{
    
}

- (void)imageViewFailedToLoadImage:(EGOImageView*)imageView error:(NSError*)error
{
    
}

#pragma mark - UITextField

-(void)cellSwitchValueChanged:(ZUserSettingBoolCell*)cell
{
    NSIndexPath *indexPath = [self.table indexPathForCell:cell];
    switch (indexPath.row)
    {
        case 0:
        {
            self.isCommentsApnEnabled = cell.switchControl.isOn;
        }
            break;
        case 1:
        {
            self.isPlaceCommentApnEnabled = cell.switchControl.isOn;
        }
            break;
        case 2:
        {
            self.isApnEnabled = cell.switchControl.isOn;
        }
            break;
        case 3:
        {
            self.currentLocationVisible = cell.switchControl.isOn;
        }
            break;
        case 4:
        {
            self.googleMapVisible = cell.switchControl.isOn;
        }
            break;
    }
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	textField.text = [textField.text trimWhitespace];
	[textField performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField == self.tfEmail) {
		self.tfEmail.backgroundColor = [UIColor whiteColor];
		[UIView animateWithDuration:0.3
						 animations:^{
							 self.frameTextOriginal = self.tfEmail.frame;
							 self.tfEmail.frame = self.tfEmail.superview.bounds;
						 }];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField == self.tfEmail) {
		[UIView animateWithDuration:0.3
						 animations:^{
							 self.tfEmail.frame = self.frameTextOriginal;
						 }
						 completion:^(BOOL finished) {
							 self.tfEmail.backgroundColor = [UIColor clearColor];
						 }];
	}
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return UsrProfileSectionCOUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
	switch (section) {
		case UsrProfileSectionPosts:
			return self.allPosts.count;
			
		case UsrProfileSectionHashtags:
			return self.allHashtags.count;

		case UsrProfileSectionTemplText:
			return 1;
            
        case UsrProfileSectionSettings:
            return 7;
			
	//	case UsrProfileSectionFavoriteLocation:
	//		return self.allFavoriteLocations.count;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger row = indexPath.row;
	UITableViewCell *cell = nil;
	
	switch (indexPath.section) {
		case UsrProfileSectionPosts: {
            NSString *cellID = @"ZPersonPostCell";
			ZPersonPostCell *postCell = (ZPersonPostCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
			if (! postCell) {
				postCell = [ZPersonPostCell cell];
			}
			ZMailDataModel *msgModel = [self.allPosts objectAtIndex:row];
			postCell.labTitle.text = msgModel.title;
			postCell.labText.text = msgModel.descript;
			if (msgModel.hasImage)
            {
                postCell.picBack.hidden = NO;
				postCell.picture.imageURL = [NSURL urlPlaceImageWithID:msgModel.ID];
			}
			else {
                postCell.picBack.hidden = YES;
				postCell.picture.image = nil;
			}

			cell = postCell;
			break;
		}
			
		case UsrProfileSectionHashtags: {
            NSString *cellID = @"cellHashtags";
			cell = [tableView dequeueReusableCellWithIdentifier:cellID];
			if (! cell) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
				UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
				if (font) {
					cell.textLabel.font = font;
				}
			}
			cell.textLabel.text = [NSString stringWithFormat:@"#%@", [self.allHashtags objectAtIndex:row]];
			break;
		}
			
		case UsrProfileSectionTemplText: {
			
            NSString *cellID = [NSString stringWithFormat:@"TextTableViewCell%d", indexPath.row];
			
			TextTableViewCell *textCell = (TextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
			if (!textCell) {
				textCell = [[[NSBundle mainBundle] loadNibNamed:@"TextTableViewCell" owner:nil options:nil] lastObject];
                textCell.userModel = self.userModel;
			}
            
            [textCell updateData:indexPath.row+1];
    
            cell = textCell;
		}
            break;
        case UsrProfileSectionSettings:
        {
            if(indexPath.row == 5)
            {
                NSString *cellID = @"CellDefaultLanguage";
                cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (! cell) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                }
                
                cell.textLabel.text = @"Default language";
                cell.detailTextLabel.text = @"English";
                break;
            }
            else if(indexPath.row == 6)
            {
                NSString *cellID = @"CellFacebookProfile";
                cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (! cell) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                    cell.detailTextLabel.numberOfLines = 2;
                }
                
                cell.textLabel.text = @"Facebook login";
                
                if(self.isFacebookEnabled)
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"connected as %@", self.fbUsername];
                    cell.detailTextLabel.textColor = [UIColor greenColor];
                }
                else
                {
                    cell.detailTextLabel.text = @"not connected";
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                }
                
                break;
            }
            
            NSString *cellID = @"ZUserSettingBoolCell";
			ZUserSettingBoolCell *settingCell = (ZUserSettingBoolCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
			if (!settingCell) {
				settingCell = [ZUserSettingBoolCell cell];
                settingCell.delegate = self;
			}

            switch (indexPath.row)
            {
                case 0:
                {
                    settingCell.labelName.text = @"Push Notifications for Comments from Your Posts";
                    settingCell.switchControl.on = self.isCommentsApnEnabled;
                }
                    break;
                case 1:
                {
                    settingCell.labelName.text = @"Push Notifications for Comments from Other's Posts";
                    settingCell.switchControl.on = self.isPlaceCommentApnEnabled;
                }
                    break;
                case 2:
                {
                    settingCell.labelName.text = @"All Push Notifications (all posts and legits)";
                    settingCell.switchControl.on = self.isApnEnabled;
                }
                    break;
                case 3:
                {
                    settingCell.labelName.text = @"Current location visible";
                    settingCell.switchControl.on = self.currentLocationVisible;
                }
                    break;
                case 4:
                {
                    settingCell.labelName.text = @"Google map visible";
                    settingCell.switchControl.on = self.googleMapVisible;
                }
                    break;
            }
            
            cell = settingCell;
        }
            break;
			
			/*
		case UsrProfileSectionFavoriteLocation: {
			
			static NSString *cellID = @"CellFavoriteLocation";
			
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
			if (!cell) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
				[cell autorelease];
			}
			ZLocationModel *model = self.allFavoriteLocations[indexPath.row];
			cell.textLabel.text = [model stringRepresentation];
			
			return cell;
		}
             */
	}

	
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case UsrProfileSectionPosts:
			return self.headerPosts;
			
		case UsrProfileSectionHashtags:
			return self.headerHashtags;
			
		case UsrProfileSectionTemplText:
			self.headerTemplateTextLab.text = @"Configure Custom Text";
			return self.headerTemplateText;
			
        case UsrProfileSectionSettings:
            self.headerSettingsLabel.text = @"Settings";
            return self.headerSettings;
            /*
		case UsrProfileSectionFavoriteLocation:
			self.headerFavoriteLab.text = @"Favorite Locations:";
			return self.headerFavorite;
             */
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case UsrProfileSectionPosts: {
			ZMailDataModel *msgModel = [self.allPosts objectAtIndex:indexPath.row];
			return [self.controlPersonPostCell heightWithText:msgModel.descript hasImage:[msgModel hasImage]];
		}
			
		case UsrProfileSectionTemplText: {
            
			CGFloat h = [self.customTextCell heightForObject:self.userModel atIndex:indexPath.row + 1 isSwitchVisible:YES];
			h = MAX(h, 44);
			return h + 5;
		}
        case UsrProfileSectionSettings: {
			return 55;
		}

		case UsrProfileSectionHashtags:
		//case UsrProfileSectionFavoriteLocation:
			return 44;
	}
    
	return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.section)
    {
		case UsrProfileSectionTemplText:
        {
			EditTextViewController *controller = [EditTextViewController controller];
			controller.index = indexPath.row + 1;
            controller.userModel = self.userModel;
			[self.navigationController pushViewController:controller animated:YES];
			
			break;
		}
            /*
		case UsrProfileSectionFavoriteLocation: {
			
			ZLocationModel *model = self.allFavoriteLocations[indexPath.row];
			[self.delegate thisUserProfileVC:self didSelectFavoriteLocationModel:model];
			break;
		}
             */
			
//		case UsrProfileSectionFavoriteLocation: {
//			UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Show", @"Add", @"Del", nil];
//			[sheet showInView:self.view];
//			[sheet release];
//			
//			break;
//		}
			
		case UsrProfileSectionPosts: {
			ZMailDataModel *msgModel = [self.allPosts objectAtIndex:indexPath.row];
			ZCommentsListVC *ctr = [ZCommentsListVC controller];
			ctr.mailModel = msgModel;
			ctr.userModel = self.userModel;
			[self.navigationController pushViewController:ctr animated:YES];
			break;
		}
        case UsrProfileSectionHashtags:
        {
            NSString *hashtag = [self.allHashtags objectAtIndex:indexPath.row];
            hashtag = [NSString stringWithFormat:@"#%@", hashtag];
			ZMailListViewController *ctrl = [[[ZMailListViewController alloc] initWithPersonId:self.userModel.ID hashtag:hashtag] autorelease];
            [self.navigationController pushViewController:ctrl animated:YES];
			break;
		}
        case UsrProfileSectionSettings:
        {
            if(indexPath.row == 5)
            {
                ZSelectLanguageViewController *ctrl = [[[ZSelectLanguageViewController alloc] initWithLanguage:self.defaultLanguage] autorelease];
                [self.navigationController pushViewController:ctrl animated:YES];
            }
            else if(indexPath.row == 6)
            {
                //connect to facebook
                NSLog(@"Connect to facebook");
                
                UIActionSheet *sheet = nil;
                    
                if(self.isFacebookEnabled)
                {
                    if(!self.userModel.username || [self.userModel.username isEqualToString:@""])
                    {
                        sheet = [[UIActionSheet alloc] initWithTitle:@"Facebook Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                 @"Syncronize profile",
                                 nil];
                    }
                    else
                    {
                        sheet = [[UIActionSheet alloc] initWithTitle:@"Facebook Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                 @"Syncronize profile",
                                 @"Disconnect account",
                                 nil];
                    }
                }
                else
                {
                    sheet = [[UIActionSheet alloc] initWithTitle:@"Facebook Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                             @"Connect",
                             nil];
                }
                
                [sheet showInView:self.view];
                [sheet release];
            }
            
			break;
		}
			
		default:
			break;
	}
}

#pragma mark - Delegate UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet.tag == 999) {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex]; //zs
		return;
	}
	
    
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
     
    if(buttonIndex == 0)
    {
        if(self.isFacebookEnabled)
            [self synchronizeProfileWithFacebook];
        else
            [self loginToFacebook];
    }
    else if(buttonIndex == 1)
    {
        [self logoutFromFacebook];
    }
}



#pragma mark - Facebook Login
//=================================================================================================================
- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date
{    
//    NSLog(@"-delegate:token:%@",token);
//    NSLog(@"-delegate:date:%@",date);
    
    [_fbSession facebookGetInfo];    
}
- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date withInfo:(NSDictionary*)result
{
//  NSString *email = [result valueForKey:@"email"];
//  NSString *name = [result valueForKey:@"name"];
    NSString *username = [result valueForKey:@"username"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{      
        NSURL *fbPictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=300&height=300", [result objectForKey:@"id"]]];
        NSData *dat = [NSData dataWithContentsOfURL:fbPictureURL];        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fbImage = [UIImage imageWithData:dat];
            if (self.loadFBImage) {
                self.loadFBImage = NO;
                [self getUserImageFromFBView];
            }
        });
        
    });
        
//  NSLog(@"delegate:token:%@",token);
//  NSLog(@"delegate:date:%@",date);
//    NSLog(@"(%@)(%@)(%@)",email,name,username);
//    NSLog(@"res=(%@)",result);
    
    if(YES)
    {
        self.isFacebookEnabled = YES;
        self.fbUsername = username;        
        [self.table reloadData];
    }
    
}

-(void)loginToFacebook
{
    if (!_fbSession)
        self.fbSession = [[[FBSession alloc] initWithDelegate:self] autorelease];
    [_fbSession facebookLogin];
    

    /*
    #define SETTING_KEY_FACEBOOK_LOGIN      @"SETTING_KEY_FACEBOOK_LOGIN"
    #define SETTING_KEY_FACEBOOK_PASSWORD   @"SETTING_KEY_FACEBOOK_PASSWORD"
    #define SETTING_KEY_IS_FACEBOOK_LOGIN   @"SETTING_KEY_IS_FACEBOOK_LOGIN"
    
    SCLoginViewController* loginViewController =
    [[SCLoginViewController alloc]initWithNibName:@"SCLoginViewController" bundle:nil];
    [topViewController presentModalViewController:loginViewController animated:NO];
    */
    
    
/* //zsf
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error)
    {
                                      if (error)
                                      {
                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                              message:error.localizedDescription
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil];
                                          [alertView show];
                                      }
                                      else if (session.isOpen)
                                      {
                                          [self getFBInfo];
                                          //[self pickFriendsButtonClick:sender];
                                      }
                                  }];
*/  
}

-(void)logoutFromFacebook
{
    self.fbUsername = nil;
    self.isFacebookEnabled = NO;
    
    [self.table reloadData];
    
    if (self.fbSession)
        [self.fbSession facebookLogout]; //zs
}

-(void)getUserImageFromFBView
{
    UIImage *img = self.fbImage;
    [self savePicture:img];
}

-(void)synchronizeProfileWithFacebook
{
    if (!self.fbImage)  {
        self.loadFBImage = YES;
        [self loginToFacebook];
        return;        
    }
    
    [self getUserImageFromFBView];
    
/* //zsf
    [FBRequestConnection startForMeWithCompletionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error)
     {
         NSLog(@"facebook result: %@", result);
         FBGraphObject *graphObject = (FBGraphObject*)result;
         NSLog(@"Id = %@", [graphObject objectForKey:@"id"]);
         NSLog(@"Username = %@", [graphObject objectForKey:@"username"]);
         self.userModel.facebookUsername = [graphObject objectForKey:@"username"];
         self.isFacebookEnabled = YES;
         [self.table reloadData];
         
         self.fbPictView = [[FBProfilePictureView alloc] initWithFrame:CGRectZero];
         self.fbPictView.profileID = [graphObject objectForKey:@"id"];
         [self performSelector:@selector(getUserImageFromFBView) withObject:nil afterDelay:1.0];
     }];
*/
}

#pragma mark - FBLoginView delegate


#pragma mark - Requests

- (void)runUserSettingsRequestWithUserID:(NSString *)userID
{	
    NSDictionary *arguments = @{@"show" : @"1"};
	ZCommonRequest *rq = [ZCommonRequest requestWithActionName:@"settings" arguments:arguments];
	
	[self.spinner startAnimating];
	dispatch_async(dispatch_queue_create("request.settings", NULL), ^{
		[rq startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.spinner stopAnimating];
			[self handleUserSettingsResultRequest:rq];
		});
	});
}

- (void)handleUserSettingsResultRequest:(ZCommonRequest *)rq {
	
	NSDictionary *resultDict = [[rq responseString] JSONValue];
    
	if (resultDict.count) {
		LLog(@"%@", resultDict);
	}
	else {
		LLog(@"resp:'%@'; err:'%@'", [rq responseString], rq.error);
	}
	
	if (!rq.error) {
		[self.userModel applySettingsDictionary:resultDict];
        
		[self reloadData];
	}
}

- (void)runPersonProfileRequestWithUserID:(NSString *)userID {
	ZCommonRequest *rq = [ZCommonRequest requestPersonProfileWithID:userID];
	
	[self.spinner startAnimating];
	dispatch_async(dispatch_queue_create("request.profile", NULL), ^{
		[rq startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.spinner stopAnimating];
			[self handleResultRequest:rq];
		});
	});
}

- (void)handleResultRequest:(ZCommonRequest *)rq {
	
	NSDictionary *resultDict = [[rq responseString] JSONValue];

	if (resultDict.count) {
		LLog(@"%@", resultDict);
	}
	else {
		LLog(@"resp:'%@'; err:'%@'", [rq responseString], rq.error);
	}
	
	if (!rq.error) {
		ZPersonModel *personModel = [ZPersonModel modelWithID:self.userModel.ID];
		[personModel updateWithDetailedInfoDictionary:resultDict];
		self.userModel.extendedModel = personModel;
		
		self.allHashtags = personModel.hashtags;
		self.allPosts = personModel.latestPosts;
        
		[self reloadData];
	}
}

#pragma mark  - request to Save
- (void)runRequestSaveUser {
	
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"settings"];
	//	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL urlWithActionString:@"settings"]];
	//	[request setPostValue:self.userModel.sessionID forKey:@"sess_id"];
	
	if (hasUnsavedPicture && self.userModel.hasImage) {
		[request setPostValue:@"1" forKey:@"num"];
		[request setFile:[self.userModel pathPicture] forKey:@"image"];
	}
	else {
	}
	NSString *apnsToken = self.userModel.apnsToken;
	if (apnsToken) {
		[request setPostValue:apnsToken forKey:@"token"];
	}
	
	NSString *email = [self.tfEmail.text trimWhitespace];
	if (email.length) {
		[request setPostValue:email forKey:@"email"];
	}
    
    if(self.userModel.facebookUsername)
        [request setPostValue:self.userModel.facebookUsername forKey:@"fb_account"];
	else
        [request setPostValue:@"" forKey:@"fb_account"];
    
	BOOL isPingOn = NO;
	[request setPostValue:isPingOn ? @"1" : @"0" forKey:@"ping"];
	
    for(int i=1; i<=10; i++)
    {
        NSString *customStringFmt = [NSString stringWithFormat:@"ln%d", i];
        NSString *customStringVisibleFmt = [NSString stringWithFormat:@"ln%d_v", i];
        
        NSString *onValue = i == 1 ? [self.userModel.customFields objectForKey:customStringVisibleFmt] : @"0";
        
        NSString *textValue = [self.userModel.customFields objectForKey:customStringFmt];

        
//      NSLog(@"%d:%@-%@", i, textValue, onValue);
        
        [request setPostValue:textValue forKey:customStringFmt];
        [request setPostValue:onValue forKey:customStringVisibleFmt];
    }
    
	// task #7
	NSString *public = self.userModel.isPublic ? @"1" : @"0";
	[request setPostValue:public forKey:@"public"];
    
    NSString *isCommentsApnEnabled = self.isCommentsApnEnabled ? @"0" : @"1";
	[request setPostValue:isCommentsApnEnabled forKey:@"pm_comment"];
    
    NSString *isPlaceCommentApnEnabled = self.isPlaceCommentApnEnabled ? @"0" : @"1";
	[request setPostValue:isPlaceCommentApnEnabled forKey:@"pm_resp"];
    
    NSString *isApnEnabled = self.isApnEnabled ? @"0" : @"1";
	[request setPostValue:isApnEnabled forKey:@"pm_all"];
	
	int privacy = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerPrivacy"];
	[request setPostValue:[[NSNumber numberWithInt:privacy] stringValue] forKey:@"ping_opt"];
	[request setPostValue:[NSString stringWithFormat:@"%f", APP_DLG.longitude] forKey:@"lon"];
	[request setPostValue:[NSString stringWithFormat:@"%f", APP_DLG.latitude] forKey:@"lat"];
	
	//	for (int i = 0; i < 10; i++) {
	//
	//		NSString *key = [NSString stringWithFormat:@"ln%d", i + 1];
	//
	//		NSString *_text = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	//		if (_text && [_text length] > 0) {
	//			[request setPostValue:_text forKey:key];
	//		}
	//
	//		key = [NSString stringWithFormat:@"ln%d_v", i + 1];
	//		[request setPostValue:[[NSUserDefaults standardUserDefaults] boolForKey:key] ? @"1" : @"0" forKey:key];
	//
	//	}
	//
	//	int timeFilter_0 = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeFilter_0"];
	//	int timeFilter_1 = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeFilter_1"];
	//	int timeFilter_2 = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeFilter_2"];
	//	int timeFilter_3 = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeFilter_3"];
	//
	//	if (timeFilter_0 == 0 && timeFilter_1 == 0 && timeFilter_1 == 0 && timeFilter_3 == 0) timeFilter_0 = 1;
	//
	//	[request setPostValue:[NSString stringWithFormat:@"%d|%d|%d|%d", timeFilter_0, timeFilter_1, timeFilter_2, timeFilter_3] forKey:@"time_filter"];
	
	
	[self showProgress];
//    NSLog(@"save_1");
	dispatch_async(dispatch_queue_create("request.upload.picture", NULL), ^{
//  dispatch_sync(dispatch_queue_create("request.upload.picture", NULL), ^{
//        NSLog(@"save_3");
		[request startSynchronous];
		NSError *error = [request error];
//        NSLog(@"save_33 err=%d",error.code);
		
		dispatch_async(dispatch_get_main_queue(), ^{
//			[self hideProgress];
            BOOL wasSave = NO;
            BOOL wasDelay = NO;
			if (!error)
            {
                self.userModel.isApnEnabled = self.isApnEnabled;
                self.userModel.isCommentsApnEnabled = self.isCommentsApnEnabled;
                self.userModel.isPlaceCommentApnEnabled = self.isPlaceCommentApnEnabled;
                self.userModel.currentLocationVisible = self.currentLocationVisible;
                self.userModel.googleMapVisible = self.googleMapVisible;
                self.userModel.facebookUsername = self.fbUsername;
                                                
				if (hasUnsavedPicture) {
					NSURL *url = [NSURL urlPersonProfileImageWithID:self.userModel.ID];
					NSLog(@">>img-url:'%@'", url.absoluteString);
					if (self.imageUrlToRemove) {
//                      [self.picture emptyCache]; //zs
 						[self.picture clearCacheForURL:self.imageUrlToRemove];
						self.imageUrlToRemove = nil;
                        wasSave = YES;
					}
                    wasDelay = YES;
					[self performSelector:@selector(loadImageForUrl:) withObject:url afterDelay:1];//need to wait until cache is empty
                    
                    hasUnsavedPicture = NO;
                    
//                    self.testImageView.image = nil; //zs
//                    self.testImageView.backgroundColor = [UIColor greenColor];                    
				}
                
                for(int i=1; i<=10; i++)
                {
                    NSString *customStringFmt = [NSString stringWithFormat:@"ln%d", i];
                    NSString *customStringVisibleFmt = [NSString stringWithFormat:@"ln%d_v", i];
                    
                    NSString *onValue = [[NSUserDefaults standardUserDefaults] stringForKey:customStringVisibleFmt];
                    if(!onValue)
                    {
                        onValue = @"0";
                        [[NSUserDefaults standardUserDefaults] setObject:onValue forKey:customStringVisibleFmt];
                    }
                    NSString *textValue = [[NSUserDefaults standardUserDefaults] stringForKey:customStringFmt];
                    if(!textValue)
                    {
                        textValue = @"";
                        [[NSUserDefaults standardUserDefaults] setObject:textValue forKey:customStringFmt];
                    }
                    
                    [self.userModel.customFields setObject:textValue forKey:customStringFmt];
                    [self.userModel.customFields setObject:onValue forKey:customStringVisibleFmt];
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.userModel saveUser];
			}
			else {
                [APP_DLG showAlertWithMessage:[error localizedDescription] title:nil];
			}
//          [self hideProgress];
//          NSLog(@"save_end");
            if (wasDelay) {
                [self performSelector:@selector(hideProgress) withObject:nil afterDelay:1.2]; //1.0
            } else {
                [self performSelector:@selector(hideProgress) withObject:nil afterDelay:0.2]; //0.5
            }
		});
	});
//  NSLog(@"save_2");
	
//	LLog(@"request2 = (%@)", [request responseString]);
}

-(void)loadImageForUrl:(NSURL*)url
{
    self.picture.imageURL = url;
}


- (void)imageViewLoadedImage:(EGOImageView*)eIimage
{
//  NSLog(@">->->Loaded EGO_image:%@",eIimage.imageURL);
//    self.testImageView.backgroundColor = [UIColor redColor];
//    self.testImageView.image = eIimage.image; //zs
    if (!eIimage.image) {
        NSLog(@">>>Loaded EGO_IMAGE = NIL");
    }
    
}
        
- (void)imageViewFailedToLoadImage:(EGOImageView*)eImage
{
    NSLog(@"!!!NOT Loaded EGO_image:%@",eImage.imageURL);
}


#pragma mark - ZSmartTextViewDelegate

- (void)smartTextView:(ZSmartTextView *)smartTextView
didSelectOriginalText:(NSString *)oText
		formattedText:(NSString *)fText
				 kind:(ZSmartTextKind)kind
{
	switch (kind) {
		case ZSmartTextKindLink:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:fText]];
			break;
			
		case ZSmartTextKindHashtag: {
            [APP_DLG showAlertWithMessage:fText title:@"Hashtag"];            
			break;
		}			
		case ZSmartTextKindPhoneNumber: {
			break;
		}			
		default:
			break;
	}
}

#pragma mark - ZSelectLanguageViewController delegate

-(void)controller:(ZSelectLanguageViewController*)sender didSelectLanguage:(NSString*)language
{
    self.defaultLanguage = language;
    [self.table reloadData];
}

- (void)viewDidUnload {
    [self setTestImageView:nil];
    [super viewDidUnload];
}
@end
