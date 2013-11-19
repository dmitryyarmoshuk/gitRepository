//
//  FBShareUtils.h
//  ZVeqtr
//
//  Created by Maxim on 6/19/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <FacebookSDK/FacebookSDK.h>


@interface FBShareUtils : NSObject

-(FBShareUtils*)sharedUtils;

+(void)shareText:(NSString*)text imageUrl:(NSString*)imageUrl;

@end
 
