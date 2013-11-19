//
//  ZUserModel.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZPersonModel;
@class ZDateComponents;
@class ZLocationModel;
@class ZFavoriteFilterModel;

@interface ZUserModel : NSObject
@property (nonatomic, retain) NSString *ID;
@property (nonatomic, retain) NSString *sessionID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *realname;
@property (nonatomic, retain) NSString *pwd;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *facebookUsername;
//	it keeps this token for debug purpose only, it comes from server (not from iOS)
@property (nonatomic, retain) NSString *apnsToken;
@property (nonatomic, retain) NSMutableArray *allHashtags;
@property (nonatomic, assign) BOOL	friendsOnlySearch;
@property (nonatomic, assign) BOOL	switchDistance;
@property (nonatomic, assign) BOOL	ping;
@property (nonatomic, assign) BOOL	isPublic;

@property (nonatomic, assign) BOOL	isCommentsApnEnabled;
@property (nonatomic, assign) BOOL	isPlaceCommentApnEnabled;
@property (nonatomic, assign) BOOL	isApnEnabled;
@property (nonatomic, assign) BOOL	currentLocationVisible;
@property (nonatomic, assign) BOOL	googleMapVisible;

@property (nonatomic, assign) int	unreadNotificationsCount;
@property (nonatomic, retain) NSString	*defaultLanguage;
@property (nonatomic, retain) NSMutableDictionary       *customFields;

//{1,5,10,25,50,100,150};
@property (nonatomic, assign) NSInteger	pickerDistance;
@property (nonatomic, retain) UIImage	*image;

- (NSString *)pathPicture;
- (BOOL)hasImage;

//	ZLocationModel array
- (NSArray *)allFavouriteLocations;
- (void)addFavoriteLocationModel:(ZLocationModel *)model;

//	ZFavoriteFilterModel collection
- (void)addFavoriteFilterModel:(ZFavoriteFilterModel *)model;
- (NSMutableArray *)allFavouriteFilters;
- (NSMutableArray *)allFavouriteFiltersForType:(NSString*)type;
- (void)deleteFavoriteFilterModel:(ZFavoriteFilterModel *)model;
-(void)saveCurrentFilters;
-(void)restoreCurrentFilters;

//	ZPersonModel extends this model (it duplicates some fields)
@property (nonatomic, retain) ZPersonModel	*extendedModel;

- (void)addHashtagsFromArray:(NSArray *)array;

- (void)applySettingsDictionary:(NSDictionary *)dic;

+ (ZUserModel *)restoreUser;
+ (ZUserModel *)userModelWithLoginDictionary:(NSDictionary *)dict;
- (BOOL)applyLoginDictionary:(NSDictionary *)dict;
- (void)restoreUser;
- (void)saveUser;

//	time filters
@property (nonatomic, retain) ZDateComponents *dateComponents;
- (void)saveDateComponents;
- (void)restoreDateComponents;
- (NSDictionary *)dateFilterArguments;
//	resets filters to default values
- (void)resetTimeFilters;

@end
