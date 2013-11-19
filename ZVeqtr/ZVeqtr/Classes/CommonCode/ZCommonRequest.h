//
//  ZCommonRequest.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ASIFormDataRequest.h"

@class ZUserModel;
@class ZNewMessageModel;

@interface ZCommonRequest : ASIFormDataRequest
{}

@property (nonatomic, retain) ZUserModel *userModel;

+ (ZCommonRequest *)requestWithActionName:(NSString *)actionName;
+ (ZCommonRequest *)requestWithActionName:(NSString *)actionName arguments:(NSDictionary *)arguments;
+ (ZCommonRequest *)requestLoginUser:(ZUserModel *)usrModel;
+ (ZCommonRequest *)requestRestorePwdUser:(ZUserModel *)usrModel;
+ (ZCommonRequest *)requestRegisterUser:(ZUserModel *)usrModel;
+ (ZCommonRequest *)requestPersonProfileWithID:(NSString *)profileID;
+ (ZCommonRequest *)requestPersonProfileWithUsername:(NSString *)username;
+ (ZCommonRequest *)requestWithNewMessageModel:(ZNewMessageModel *)model;
+ (ZCommonRequest *)requestFBLoginUser:(ZUserModel *)usrModel;

- (void)addPostValuesForKeys:(NSDictionary *)arguments;

- (void)startSynchronous;

+ (void)setLastRequestTimestamp;
+ (NSDate *)lastRequestTimestamp;

@end
