//
//  ZNewMessageModel.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/24/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZPersonModel;

@interface ZNewMessageModel : NSObject
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *privacy;
@property (nonatomic, retain) NSString *imagePath;
@property (nonatomic, retain) NSString *sLatitude;
@property (nonatomic, retain) NSString *sLongitude;

- (BOOL)isValid;
@end

