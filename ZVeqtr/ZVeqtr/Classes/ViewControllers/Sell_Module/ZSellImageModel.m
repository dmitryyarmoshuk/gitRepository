//
//  ZSellImageModel.m
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSellImageModel.h"

@implementation ZSellImageModel

- (void)dealloc
{
    self.image = nil;
    self.position = nil;
    self.description = nil;
    self.urlString = nil;
    self.garageSaleModel = nil;
    
	[super dealloc];
}

+ (ZSellImageModel *)newModel
{
	ZSellImageModel *model = [[self new] autorelease];
	model.isNew = YES;
    model.status = @"0";
    
	return model;
}

+ (ZSellImageModel *)modelWithDictionary:(NSDictionary *)dataDict
{
	ZSellImageModel *model = [[self new] autorelease];
	if ([model applyDictionary:dataDict])
    {
		return model;
	}
    
	return nil;
}

- (BOOL)applyDictionary:(NSDictionary *)dataDict
{
	if (![dataDict isKindOfClass:[NSDictionary class]])
    {
		LLog(@"Wrong argument (%@)", dataDict);
		return NO;
	}
	
	BOOL isOK = NO;
    
	if (dataDict.count > 0)
    {
		self.position = CHECK_STRING(dataDict[@"pos"]);
        self.description = CHECK_STRING(dataDict[@"description"]);
        self.urlString = CHECK_STRING(dataDict[@"url"]);
        self.status = CHECK_STRING(dataDict[@"status"]);
        self.ID = CHECK_STRING(dataDict[@"id"]);
        
		isOK = YES;
	}
    
	return isOK;
}

- (NSString *)pathPicture
{
	return [ZSellImageModel pathPictureForPosition:self.position];
}

+(NSString *)pathPictureForPosition:(NSString*)position
{
	return [[NSString stringWithFormat:@"sale_image_%@", position] docPath];
}

+ (void)clearAllCachedImages
{
    for(int i=0; i<=10; i++)
    {
        NSString *path = [ZSellImageModel pathPictureForPosition:[NSString stringWithFormat:@"%d", i]];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if(error)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

- (void)setImage:(UIImage *)image
{
	NSString *path = [self pathPicture];
    NSLog(@"%@", path);
    NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if(image)
    {
        NSData *imgData = UIImageJPEGRepresentation(image, 0.8);
        
        BOOL isOK = [imgData writeToFile:path atomically:YES];
        if (!isOK)
        {
            LLog(@"Cannot save image at path '%@'", path);
        }
    }
}

- (UIImage *)image
{
	NSString *picFile = [self pathPicture];
    
	LLog(@"%@", picFile);
	
    NSData *imgData = [NSData dataWithContentsOfFile:picFile];
	return imgData ? [UIImage imageWithData:imgData] : nil;
}

#pragma mark -

- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[self class]])
    {
		ZSellImageModel *model2 = (ZSellImageModel *)object;
		return [self.position isEqual:model2.position];
	}
    
	return NO;
}

@end
