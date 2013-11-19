//
//  ZMessageModel.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZCommentOnMessageModel.h"
#import "NSString+ZVeqtr.h"

@interface ZCommentOnMessageModel ()
@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, retain) NSDictionary *dataDictionary;
@property (nonatomic, retain, readwrite) NSString	*ID;
@property (nonatomic, retain, readwrite) NSString	*userID;
@property (nonatomic, retain, readwrite) NSString	*descript;
@property (nonatomic, retain, readwrite) NSString	*dateString;
@property (nonatomic, retain) NSString *strHasImage;
@end


@implementation ZCommentOnMessageModel

- (void)dealloc {
	self.dataArray = nil;
	[super dealloc];
}


+ (ZCommentOnMessageModel *)modelWithDictionary:(NSDictionary *)dict {
	
	if (!dict) {
		LLog(@"NO dict");
		return nil;
	}
	
	ZCommentOnMessageModel *model = [self new];
	model.dataDictionary = dict;
	
	model.ID = CHECK_STRING(model.dataDictionary[@"id"]);
	model.userID = CHECK_STRING(model.dataDictionary[@"user_id"]);
	model.rating = CHECK_STRING(model.dataDictionary[@"rating"]);
	model.descript = CHECK_STRING(model.dataDictionary[@"description"]);
	
    if (!model.descript)
    {
		model.descript = CHECK_STRING(model.dataDictionary[@"text"]);
	}
	model.dateString = CHECK_STRING(model.dataDictionary[@"date"]);
	
	model.lat = CHECK_STRING(model.dataDictionary[@"lat"]);
	model.lon = CHECK_STRING(model.dataDictionary[@"lon"]);
	model.location = CHECK_STRING(model.dataDictionary[@"location"]);
	model.strHasImage = CHECK_STRING(model.dataDictionary[@"image"]);
	model.privacy = CHECK_STRING(model.dataDictionary[@"privacy"]);
	model.status = CHECK_STRING(model.dataDictionary[@"status"]);
	model.title = CHECK_STRING(model.dataDictionary[@"title"]);
    model.username = CHECK_STRING(model.dataDictionary[@"nickname"]);
    
	return [model autorelease];
}

- (BOOL)hasImage {
	return [self.strHasImage boolValue];
}

- (NSDate *)date {
	LLog(@"//TODO: parse:'%@'", self.dateString);
	return nil;
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[self class]]) {
		ZCommentOnMessageModel *model2 = (ZCommentOnMessageModel *)object;
		return [self.ID isEqualToString:model2.ID];
	}
	return NO;
}

- (NSString *)text {
	return [self.descript stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@:%p> txt:%@",
			[self class], self, self.text];
}

- (NSString *)pathPicture {
	return [@"message_comment_image.jpg" docPath];
}

- (void)setImage:(UIImage *)image {
	NSData *imgData = UIImageJPEGRepresentation(image, 0.8);
	NSString *path = [self pathPicture];
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
	BOOL isOK = [imgData writeToFile:path atomically:YES];
	if (!isOK) {
		LLog(@"Cannot save image at path '%@'", path);
	}
}

- (UIImage *)image {
	NSString *picFile = [self pathPicture];
	LLog(@"%@", picFile);
	NSData *imgData = [NSData dataWithContentsOfFile:picFile];
	return imgData ? [UIImage imageWithData:imgData] : nil;
}

@end
