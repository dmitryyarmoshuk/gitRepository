//
//  FBSession.h
//  VoterTest
//
//  Created by User User on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
//#import "Facebook.h"

@protocol FBSeccionDelegate <NSObject>
@optional
- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date;
- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date withInfo:(NSDictionary*)result;
@end


@interface FBSession : NSObject <FBRequestDelegate,FBDialogDelegate,FBSessionDelegate>

@property(nonatomic, assign)   Facebook *facebook;
@property(nonatomic, retain)   NSArray *permissions;
@property(nonatomic, retain)   NSMutableDictionary *result;
@property(nonatomic, assign)   id<FBSeccionDelegate> delegate;

- (id)initWithDelegate:(id<FBSeccionDelegate>)delegate; 
- (void)facebookLogin;
- (void)facebookLogout;
- (void)facebookGetInfo;
- (void)facebookGetPicture;

- (void)publishFBStream:(NSString*)text;
- (void)publishImageFBStream:(NSString*)text imageUrl:(NSString*)imageUrl;

@end


