//
//  FBSession.m
//  VoterTest
//
//  Created by User User on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FBConnect.h"

#import "FBSession.h"
//#import "UserInfo.h"

static NSString* kAppId = @"681858481843608";//  @"527673330624606";// @"331663473546996"; //@"681858481843608";

//@interface FBSession (FaceBookConnect)
//@end


//======================================================================================================
@implementation FBSession
@synthesize facebook = _facebook;
@synthesize permissions = _permissions;
@synthesize delegate = _delegate;
@synthesize result = _result;

/*
@"read_stream",
@"offline_access",
@"read_friendlists",
@"user_relationships",
@"user_likes",
@"user_about_me",
@"user_birthday",
@"user_activities",
@"friends_relationships",
@"user_relationship_details",
@"friends_relationship_details",
@"friends_birthday",
@"user_videos",
@"video_upload"
*/

/*
@"user_likes",
@"user_birthday",
@"email",
@"publish_stream",
@"publish_actions",
@"user_photos",
@"friends_photos",
*/
- (id)initWithDelegate:(id<FBSeccionDelegate>) delegate;
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
//      self.permissions = [NSArray arrayWithObjects:@"read_stream", @"offline_access", nil];
        self.permissions = [NSArray arrayWithObjects:@"offline_access",@"publish_stream",@"publish_actions",@"user_about_me",@"user_photos", nil];
        self.result = [[NSMutableDictionary alloc] initWithCapacity:25];
    }
    return self;
}

- (void)dealloc
{

    NSLog(@"---dealloc FBSession - logout!!!");
    
    [self facebookLogout];
    
    
    self.permissions = nil;  
    self.result = nil;
    [_facebook release];
    
    [super dealloc];
}


//============================================================================================
#pragma mark - Facebook API get back
- (void)fbDidLogin {
    NSLog(@">!fbAPI!>_fbDidLogin");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize]; 
    if ([self.delegate respondsToSelector:@selector(fbDidLogin:expDate:)])
    {
//      [self facebookGetInfo];
        [self.delegate fbDidLogin:[_facebook accessToken] expDate:[_facebook expirationDate]];
    }
//    [[UserInfo sharedInstance] releaseNetworkActivityIndicator];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@">!fbAPI!>_fbDid_Not_Login cancel:%d",cancelled);
//    [[UserInfo sharedInstance] releaseNetworkActivityIndicator];
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    NSLog(@">!fbAPI!>_fbDidLogout");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }    
//    [[UserInfo sharedInstance] releaseNetworkActivityIndicator];
}


- (void)request:(FBRequest *)request didLoad:(id)result {
    
    NSLog(@">!fbAPI!>_request");

    NSDictionary *res = (NSDictionary*)result;
//  NSLog(@"++request didLoad:%@",res);
//    NSString *email = [res valueForKey:@"email"];
//    NSString *name = [res valueForKey:@"name"];    
    if ([self.delegate respondsToSelector:@selector(fbDidLogin:expDate:withInfo:)])
    {
        [self.delegate fbDidLogin:[_facebook accessToken] expDate:[_facebook expirationDate] withInfo:res];
    }
}



- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    NSLog(@">!fbAPI!>_fbDidExtendToken"); 
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    NSLog(@">!fbAPI!>_fbSessionInvalidated");
}


//==============================================================================
#pragma mark - user functions

- (void)facebookLogin
{
    NSLog(@":+++facebookLogin");

    if (!_facebook)
        _facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }    
    
    if ([_facebook isSessionValid] == NO) {     
    NSLog(@":+facebookLogin : open new session!!");    
        APP_DLG.facebook = _facebook;
//      [[UserInfo sharedInstance] requestNetworkActivityIndicator];
        [_facebook authorize:_permissions];
    } else 
    {
    NSLog(@":+facebookLogin : fb_session is valid - already connected...");    
        if ([self.delegate respondsToSelector:@selector(fbDidLogin:expDate:)])
        {
            [self.delegate fbDidLogin:[_facebook accessToken] expDate:[_facebook expirationDate]];
        }        
    }
}


/**
 * Invalidate the access token and clear the cookie.
 */
- (void)facebookLogout 
{
    NSLog(@":+++facebookLogout");
    [_facebook logout:self];
}

- (void)facebookGetInfo 
{
//  [[UserInfo sharedInstance] requestNetworkActivityIndicator];
    [_facebook requestWithGraphPath:@"me" andDelegate:self];        
}

- (void)facebookGetPicture
{
//  [[UserInfo sharedInstance] requestNetworkActivityIndicator];
    [_facebook requestWithGraphPath:@"me/picture" andDelegate:self];
}


//=======================================================================================================================
- (void)publishFBStream:(NSString*)text  {
//    [self initFacebook];
//    NSLog(@"text=%@",text);
    
    if ([_facebook isSessionValid]) {
        SBJsonWriter *jsonWriter = [[SBJsonWriter new] autorelease];
        
        NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               @"http://veqtr.com/", @"text",                                                               
                                                               @"http://veqtr.com/",@"href",
                                                               nil], nil];        
        NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
        
        
        NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
                                    text, @"name",
                                    @"", @"caption",
//                                  text, @"description",
                                    @"http://veqtr.com/", @"href", nil];
        NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
        
        
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Share on Facebook",  @"user_message_prompt",
                                       actionLinksStr, @"action_links",
                                       attachmentStr, @"attachment",
                                       text, @"message", nil];
        [_facebook dialog: @"stream.publish" //@"feed"
               andParams:params
             andDelegate:self];
        
        
    } else {
//        [self loginToFacebook];
    }
}

- (void)publishImageFBStream:(NSString*)text imageUrl:(NSString*)imageUrl  {
//  [self initFacebook];
//    NSLog(@"text=%@",text);
//    NSLog(@"imageUrl=%@",imageUrl);
    
    if (!imageUrl) {
        [self publishFBStream:text];
        return;
    }
    
    if ([_facebook isSessionValid]) {
        SBJsonWriter *jsonWriter = [[SBJsonWriter new] autorelease];
        
        NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               @"http://veqtr.com/",@"text",
                                                               @"http://veqtr.com/", @"href",
                                                               nil], nil];
        NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
        
        
        NSDictionary* imageShare = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"image", @"type",
                                    imageUrl, @"src",
                                    @"http://veqtr.com/", @"href",
                                    nil];
        
        
        NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
                                    text, @"name",
//                                  @"", @"caption",
//                                  text, @"description",
                                    @"Сообщение1", @"message",
                                    [NSArray arrayWithObjects:imageShare, nil], @"media",
                                    nil];        
        NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
        
        
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Share on Facebook",  @"user_message_prompt",
                                       actionLinksStr, @"action_links",
                                       attachmentStr, @"attachment",
                                       @"Сообщение2", @"message",
                                       nil];
        
        [_facebook dialog: @"stream.publish"
               andParams: params
             andDelegate:self];
       
    } else {
//        [self loginToFacebook];
    }
}



@end
