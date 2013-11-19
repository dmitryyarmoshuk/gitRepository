//
//  ZFavoriteFilterModel.h
//  ZVeqtr
//
//  Created by Maxim on 1/24/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FILTER_TYPE_LOCATION    @"FILTER_TYPE_LOCATION"
#define FILTER_TYPE_USER        @"FILTER_TYPE_USER"
#define FILTER_TYPE_HASHTAG     @"FILTER_TYPE_HASHTAG"

@class ZDateComponents;

@interface ZFavoriteFilterModel : NSObject

{}

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) ZDateComponents *dateComponents;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, retain) NSDictionary *zipPlace;
@property (nonatomic, retain) UIImage	*image;

//base methods
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)stringRepresentation;
+ (ZFavoriteFilterModel *)modelWithDictionary:(NSDictionary *)dict;

//filter image
-(void)deleteImage;
- (BOOL)hasImage;

@end
