//
//  NSURL+ZVeqtr.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/15/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "NSURL+ZVeqtr.h"

@implementation NSURL (ZVeqtr)

NSString *const ServerRootSURL = @"http://veqtr.com/iphone/";
NSString *const urlPersonProfileImage = @"http://veqtr.com/image/user/{0}/1.jpg";
NSString *const urlPlaceImage = @"http://veqtr.com/image/place/full_{0}.jpg";
NSString *const urlMailImageThumb = @"http://veqtr.com/image/comments/thumb_{0}.jpg";
NSString *const urlMailImageFull = @"http://veqtr.com/image/comments/full_{0}.jpg";

NSString *const urlVenueMessageImageThumb = @"http://veqtr.com/image/venue/comments/thumb_{0}.jpg";
NSString *const urlVenueMessageImageFull = @"http://veqtr.com/image/venue/comments/full_{0}.jpg";

NSString *const urlSailImageFull = @"http://veqtr.com";
NSString *const urlSaleThumbnail = @"http://veqtr.com";


+ (NSURL *)urlWithActionString:(NSString *)actionName {
	if (!actionName.length) {
		return nil;
	}
	NSString *surl = [ServerRootSURL stringByAppendingFormat:@"%@.php", actionName];
	return [NSURL URLWithString:surl];
}

+ (NSURL *)urlWithActionString:(NSString *)actionName arguments:(NSDictionary *)arguments {
	NSMutableArray *components = [NSMutableArray arrayWithCapacity:8];
	for (NSString *key in arguments) {
		NSString *component = [NSString stringWithFormat:@"%@=%@", key, arguments[key]];
		[components addObject:component];
	}
	NSString *argString = [components componentsJoinedByString:@"&"];
	NSString *surl = [NSString stringWithFormat:@"%@%@.php?%@", ServerRootSURL, actionName, argString];
	return [NSURL URLWithString:surl];
}

+ (NSURL *)urlPersonProfileImageWithID:(NSString *)personID {
	if (personID.length == 0) {
		LLog(@"NO personID");
		return nil;
	}
	NSString *surl = [urlPersonProfileImage stringByReplacingOccurrencesOfString:@"{0}"
																	  withString:personID];
	return [NSURL URLWithString:surl];
}

+ (NSURL *)urlThumbMailImageWithID:(NSString *)mailID {
	if (mailID.length == 0) {
		LLog(@"NO mailID");
		return nil;
	}
    
	NSString *surl = [urlMailImageThumb stringByReplacingOccurrencesOfString:@"{0}"
																	  withString:mailID];
    LLog(@"%@", surl);
	return [NSURL URLWithString:surl];
}

+ (NSURL *)urlThumbVenueMessageImageWithID:(NSString *)messageID {
	if (messageID.length == 0) {
		LLog(@"NO mailID");
		return nil;
	}
    
	NSString *surl = [urlVenueMessageImageThumb stringByReplacingOccurrencesOfString:@"{0}"
                                                                  withString:messageID];
    LLog(@"%@", surl);
	return [NSURL URLWithString:surl];
}


+ (NSURL *)urlFullMailImageWithID:(NSString *)mailID {
	if (mailID.length == 0) {
		LLog(@"NO mailID");
		return nil;
	}
	NSString *surl = [urlMailImageFull stringByReplacingOccurrencesOfString:@"{0}"
                                                                  withString:mailID];
	return [NSURL URLWithString:surl];
}

+ (NSURL *)urlFullVenueMessageImageWithID:(NSString *)messageID {
	if (messageID.length == 0) {
		LLog(@"NO mailID");
		return nil;
	}
	NSString *surl = [urlVenueMessageImageFull stringByReplacingOccurrencesOfString:@"{0}"
                                                                 withString:messageID];
	return [NSURL URLWithString:surl];
}

+ (NSURL *)urlPlaceImageWithID:(NSString *)placeID {
	if (placeID.length == 0) {
		LLog(@"NO placeID");
		return nil;
	}
	NSString *surl = [urlPlaceImage stringByReplacingOccurrencesOfString:@"{0}"
															  withString:placeID];
	return [NSURL URLWithString:surl];
}

+ (NSURL *)urlSaleImageFull:(NSString *)relativeUrl
{
	if (relativeUrl.length == 0)
    {
		LLog(@"NO relative url");
		return nil;
	}
    
	NSString *surl = [urlSailImageFull stringByAppendingPathComponent:relativeUrl];

	return [NSURL URLWithString:surl];
}

+ (NSURL *)urlSaleThumbnail:(NSString *)relativeUrl
{
	if (relativeUrl.length == 0)
    {
		LLog(@"NO relative url");
		return nil;
	}
    
	NSString *surl = [urlSaleThumbnail stringByAppendingPathComponent:relativeUrl];
    
	return [NSURL URLWithString:surl];
}

@end
