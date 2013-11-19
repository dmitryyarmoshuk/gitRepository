//
//  ZPersonModel.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/15/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZVeqtrAnnotation.h"


@interface ZPersonModel : NSObject
<ZVeqtrAnnotation>
{}

@property (nonatomic, retain, readonly) NSString		*ID;
@property (nonatomic, retain, readonly) NSString		*info;
@property (nonatomic, retain, readonly) NSString		*lat;
@property (nonatomic, retain, readonly) NSString		*lon;
@property (nonatomic, retain, readonly) NSString		*nickname;
@property (nonatomic, retain, readonly) NSString		*name;
@property (nonatomic, retain, readonly) NSString		*age;
@property (nonatomic, retain, readonly) NSString		*rating;
@property (nonatomic, retain, readonly) NSString		*friendPhonenumber;
@property (nonatomic, retain, readonly) NSArray			*allImages;
@property (nonatomic, retain) NSArray            *customFields;
@property (nonatomic, readonly) NSString	*img;
@property (nonatomic, readonly) CLLocationCoordinate2D	coordinate;
//
@property (nonatomic, retain) NSString	*email;
@property (nonatomic, retain) NSString	*follow;
@property (nonatomic, retain) NSString	*followers;
@property (nonatomic, retain) NSString	*friends;
@property (nonatomic, retain) NSArray	*hashtags;
@property (nonatomic, retain) NSArray	*latestPosts; //arr of ZMailDataModel
@property (nonatomic, retain) NSString	*img1;
@property (nonatomic, retain) NSString	*postCount;
@property (nonatomic, assign) BOOL		isFollow;	//	you_follow
@property (nonatomic, assign) BOOL		wasUpdated;
@property (nonatomic, assign, readonly) BOOL		isFriend;
@property (nonatomic, readonly) NSString	*title;

+ (ZPersonModel *)modelWithDictionary:(NSDictionary *)dict;
+ (ZPersonModel *)modelWithID:(NSString *)ID;
- (void)updateWithDetailedInfoDictionary:(NSDictionary *)dict;

- (BOOL)isEqual:(id)object;

@end


/*
 email = IvanTheTerrible;
 folow = 3;
 folowers = 0;
 "hash_tags" =     (
 );
 img1 = "1.jpg";
 "latest_post" =     (
.............
 )
 name = "<null>";
 "post_cnt" = 2;
 rating = 0;
 "you_folow" = 0;

 
*/