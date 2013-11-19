//
//  ZFavoriteFilterModel.m
//  ZVeqtr
//
//  Created by Maxim on 1/24/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZFavoriteFilterModel.h"
#import "ZDateComponents.h"

@implementation ZFavoriteFilterModel

- (NSString *)pathPicture
{
    NSString *pictName = [NSString stringWithFormat:@"UserFilterImage_ID_%@.png", self.id];
    
	return [pictName docPath];
}

-(void)deleteImage
{
    NSString *path = [self pathPicture];
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (BOOL)hasImage {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self pathPicture]];
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

- (void)dealloc {
	self.dateComponents = nil;
	self.type = nil;
    self.title = nil;
    
	[super dealloc];
}

- (NSDictionary *)dictionaryRepresentation {
	NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:8];
	if (self.title) {
		dic[@"title"] = self.title;
	}
	if (self.type) {
		dic[@"type"] = self.type;
	}
    if (self.id) {
		dic[@"id"] = self.id;
	}
    if (self.zipPlace) {
		dic[@"zipPlace"] = self.zipPlace;
	}
    if(self.searchText){
        dic[@"searchText"] = self.searchText;
    }
    if (self.dateComponents) {
        dic[@"dateComponentsDictionary"] = [self.dateComponents dictionaryRepresentation];
		//dic[@"userId"] = [self.dateComponents dic;
	}
    
	return dic;
}

+ (ZFavoriteFilterModel *)modelWithDictionary:(NSDictionary *)dict {
	if (!dict) {
		return nil;
	}
	ZFavoriteFilterModel *model = [[self new] autorelease];
	model.title = dict[@"title"];
	model.type = dict[@"type"];
    model.id = dict[@"id"];
    model.searchText = dict[@"searchText"];
    model.zipPlace = dict[@"zipPlace"];
    model.dateComponents = [ZDateComponents dateComponentsWithDictionary:dict[@"dateComponentsDictionary"]];
    
	return model;
}

- (NSString *)stringRepresentation
{
	return	self.title.length ? self.title : @"noname filter";
}

@end
