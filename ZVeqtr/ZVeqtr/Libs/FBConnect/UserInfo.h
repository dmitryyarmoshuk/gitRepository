//
//  UserInfo.h
//  Voter
//
//  Created by Khitryk Artsiom on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
{
@private
    
    NSString* username_;
    NSString* email_;
    NSString* zipCode_;
    NSString* yearOfBirth_;
    NSString* password_;
    NSString* categoryID_;
    NSMutableArray* subCategoryID_;
    NSString* businessID_;    
    NSString* token_;
    
    id faceBookCallController_;   
    BOOL isUserLogin;
    int netActivityReqs_;
}

@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* email;      
@property (nonatomic, copy) NSString* zipCode;     
@property (nonatomic, copy) NSString* yearOfBirth; 
@property (nonatomic, copy) NSString* password;  
@property (nonatomic, copy) NSString* categoryID;
@property (nonatomic, retain) NSMutableArray* subCategoryID;
@property (nonatomic, copy) NSString* businessID;
@property (nonatomic, copy) NSString* token;

@property (nonatomic, assign) id faceBookCallController;
@property (nonatomic, assign) BOOL isUserLogin;

+ (UserInfo*)sharedInstance;

-(void) requestNetworkActivityIndicator;
-(void) releaseNetworkActivityIndicator;
@end
