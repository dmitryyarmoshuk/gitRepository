//
//  UserInfo.m
//  Voter
//
//  Created by Khitryk Artsiom on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserInfo.h"

static UserInfo* _sharedInstance;

@implementation UserInfo
@synthesize username = username_, email = email_, zipCode = zipCode_, yearOfBirth = yearOfBirth_, password = password_;
@synthesize categoryID = categoryID_, subCategoryID = subCategoryID_, businessID = businessID_;
@synthesize token = token_;
@synthesize faceBookCallController = faceBookCallController_;
@synthesize isUserLogin = isUserLogin;

+ (UserInfo*)sharedInstance
{
    @synchronized(self)
    {
        if(_sharedInstance == nil )
        {
            _sharedInstance = [[UserInfo alloc] init];
        }
    }
    
    return _sharedInstance;

}

- (id)init
{
    self = [super init];
    _sharedInstance = self;
    
    self.subCategoryID = [[NSMutableArray alloc]init];
    return self;
}

- (void)dealloc
{
    [username_ release];
    [email_ release];
    [zipCode_ release];
    [yearOfBirth_ release];
    [password_ release];
    [categoryID_ release];
    [subCategoryID_ release];
    [businessID_ release];
    [token_ release];
    
    
    [super dealloc];
}

-(void) requestNetworkActivityIndicator {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;    
	netActivityReqs_++;
}

-(void) releaseNetworkActivityIndicator {    
	netActivityReqs_--;
	if(netActivityReqs_ <= 0)
	{
		UIApplication* app = [UIApplication sharedApplication];
		app.networkActivityIndicatorVisible = NO;
	}    
	//failsafe
	if(netActivityReqs_ < 0)
		netActivityReqs_ = 0;
}

@end
