//
//  ZNotificationModel.m
//  ZVeqtr
//
//  Created by Maxim on 2/13/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZNotificationModel.h"

NSString *const kNTComments = @"comment";
NSString *const kNTCommentConversation = @"comment_convers";

NSString *const kNTPrivateMessages = @"pm";

NSString *const kNTLegitPosts = @"legit_post";
NSString *const kNTLegitConversation = @"legit_convers";
NSString *const kNTLegitComments = @"legit_comment";
NSString *const kNTLegitCommentsConversation = @"legit_comment_convers";

NSString *const kNTCommentSale = @"comment_sale";

NSString *const kNTFriendRequest = @"friend";

NSString *const kNTFriendFollowers = @"follow";


@implementation ZNotificationModel

- (void)dealloc {
	self.nickname = nil;
    self.date = nil;
    self.id = nil;
    self.creatorId = nil;
    self.message = nil;
    
	[super dealloc];
}

+ (ZNotificationModel *)notificationModelWithDictionary:(NSDictionary *)dict {
	if (!dict) {
		return nil;
	}
	ZNotificationModel *model = [[self new] autorelease];
	model.nickname = CHECK_STRING(dict[@"nickname"]);
    model.id = CHECK_STRING(dict[@"id"]);
    model.date = CHECK_STRING(dict[@"date"]);
    model.message = CHECK_STRING(dict[@"text"]);
    model.creatorId = CHECK_STRING(dict[@"creator_id"]);
    model.actionType = CHECK_STRING(dict[@"type"]);
    model.postId = CHECK_STRING(dict[@"place_id"]);

	return model;
}

- (NSString *)actionText
{
    if([self.actionType isEqualToString:kNTFriendFollowers])
    {
        return @"is following you";
    }
    else if([self.actionType isEqualToString:kNTFriendRequest])
    {
        return @"wants to be your friend";
    }
    else if([self.actionType isEqualToString:kNTPrivateMessages])
    {
        return @"sent you private message:";
    }
    else if([self.actionType isEqualToString:kNTComments])
    {
        return @"said:";
    }
    else if([self.actionType isEqualToString:kNTLegitPosts])
    {
        return @"gave you a legit for your post";
    }
    else if([self.actionType isEqualToString:kNTLegitComments])
    {
        return @"gave you a legit for your comment";
    }
    else if([self.actionType isEqualToString:kNTLegitConversation])
    {
        return @"gave you a legit for your conversation";
    }
    else if([self.actionType isEqualToString:kNTLegitCommentsConversation])
    {
        return @"gave you a legit for your comment";
    }
    else if([self.actionType isEqualToString:kNTCommentSale])
    {
        return @"sent comment for sale:";
    }
    else if([self.actionType isEqualToString:kNTCommentConversation])
    {
        return @"sent comment for venue:";
    }
    
	return @"unknown action type";
}

@end
