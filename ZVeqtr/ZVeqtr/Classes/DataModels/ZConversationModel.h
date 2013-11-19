//
//  ZConversationModel.h
//  ZVeqtr
//
//  Created by Maxim on 6/21/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZConversationModel : NSObject

@property (nonatomic, retain) NSString		*name;
@property (nonatomic, retain) NSString		*ID;
@property (nonatomic, retain) NSString		*user_id;
@property (nonatomic, retain) NSString		*rating;

@property (nonatomic, retain) NSString		*address; //zs
@property (nonatomic, retain) NSString		*title;


+ (ZConversationModel *)modelWithDictionary:(NSDictionary *)dataDict;
+ (ZConversationModel *)modelWithID:(NSString *)ID;

- (BOOL)applyDictionary:(NSDictionary *)dataDict;

@end
