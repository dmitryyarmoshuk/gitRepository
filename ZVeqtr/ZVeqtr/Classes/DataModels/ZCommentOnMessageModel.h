//
//  ZMessageModel.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZCommentOnMessageModel : NSObject
{}

+ (ZCommentOnMessageModel *)modelWithDictionary:(NSDictionary *)dict;

//	short representation
@property (nonatomic, retain, readonly) NSString	*ID;
@property (nonatomic, retain, readonly) NSString	*userID;
@property (nonatomic, retain, readonly) NSString	*descript;
//	filtered descript
@property (nonatomic, readonly)			NSString	*text;

//	long representation
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, retain) NSString *lat;
@property (nonatomic, retain) NSString *lon;
@property (nonatomic, retain) NSString *rating;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *privacy;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, readonly) BOOL hasImage;

@property (nonatomic, retain) UIImage	*image;

- (NSString *)pathPicture;

- (BOOL)isEqual:(id)object;

@end


/*	long representation:
 {
 date = "2012-10-23 15:31:58";
 description = "Hello my dear";
 id = 60;
 image = 1;
 lat = "49.95829";
 location = "";
 lon = "36.17798";
 privacy = 0;
 status = 0;
 title = subject;
 "user_id" = 53;
 },
 */
