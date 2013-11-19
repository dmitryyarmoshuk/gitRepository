//
//  ZCommonRequest.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZCommonRequest.h"
#import "ZNewMessageModel.h"
#import "HomeViewController.h"

@interface ASIFormDataRequest (reveal_private_methods)
- (NSArray *)fileData;
@end


@implementation ZCommonRequest

static NSDate	*lastRequestTimestamp = nil;
static NSLock	*lock = nil;

+ (void)initialize {
	if (self == [ZCommonRequest class]) {
		lock = [NSLock new];
	}
}

+ (void)setLastRequestTimestamp {
	[lock lock];
	[lastRequestTimestamp release];
	lastRequestTimestamp = [[NSDate date] retain];
	[lock unlock];
}

+ (NSDate *)lastRequestTimestamp {
	NSDate *date = nil;
	[lock lock];
	date = [[lastRequestTimestamp copy] autorelease];
	[lock unlock];
	return date;
}

+ (ZCommonRequest *)requestWithActionName:(NSString *)actionName {
	if (!actionName) {
		LLog(@"NO action name");
		return nil;
	}
	ZCommonRequest *rq = [ZCommonRequest requestWithURL:[NSURL urlWithActionString:actionName]];
	NSString *sessionID = APP_DLG.sessionID;
	if (sessionID) {
		[rq setPostValue:sessionID forKey:@"sess_id"];
	}
	rq.responseEncoding = NSUTF8StringEncoding;
	return rq;
}

+ (ZCommonRequest *)requestWithActionName:(NSString *)actionName arguments:(NSDictionary *)arguments
{
	if (!actionName)
    {
		LLog(@"NO action name");
		return nil;
	}
    
	NSURL *url = [NSURL urlWithActionString:actionName];
	ZCommonRequest *rq = [ZCommonRequest requestWithURL:url];
	for (NSString *key in arguments)
    {
		[rq setPostValue:arguments[key] forKey:key];
	}
    
	NSString *sessionID = APP_DLG.sessionID;
	if (sessionID)
    {
		[rq setPostValue:sessionID forKey:@"sess_id"];
	}
    
	rq.responseEncoding = NSUTF8StringEncoding;
	return rq;
}

+ (ZCommonRequest *)requestLoginUser:(ZUserModel *)usrModel
{	
	ZCommonRequest *rq = [self requestWithActionName:@"auth"];
	rq.userModel = usrModel;
	[rq setPostValue:@"login" forKey:@"action"];
	[rq setPostValue:usrModel.username forKey:@"login"];
	[rq setPostValue:usrModel.pwd forKey:@"password"];
	
	return rq;
}

+ (ZCommonRequest *)requestFBLoginUser:(ZUserModel *)usrModel
{
	ZCommonRequest *rq = [self requestWithActionName:@"auth"];
	rq.userModel = usrModel;
	[rq setPostValue:@"login_fb" forKey:@"action"];
	[rq setPostValue:usrModel.facebookUsername forKey:@"fb_account"];
	
	return rq;
}

+ (ZCommonRequest *)requestRestorePwdUser:(ZUserModel *)usrModel
{	
	ZCommonRequest *rq = [self requestWithActionName:@"auth"];
	rq.userModel = usrModel;
	[rq setPostValue:@"forgot" forKey:@"action"];
	[rq setPostValue:usrModel.username forKey:@"login"];
	
	return rq;
}

+ (ZCommonRequest *)requestRegisterUser:(ZUserModel *)usrModel {
	
	ZCommonRequest *rq = [self requestWithActionName:@"auth"];
	rq.userModel = usrModel;
	[rq setPostValue:@"register" forKey:@"action"];
	[rq setPostValue:usrModel.username forKey:@"login"];
	[rq setPostValue:usrModel.pwd forKey:@"password"];
	[rq setPostValue:usrModel.email forKey:@"email"];
//	NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
    
//  NSLog(@"1 = (%@)",[[UIDevice currentDevice] uniqueIdentifier]);
//  NSLog(@"2 = (%@)",[[UIDevice currentDevice] identifierForVendor]);
    NSString *udid = (NSString *)[[UIDevice currentDevice] identifierForVendor];
/// udid = @"00000000000010008000000c2925a02a00000123"; //make custom udid
    
    NSLog(@"udid = (%@)",udid);
	[rq setPostValue:udid forKey:@"udid"];
	
	return rq;
}

+ (ZCommonRequest *)requestPersonProfileWithID:(NSString *)profileID {
	
	if (!profileID) {
		LLog(@"NO profile id");
		return nil;
	}
	NSString *sessionID = APP_DLG.currentUser.sessionID;
	if (!sessionID) {
		LLog(@"NO session");
		return nil;
	}
	NSDictionary *arguments = @{@"user_id" : profileID, @"sess_id" : sessionID};
	ZCommonRequest *rq = [self requestWithActionName:@"user_info" arguments:arguments];
	
	return rq;
}

+ (ZCommonRequest *)requestPersonProfileWithUsername:(NSString *)username {
	
	if (!username) {
		LLog(@"NO profile username");
		return nil;
	}
	NSString *sessionID = APP_DLG.currentUser.sessionID;
	if (!sessionID) {
		LLog(@"NO session");
		return nil;
	}
	NSDictionary *arguments = @{@"nickname" : username, @"sess_id" : sessionID};
	ZCommonRequest *rq = [self requestWithActionName:@"user_info" arguments:arguments];
	
	return rq;
}

+ (ZCommonRequest *)requestWithNewMessageModel:(ZNewMessageModel *)model {
	
	if (![model isValid]) {
		LLog(@"invalid model");
		return nil;
	}

	ZCommonRequest *request = [self requestWithActionName:@"save"];
	
	[request setPostValue:@"1" forKey:@"place"];
	[request setPostValue:model.title   forKey:@"title"];
	[request setPostValue:model.message forKey:@"description"];
	[request setPostValue:model.privacy forKey:@"privacy"];
	[request setPostValue:model.sLatitude forKey:@"lat"];
	[request setPostValue:model.sLongitude forKey:@"lon"];
	
	if (model.imagePath && [[NSFileManager defaultManager] fileExistsAtPath:model.imagePath]) {
		[request setFile:model.imagePath forKey:@"image"];
	}
	
	return request;
}

#pragma mark - 

- (void)startSynchronous {
	printf("  >>URL:'%s'\n", [url.absoluteString cStringUsingEncoding:NSUTF8StringEncoding]);
	NSArray *arr = postData;
	for (NSDictionary *d in arr) {
		NSString *s = [NSString stringWithFormat:@"'%@' = '%@'", d[@"key"], d[@"value"]];
		printf("%s\n", [s cStringUsingEncoding:NSUTF8StringEncoding]);
	}
	NSArray *fData = [self fileData];
	if (fData.count) {
		NSString *s = [fData description];
//		printf("File Data: %s\n", [s cStringUsingEncoding:NSUTF8StringEncoding]);
	}
	
//	printf("<<<startSynchronous=================Start>>>>\n");
	[[self class] setLastRequestTimestamp];
	[super startSynchronous];
//	printf("<<<startSynchronous=================Finish>>>\nRESULT(or err): '%s'\n", self.error ? [self.error.localizedDescription cStringUsingEncoding:NSUTF8StringEncoding] : [self.responseString cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if([self.responseString isEqualToString:@"status=auth_error"])
    {
        //do logout
        [APP_DLG.homeViewController doLogout:NO];
    }
}

- (void)addPostValuesForKeys:(NSDictionary *)arguments {
	for (NSString *key in arguments) {
		[self setPostValue:arguments[key] forKey:key];
	}
}

@end
