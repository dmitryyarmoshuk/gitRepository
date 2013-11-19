//
//  ZNotificationModel.h
//  ZVeqtr
//
//  Created by Maxim on 2/13/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const kNTComments;
NSString *const kNTCommentConversation;

NSString *const kNTPrivateMessages;

NSString *const kNTLegitPosts;
NSString *const kNTLegitConversation;
NSString *const kNTLegitComments;
NSString *const kNTLegitCommentsConversation;

NSString *const kNTCommentSale;

NSString *const kNTFriendRequest;

NSString *const kNTFriendFollowers;


@interface ZNotificationModel : NSObject

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *creatorId;
@property (nonatomic, retain) NSString *actionType;
@property (nonatomic, retain) NSString *postId;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *date;

- (NSString *)actionText;
+ (ZNotificationModel *)notificationModelWithDictionary:(NSDictionary *)dict;

@end
