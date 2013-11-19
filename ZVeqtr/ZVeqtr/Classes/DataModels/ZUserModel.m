//
//  ZUserModel.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZUserModel.h"
#import "ZLocationModel.h"
#import "NSString+ZVeqtr.h"
#import "ZDateComponents.h"
#import "ZFavoriteFilterModel.h"


#define DEFAULTS_USER_FILTER_FORMAT_KEY @"UserFilter_%@" //should be field with user id

@interface ZUserModel ()
@property (nonatomic, retain, readwrite) NSMutableArray *arrFavouriteLocations;
@property (nonatomic, retain, readwrite) NSMutableDictionary *dicFavouriteFilters;
@end


@implementation ZUserModel

+ (ZUserModel *)userModelWithLoginDictionary:(NSDictionary *)dict {
	ZUserModel *model = [[self new] autorelease];
	if (![model applyLoginDictionary:dict]) {
		model = nil;
	}
	return model;
}

+ (ZUserModel *)restoreUser {
	ZUserModel *model = [[self new] autorelease];
	[model restoreUser];
	if (!model.username) {
		model = nil;
	}
	return model;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.googleMapVisible = YES;
    }
    return self;
}

- (void)dealloc {
	self.ID = nil;
	self.sessionID = nil;
	self.username = nil;
	self.realname = nil;
	self.pwd = nil;
	self.email = nil;
	self.apnsToken = nil;
	self.allHashtags = nil;
	self.arrFavouriteLocations = nil;
	self.extendedModel = nil;
    self.dicFavouriteFilters = nil;
    self.defaultLanguage = nil;
    
	[super dealloc];
}

- (void)addFavoriteFilterModel:(ZFavoriteFilterModel *)model {
	if (!model) {
		LLog(@"No model!!")
		return;
	}
    
    if (!model.type) {
		LLog(@"Type of filter wasn't defined!!")
		return;
	}
	
    NSMutableArray *array = [self.dicFavouriteFilters objectForKey:model.type];
    if(!array)
    {
        array = [NSMutableArray array];
        [self.dicFavouriteFilters setObject:array forKey:model.type];
    }
    
	NSInteger indx = [array indexOfObject:model];
	if (indx != NSNotFound) {
		[array removeObjectAtIndex:indx];
	}
    
	[array insertObject:model atIndex:0];
    
    [self saveCurrentFilters];
}

-(void)saveCurrentFilters
{
    NSString *defaultsFilterKey = [NSString stringWithFormat:DEFAULTS_USER_FILTER_FORMAT_KEY, self.ID];
    NSMutableArray *filterArray = [NSMutableArray array];
    
    for(ZFavoriteFilterModel *model in [self allFavouriteFilters])
    {
        NSDictionary *filterDictionary = [model dictionaryRepresentation];
        [filterArray insertObject:filterDictionary atIndex:0];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:filterArray forKey:defaultsFilterKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)restoreCurrentFilters
{
    self.dicFavouriteFilters = [NSMutableDictionary dictionary];
    
    NSString *defaultsFilterKey = [NSString stringWithFormat:DEFAULTS_USER_FILTER_FORMAT_KEY, self.ID];
    NSMutableArray *filterArray = [[NSUserDefaults standardUserDefaults] objectForKey:defaultsFilterKey];
    if(!filterArray)
    {
        LLog(@"No active filters!!")
        return;
    }
    
    for(NSDictionary *filterDictionary in filterArray)
    {
        ZFavoriteFilterModel *model = [ZFavoriteFilterModel modelWithDictionary:filterDictionary];
        NSMutableArray *array = [self.dicFavouriteFilters objectForKey:model.type];
        if(!array)
        {
            array = [NSMutableArray array];
            [self.dicFavouriteFilters setObject:array forKey:model.type];
        }
        
        NSInteger indx = [array indexOfObject:model];
        if (indx != NSNotFound) {
            [array removeObjectAtIndex:indx];
        }
        
        [array insertObject:model atIndex:0];
    }
}

- (void)deleteFavoriteFilterModel:(ZFavoriteFilterModel *)model
{
    [model deleteImage];
    for(NSString *key in [self.dicFavouriteFilters allKeys])
    {
        NSMutableArray *array = [self.dicFavouriteFilters objectForKey:key];
        if([array containsObject:model])
        {
            [array removeObject:model];
            break;
        }
    }
    
    [self saveCurrentFilters];
}

- (NSMutableArray *)allFavouriteFilters
{
    NSMutableArray *array = [NSMutableArray array];
    for(NSString *key in [self.dicFavouriteFilters allKeys])
    {
        [array addObjectsFromArray:[self.dicFavouriteFilters objectForKey:key]];
    }
    
	return array;
}

- (NSMutableArray*)allFavouriteFiltersForType:(NSString*)type {
	return [NSMutableArray arrayWithArray:[self.dicFavouriteFilters objectForKey:type]];
}

- (void)addFavoriteLocationModel:(ZLocationModel *)model {
	if (!model) {
		LLog(@"No model!!")
		return;
	}
	
	NSInteger indx = [self.arrFavouriteLocations indexOfObject:model];
	if (indx != NSNotFound) {
		[self.arrFavouriteLocations removeObjectAtIndex:indx];
	}

	[self.arrFavouriteLocations insertObject:model atIndex:0];
	if (self.arrFavouriteLocations.count > 20) {
		[self.arrFavouriteLocations removeLastObject];
	}
}

- (NSArray *)allFavouriteLocations {
	return self.arrFavouriteLocations;
}

- (NSString *)pathPicture {
	return [@"photo1.jpg" docPath];
}

- (BOOL)hasImage {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self pathPicture]];
}

