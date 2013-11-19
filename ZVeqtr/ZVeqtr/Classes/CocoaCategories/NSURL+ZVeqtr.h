//
//  NSURL+ZVeqtr.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/15/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const ServerRootSURL;
NSString *const urlPersonProfileImage;

@interface NSURL (ZVeqtr)
+ (NSURL *)urlWithActionString:(NSString *)actionName;
+ (NSURL *)urlWithActionString:(NSString *)actionName arguments:(NSDictionary *)arguments;
+ (NSURL *)urlPersonProfileImageWithID:(NSString *)personID;
+ (NSURL *)urlPlaceImageWithID:(NSString *)placeID;

+ (NSURL *)urlThumbMailImageWithID:(NSString *)mailID;
+ (NSURL *)urlFullMailImageWithID:(NSString *)mailID;

+ (NSURL *)urlThumbVenueMessageImageWithID:(NSString *)messageID;
+ (NSURL *)urlFullVenueMessageImageWithID:(NSString *)messageID;

+ (NSURL *)urlSaleImageFull:(NSString *)relativeUrl;
+ (NSURL *)urlSaleThumbnail:(NSString *)relativeUrl;

@end
