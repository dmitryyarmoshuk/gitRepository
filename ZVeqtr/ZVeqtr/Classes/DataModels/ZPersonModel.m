//
//  ZPersonModel.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/15/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZPersonModel.h"
#import "ZMailDataModel.h"

@interface ZPersonModel ()
@property (nonatomic, retain) NSDictionary *debugDict;
@property (nonatomic, retain) NSDictionary *debugDetailedDict;
@property (nonatomic, retain, readwrite) NSString		*ID;
@property (nonatomic, retain, readwrite) NSString		*info;
@property (nonatomic, retain, readwrite) NSString		*lat;
@property (nonatomic, retain, readwrite) NSString		*lon;
@property (nonatomic, retain, readwrite) NSString		*nickname;
@property (nonatomic, retain, readwrite) NSString		*name;
@property (nonatomic, retain, readwrite) NSString		*age;
@property (nonatomic, retain, readwrite) NSString		*rating;
@property (nonatomic, retain, readwrite) NSString		*friendPhonenumber;
@property (nonatomic, retain, readwrite) NSArray		*allImages;
@property (nonatomic, retain) NSString	*youFollow;	//	you_follow
@property (nonatomic, assign, readwrite) BOOL		isFriend;
@end


@implementation ZPersonModel

- (void)dealloc {
	self.ID = nil;
	self.info = nil;
	self.lat = nil;
	self.lon = nil;
	self.nickname = nil;
	self.name = nil;
	self.age = nil;
	self.rating = nil;
	self.friendPhonenumber = nil;
	self.allImages = nil;
	self.debugDict = nil;
	self.debugDetailedDict = nil;
    self.customFields = nil;

	[super dealloc];
}

+ (ZPersonModel *)modelWithDictionary:(NSDictionary *)dic {
	ZPersonModel *model = [[self new] autorelease];
	[model applyDictionary:dic];
	return model;
}

+ (ZPersonModel *)modelWithID:(NSString *)ID {
	ZPersonModel *model = [[self new] autorelease];
	model.ID = ID;
	return model;
}


- (void)applyDictionary:(NSDictionary *)dic {
	self.debugDict = dic;
	
	self.ID			= CHECK_STRING(dic[@"id"]);
    self.lat		= CHECK_STRING(dic[@"lat"]);
    self.lon		= CHECK_STRING(dic[@"lon"]);
    self.nickname	= CHECK_STRING(dic[@"nickname"]);
    self.name		= CHECK_STRING(dic[@"name"]);
	self.age		= CHECK_STRING(dic[@"age"]);
	self.rating		= CHECK_STRING(dic[@"rating"]);
	self.friendPhonenumber = CHECK_STRING(dic[@"friend_phonenumber"]);

    /*
    if(!self.customFields)
    {
        self.customFields = [NSMutableDictionary dictionary];
    }
    
    for(int i=1; i<=10; i++)
    {
        NSString *customStringFmt = [NSString stringWithFormat:@"ln%d", i];
        NSString *customStringVisibleFmt = [NSString stringWithFormat:@"ln%d_v", i];
        
        NSString *customString = CHECK_STRING(dic[customStringFmt]);
        NSString *customStringVisible = CHECK_STRING(dic[customStringVisibleFmt]);
        
        [self.customFields setValue:customString forKey:customStringFmt];
        [self.customFields setValue:customStringVisible forKey:customStringVisibleFmt];
    }
     */
    
	//	images array
	NSMutableArray *arrImg = [NSMutableArray arrayWithCapacity:8];
	for (int i=1; i < 6; ++i) {
		NSString *key = [NSString stringWithFormat:@"img%d", i];
		NSString *val = dic[key];
		if (val.length) {
			[arrImg addObject:val];
		}
	}
	self.allImages = arrImg.count ? arrImg : nil;
	
	//	info array
	NSMutableArray *arrInfo = [NSMutableArray arrayWithCapacity:12];
	for (int i=1; i < 11; ++i) {
		NSString *key = [NSString stringWithFormat:@"ln%d", i];
		NSString *val = dic[key];
		if (val.length) {
			[arrInfo addObject:val];
		}
	}
	self.info = arrInfo.count ? [arrInfo componentsJoinedByString:@" "] : nil;
	
	if ([self.ID integerValue]==0) {
		LLog(@"Wrong ID (%@)", self.ID);
		;
	}
}

- (void)updateWithDetailedInfoDictionary:(NSDictionary *)dict {
	self.debugDetailedDict = dict;

	if (dict[@"id"]) {
		self.ID = CHECK_STRING(dict[@"id"]);
	}
	self.name = CHECK_STRING(dict[@"name"]);
	self.nickname = CHECK_STRING(dict[@"nickname"]);
	self.email = CHECK_STRING(dict[@"email"]);
	self.follow = CHECK_STRING(dict[@"folow"]);
	self.followers = CHECK_STRING(dict[@"folowers"]);
    self.friends = CHECK_STRING(dict[@"friends"]);
    
    self.customFields = [dict objectForKey:@"lines"];
    
	self.hashtags = dict[@"hash_tags"];
	if (self.hashtags.count == 0)
    {
		self.hashtags = nil;
	}
    
	self.img1 = CHECK_STRING(dict[@"img1"]);
	self.postCount = CHECK_STRING(dict[@"post_cnt"]);
	self.youFollow = CHECK_STRING(dict[@"you_folow"]);
	self.rating = CHECK_STRING(dict[@"rating"]);
	self.isFriend = [dict[@"is_friend"] boolValue];

	NSArray *arrLatestPosts = dict[@"latest_post"];
	NSMutableArray *messages = [NSMutableArray arrayWithCapacity:[arrLatestPosts count]];
	for (NSDictionary *d in arrLatestPosts) {
		ZMailDataModel *msgModel = [ZMailDataModel mailDataModelWithDictionary:d];
		if (msgModel) {
			[messages addObject:msgModel];
		}
	}
	self.latestPosts = messages.count ? messages : nil;
}

- (BOOL)isFollow {
	return [self.youFollow boolValue];
}

- (void)setIsFollow:(BOOL)follow {
	self.youFollow = follow ? @"1" : @"0";
}

- (NSString *)img {
	return self.allImages.count ? self.allImages[0] : nil;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude	= self.lat ? [self.lat doubleValue] : 360;
    theCoordinate.longitude = self.lon ? [self.lon doubleValue] : 360;
    return theCoordinate;
}

- (void)setAbsentID:(NSString *)ID {
	if (!self.ID) {
		self.ID = ID;
	}
}

- (NSString *)title {
	return  self.nickname ? self.nickname : self.name;
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[self class]]) {
		ZPersonModel *model2 = (ZPersonModel *)object;
		return [self.ID isEqualToString:model2.ID];
	}
	return NO;
}

#pragma mark -

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@:%p>\nid:'%@'; img:'%@'; info:'%@'; lat/lon:'%@/%@'; nick:'%@'; name:'%@'; is %@;",
			[self class], self,
			self.ID,
			self.img,
			self.info,
			self.lat,
			self.lon,
			self.nickname,
			self.name,
			self.isFriend ? @"friend":@"no friend"
			];
}

@end
