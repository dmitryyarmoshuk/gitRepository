//
//  ZConversationModel.m
//  ZVeqtr
//
//  Created by Maxim on 6/21/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZConversationModel.h"

@implementation ZConversationModel



- (void)dealloc {
	[super dealloc];
}

+ (ZConversationModel *)modelWithDictionary:(NSDictionary *)dataDict {
	ZConversationModel *model = [[self new] autorelease];
	if ([model applyDictionary:dataDict]) {
		return model;
	}
	return nil;
}

+ (ZConversationModel *)modelWithID:(NSString *)ID {
	ZConversationModel *model = [[self new] autorelease];
	model.ID = ID;
	return model;
}

- (BOOL)applyDictionary:(NSDictionary *)dataDict {
	if (![dataDict isKindOfClass:[NSDictionary class]]) {
		LLog(@"Wrong argument (%@)", dataDict);
		return NO;
	}
	
	self.title = dataDict[@"title"];
    self.ID = dataDict[@"id"];
    if(!self.ID)
        self.ID = dataDict[@"convers_id"];
    
    self.user_id = dataDict[@"user_id"];
//    NSLog(@"%@",dataDict);
//    id rat = dataDict[@"rating"];
//    Class cls = [rat class];
//    NSString *s = NSStringFromClass(cls);
    NSNumber *srat = dataDict[@"rating"];
    self.rating = [srat stringValue];
    
    self.address = dataDict[@"address"]; //zs - for venue conversation
    self.name = dataDict[@"name"]; 
    
	return YES;
}

#pragma mark -

-(NSString*)title
{
    return _title;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"description"];
}

@end
