//
//  ZNotificationCell.m
//  ZVeqtr
//
//  Created by Maxim on 2/13/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZNotificationCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ZNotificationModel.h"
#import "EGOImageView.h"
#import "NSURL+ZVeqtr.h"
#import "NSAttributedString+Attributes.h"

@interface ZNotificationCell ()
@property (nonatomic, retain) ZNotificationModel	*internalNotifModel;

@property (nonatomic, retain) IBOutlet UIButton	*buttonUsername;
@property (nonatomic, retain) IBOutlet UIButton	*buttonAction;

@end

@implementation ZNotificationCell
{
	CGFloat	initialHeight;
}

- (void)awakeFromNib
{
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font)
    {
		_labMessage.font = font;
        
		_picBack.layer.masksToBounds = YES;
		_picBack.layer.cornerRadius = 4;
		_picBack.layer.borderColor = [UIColor grayColor].CGColor;
		_picBack.layer.borderWidth = 1;
        
        self.labUsername.backgroundColor = [UIColor clearColor];
        self.labUsername.delegate = self;
        self.labUsername.userInteractionEnabled = YES;
        self.labUsername.automaticallyAddLinksForType = NSTextCheckingTypeLink|NSTextCheckingTypeAddress;
        
        self.labAction.backgroundColor = [UIColor clearColor];
        self.labAction.delegate = self;
        self.labAction.userInteractionEnabled = YES;
        self.labAction.automaticallyAddLinksForType = NSTextCheckingTypeLink|NSTextCheckingTypeAddress;
        
        self.labMessage.centerVertically = YES;
        self.labMessage.delegate = self;
        self.labMessage.userInteractionEnabled = YES;
        self.labMessage.automaticallyAddLinksForType = NSTextCheckingTypeLink|NSTextCheckingTypeAddress;
        self.labMessage.numberOfLines = 0;
	}
    
	initialHeight = self.frame.size.height;
}

-(IBAction)buttonToMap_Action
{
    if(self.delegate)
        [self.delegate notificationCellToMapButtonClicked:self];
}


- (void)dealloc {
	self.internalNotifModel = nil;
	[super dealloc];
}