- (void)setImage:(UIImage *)image {
	NSData *imgData = UIImageJPEGRepresentation(image, 0.8);
	NSString *path = [self pathPicture];
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
	BOOL isOK = [imgData writeToFile:path atomically:YES];
	if (!isOK) {
		LLog(@"Cannot save image at path '%@'", path);
	}
}

- (UIImage *)image {
	NSString *picFile = [self pathPicture];
	LLog(@"%@", picFile);
	NSData *imgData = [NSData dataWithContentsOfFile:picFile];
	return imgData ? [UIImage imageWithData:imgData] : nil;
}

- (BOOL)applyLoginDictionary:(NSDictionary *)dict {
	NSString *status = dict[@"status"];
	if (![status isEqualToString:@"ok"]) {
		return NO;
	}
	self.sessionID = dict[@"sess_id"];
	self.apnsToken = dict[@"token"];
	self.ID = dict[@"user_id"];
    self.unreadNotificationsCount = [dict[@"notify_cnt"] intValue];
    
    [self restoreCurrentFilters];
    
	return self.ID.length && self.sessionID.length;
}

- (void)restoreUser {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	self.username = [ud objectForKey:@"username"];
	self.realname = [ud objectForKey:@"realname"];
	self.pwd = [ud objectForKey:@"password"];
	self.email = [ud objectForKey:@"email"];
    self.facebookUsername = [ud objectForKey:@"fbUsername"];
	
	self.allHashtags = [[[ud objectForKey:@"allHashtags"] mutableCopy] autorelease];
	if (!self.allHashtags) {
		self.allHashtags = [NSMutableArray arrayWithCapacity:32];
	}

	//	restore locations from dictionaries
	NSArray *favLocations = [ud objectForKey:@"allFavouriteLocations"];
	if (favLocations.count) {
		NSMutableArray *locations = [NSMutableArray arrayWithCapacity:[favLocations count]];
		for (NSDictionary *dic in favLocations) {
			ZLocationModel *locModel = [ZLocationModel locationModelWithDictionary:dic];
			if (locModel) {
				[locations addObject:locModel];
			}
		}
		self.arrFavouriteLocations = locations;
	}

	if (!self.arrFavouriteLocations) {
		self.arrFavouriteLocations = [NSMutableArray arrayWithCapacity:32];
	}
    
    //restore favorite filters from dictionaries
    //TODO: implement save/load of filters
    /*
    NSArray *favFilters = [ud objectForKey:@"allFavouriteFilters"];
	if (favFilters.count) {
		NSMutableArray *filters = [NSMutableArray arrayWithCapacity:[favFilters count]];
		for (NSDictionary *dic in favFilters) {
			ZLocationModel *locModel = [ZLocationModel locationModelWithDictionary:dic];
			if (locModel) {
				[locations addObject:locModel];
			}
		}
		self.arrFavouriteLocations = locations;
	}
    */
    
	self.isPublic = [ud boolForKey:@"isPublic"];
    self.currentLocationVisible = [ud boolForKey:@"currentLocationVisible"];
    self.googleMapVisible = YES;

    NSString *str = [ud objectForKey:@"googleMapVisible"];
    if (str == nil) {
        self.googleMapVisible = YES; //default value
    } else {
        self.googleMapVisible = [ud boolForKey:@"googleMapVisible"];        
    }
    self.defaultLanguage = [ud valueForKey:@"defaultLanguage"];
    if(self.defaultLanguage == nil)
    {
        self.defaultLanguage = @"English"; //default value
    }
    
    NSLog(@" google visible = %d",self.googleMapVisible);
}

