//
//  HomeViewController_iPhone.h
//  Peek
//
//  Created by Pavel on 14.06.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSuperViewController.h"
#import "HashBookmarksVC.h"
#import "NewMessageViewController.h"
#import "ZFavoritesListViewController.h"

@class ZUserModel;
@class ZMailDataModel;
@class ZVenueModel;
@class ZGarageSaleModel;

@interface HomeViewController : ZSuperViewController
<UIActionSheetDelegate, UISearchBarDelegate, HashBookmarksVCDelegate, NewMessageViewControllerDelegate, UISearchBarDelegate, ZFavoritesListDelegate>
{
	BOOL updatedPosition;
    
    __strong id<MKAnnotation> _visibleAnnotation;        //annotation which is always visible (set when press move to map button)
}

@property (nonatomic, readonly) ZUserModel	*userModel;

- (void)updateNotificationBadge;
- (void)invalidateMap;
- (void)showMailMessageWithId:(NSString*)mailModelId;
- (void)showVenueConversationId:(NSString*)conversationId;

-(void)doLogout:(BOOL)shouldSendRequest;

-(void)showConversationOnMap:(ZMailDataModel*)mailModel;
-(void)showVenueOnMap:(ZVenueModel*)venueModel;
-(void)showSaleOnMap:(ZGarageSaleModel*)saleModel;

@end