+ (ZNotificationCell *)cell {
	return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

-(void)setNotificationModel:(ZNotificationModel *)notificationModel
{
    self.internalNotifModel = notificationModel;
    [self applyModel];
}

- (ZNotificationModel *)notificationModel {
	return self.internalNotifModel;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize maxSz = CGSizeMake(CGFLOAT_MAX, self.labAction.frame.size.height);
    CGSize size = [self.internalNotifModel.actionText sizeWithFont:self.labAction.font constrainedToSize:maxSz lineBreakMode:self.labAction.lineBreakMode];
    CGRect actionRect = self.labAction.frame;
    actionRect.size.width = size.width;
    self.labAction.frame = actionRect;
    //self.buttonAction.frame = actionRect;
    
    if(self.internalNotifModel.message)
    {
        CGSize maxSz = CGSizeMake(self.labMessage.frame.size.width, CGFLOAT_MAX);
        CGSize size = [self.labMessage.attributedText sizeConstrainedToSize:maxSz];
        
        CGRect messageFrame = self.labMessage.frame;
        messageFrame.size.height = size.height;
        self.labMessage.frame = messageFrame;
    }
    else
    {
        CGRect messageFrame = self.labMessage.frame;
        messageFrame.size.height = 0;
        self.labMessage.frame = messageFrame;
    }
    
    CGRect actionDateFrame = self.labActionDate.frame;
    actionDateFrame.origin.y = self.labMessage.frame.origin.y + self.labMessage.frame.size.height+5;
    self.labActionDate.frame = actionDateFrame;
}

- (void)applyModel
{
    if([self.notificationModel.actionType isEqualToString:kNTFriendRequest]
       || [self.notificationModel.actionType isEqualToString:kNTFriendFollowers])
    {
        _buttonToMap.hidden = YES;
    }
    else
    {
        _buttonToMap.hidden = NO;
    }
    
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:self.internalNotifModel.nickname];
    [attrStr setFont:self.labUsername.font];
    self.labUsername.attributedText = attrStr;
    [self.labUsername addCustomLink:[NSURL URLWithString:@"http://www.google.com"] inRange:[self.internalNotifModel.nickname rangeOfString:self.internalNotifModel.nickname]];
    
	self.picture.imageURL = [NSURL urlPersonProfileImageWithID:self.internalNotifModel.creatorId];
    
    attrStr = [NSMutableAttributedString attributedStringWithString:self.internalNotifModel.actionText];
    [attrStr setFont:self.labAction.font];
    self.labAction.attributedText = attrStr;
    
    //if(![self.internalNotifModel.actionType isEqualToString:@"friend"])
    {
        [self.labAction addCustomLink:[NSURL URLWithString:@"http://www.google.com"] inRange:[self.internalNotifModel.actionText rangeOfString:self.internalNotifModel.actionText]];
        /*
        [self.labAction addCustomLink:[NSURL URLWithString:@"http://www.google.com"] inRange:[self.internalNotifModel.actionText rangeOfString:self.internalNotifModel.actionText]];
        [self.labAction addCustomLink:[NSURL URLWithString:@"http://www.google.com"] inRange:[self.internalNotifModel.actionText rangeOfString:self.internalNotifModel.actionText]];
        [self.labAction addCustomLink:[NSURL URLWithString:@"http://www.google.com"] inRange:[self.internalNotifModel.actionText rangeOfString:self.internalNotifModel.actionText]];
        */
    }
    
    if(self.internalNotifModel.message)
    {
        //self.labActionLink.hidden = NO;
        self.labMessage.hidden = NO;
        attrStr = [NSMutableAttributedString attributedStringWithString:self.internalNotifModel.message];
        [attrStr setFont:self.labMessage.font];
        
        self.labMessage.attributedText = attrStr;
    }
    else
    {
        //self.labActionLink.hidden = YES;
        self.labMessage.hidden = YES;
    }
    
    
    self.labActionDate.text = self.internalNotifModel.date;
}

- (CGFloat)heightWithNotificationModel:(ZNotificationModel *)model
{
	if (!model.message)
    {
		return initialHeight;
	}
    
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:model.message];
    [attrStr setFont:self.labMessage.font];
    
    CGSize maxSz = CGSizeMake(self.labMessage.frame.size.width, CGFLOAT_MAX);
    CGSize size = [attrStr sizeConstrainedToSize:maxSz];
    
    return initialHeight + size.height;
}

-(IBAction)buttonUsername_Pressed
{
    [self.delegate notificationCellUsernameClicked:self];
}

-(IBAction)buttonUserimage_Pressed
{
    [self.delegate notificationCellUsernameClicked:self];
}

-(IBAction)buttonAction_Pressed
{
    [self.delegate notificationCellPostClicked:self];
}

#pragma mark -
#pragma mark OHAttributedLabel delegate

-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel shouldFollowLink:(NSTextCheckingResult*)linkInfo
{
    /*
	currentUrl = [linkInfo.URL retain];
    
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
													 message:@"This link will open in Safari"
													delegate:self
										   cancelButtonTitle:nil
										   otherButtonTitles:@"Cancel", @"Yes", nil] autorelease];
	[alert show];
	*/
    if(attributedLabel == self.labUsername)
    {
        [self.delegate notificationCellUsernameClicked:self];
    }
    else if(attributedLabel == self.labAction)
    {
        [self.delegate notificationCellPostClicked:self];
    }
    else if(attributedLabel == self.labMessage)
    {
        [[UIApplication sharedApplication] openURL:linkInfo.URL];
    }
    
	return NO;
}


-(UIColor*)colorForLink:(NSTextCheckingResult*)link underlineStyle:(int32_t*)pUnderline {
    return [UIColor blackColor];
}

@end