- (void)saveUser {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if (self.username) {
		[ud setObject:self.username forKey:@"username"];
	}
	if (self.realname) {
		[ud setObject:self.realname forKey:@"realname"];
	}
	if (self.pwd) {
		[ud setObject:self.pwd forKey:@"password"];
	}
	if (self.email) {
		[ud setObject:self.email forKey:@"email"];
	}
    if (self.facebookUsername) {
		[ud setObject:self.facebookUsername forKey:@"fbUsername"];
	}
    
    

	if (self.allHashtags.count) {
		[ud setObject:self.allHashtags forKey:@"allHashtags"];
	}
	else {
		[ud removeObjectForKey:@"allHashtags"];
	}

	if (self.arrFavouriteLocations.count) {
		//	convert into dict
		NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.arrFavouriteLocations.count];
		for (ZLocationModel *locModel in self.arrFavouriteLocations) {
			NSDictionary *dic = [locModel dictionaryRepresentation];
			if (dic) {
				[arr addObject:dic];
			}
		}
		[ud setObject:arr forKey:@"allFavouriteLocations"];
	}
	else {
		[ud removeObjectForKey:@"allFavouriteLocations"];
	}
	
	[ud setBool:self.isPublic forKey:@"isPublic"];
    [ud setBool:self.currentLocationVisible forKey:@"currentLocationVisible"];
    [ud setBool:self.googleMapVisible forKey:@"googleMapVisible"];
    [ud setValue:self.defaultLanguage forKey:@"defaultLanguage"];
	
	[self saveDateComponents];
	
	[ud synchronize];
}

- (void)applySettingsDictionary:(NSDictionary *)dic
{
    if(!self.customFields)
    {
        self.customFields = [NSMutableDictionary dictionary];
    }
    
    NSString *pm_all = CHECK_STRING(dic[@"pm_all"]);
    NSString *pm_comment = CHECK_STRING(dic[@"pm_comment"]);
    NSString *pm_resp = CHECK_STRING(dic[@"pm_resp"]);
    
    self.isCommentsApnEnabled = [pm_comment isEqualToString:@"0"];
    self.isPlaceCommentApnEnabled = [pm_resp isEqualToString:@"0"];
    self.isApnEnabled = [pm_all isEqualToString:@"0"];
    
    for(int i=1; i<=10; i++)
    {
        NSString *customStringFmt = [NSString stringWithFormat:@"ln%d", i];
        NSString *customStringVisibleFmt = [NSString stringWithFormat:@"ln%d_v", i];
        
        NSString *customString = CHECK_STRING(dic[customStringFmt]);
        NSString *customStringVisible = CHECK_STRING(dic[customStringVisibleFmt]);
        
        [self.customFields setValue:customString forKey:customStringFmt];
        [self.customFields setValue:customStringVisible forKey:customStringVisibleFmt];
    }
}

#pragma mark -

- (void)addHashtagsFromArray:(NSArray *)array {
	if (!self.allHashtags) {
		self.allHashtags = [NSMutableArray arrayWithCapacity:32];
	}
	for (NSString *tag in array) {
		if (![self.allHashtags containsObject:tag]) {
			[self.allHashtags addObject:tag];
		}
	}
}

- (void)saveDateComponents {
	if (self.dateComponents) {
		[[NSUserDefaults standardUserDefaults] setObject:[self.dateComponents dictionaryRepresentation] forKey:@"dateComponents"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)restoreDateComponents {
	NSDictionary *dictDC = [[NSUserDefaults standardUserDefaults] objectForKey:@"dateComponents"];
	self.dateComponents = dictDC ? [ZDateComponents dateComponentsWithDictionary:dictDC] : nil;
	LLog(@"dateComponents: '%@'", self.dateComponents);
}

- (NSDictionary *)dateFilterArguments {
	return [self.dateComponents dateFilterArguments];
}

- (void)resetTimeFilters {
	self.dateComponents = [[ZDateComponents new] autorelease];
	[self.dateComponents reset];
}

#pragma mark - debug

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@:%p>ID:'%@'; usr:'%@'; sess:'%@'; apns:'%@';\ndateComponents:%@",
			[self class], self, self.ID, self.username, self.sessionID, self.apnsToken, self.dateComponents];
}

@end
