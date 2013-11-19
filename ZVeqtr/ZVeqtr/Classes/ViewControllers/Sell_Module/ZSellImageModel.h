//
//  ZSellImageModel.h
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZGarageSaleModel.h"

@interface ZSellImageModel : NSObject

@property (nonatomic, retain) NSString		*position;
@property (nonatomic, retain) NSString		*description;
@property (nonatomic, retain) NSString		*urlString;
@property (nonatomic, retain) NSString		*status;
@property (nonatomic, retain) NSString		*ID;

@property (nonatomic, assign) BOOL          isNew;
@property (nonatomic, assign) BOOL          isDeleted;

@property (nonatomic, retain) UIImage		*image;

@property (nonatomic, retain) ZGarageSaleModel *garageSaleModel;

- (NSString *)pathPicture;

+ (void)clearAllCachedImages;
+ (ZSellImageModel *)newModel;
+ (ZSellImageModel *)modelWithDictionary:(NSDictionary *)dataDict;

- (BOOL)applyDictionary:(NSDictionary *)dataDict;

- (BOOL)isEqual:(id)object;

@end
