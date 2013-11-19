//
//  ZLocationModel.h
//  ZVeqtr
//
//  Created by Lee Loo on 10/17/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>

//	it describes a certain location, is used for favourite location
@interface ZLocationModel : NSObject
{}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;

- (NSDictionary *)dictionaryRepresentation;
- (NSString *)stringRepresentation;
+ (ZLocationModel *)locationModelWithDictionary:(NSDictionary *)dict;

@end
