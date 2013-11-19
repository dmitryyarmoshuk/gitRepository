//
//  FBShareUtils.m
//  ZVeqtr
//
//  Created by Maxim on 6/19/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//



#import "FBShareUtils.h"

FBShareUtils *utils;

@implementation FBShareUtils

-(FBShareUtils*)sharedUtils
{
    if(!utils)
    {
        utils = [[FBShareUtils alloc] init];
    }
    
    return utils;
}


+(void)shareText:(NSString*)text imageUrl:(NSString*)imageUrl
{
    if(!text && !imageUrl)
        return;
/*
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error)
     {
         if (error)
         {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:error.localizedDescription
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
             [alertView show];
         }
         else if (session.isOpen)
         {
             NSLog(@"session.isOpen");
             if ([FBSession.activeSession.permissions
                  indexOfObject:@"publish_actions"] == NSNotFound)
             {
                 // No permissions found in session, ask for it
                 [FBSession.activeSession
                  requestNewPublishPermissions:
                  [NSArray arrayWithObject:@"publish_actions"]
                  defaultAudience:FBSessionDefaultAudienceFriends
                  completionHandler:^(FBSession *session, NSError *error) {
                      if (!error) {
                          // If permissions granted, publish the story
                          NSLog(@"permissions granted");
                          //[self publishStory:text imageUrl:imageUrl];
                          //[self test2:text image:image];
                      }
                      else
                      {
                          NSLog(@"%@", error.localizedDescription);
                      }
                  }];
             } else
             {
                 NSLog(@"permissions presented");
                 // If permissions present, publish the story
                 [self publishStory:text imageUrl:imageUrl];
                 //[self test2:text image:image];
             }
         }
     }];
*/
    
}

/*
+ (void)publishStory:(NSString*)text imageUrl:(NSString*)imageUrl
{
    NSMutableDictionary *postParams = nil;
    
    if(imageUrl)
    {
        postParams =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         //@"http://www.zveqtr.com", @"link",
         imageUrl, @"picture",
         //@"Message from Veqtr app", @"name",
         //text, @"caption",
         text, @"message",
         nil];
    }
    else
    {
        postParams =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         //@"http://www.zveqtr.com", @"link",
         //@"https://developers.facebook.com/attachment/iossdk_logo.png", @"picture",
         //@"Message from Veqtr app", @"name",
         //@"Message from Veqtr app", @"caption",
         text, @"message",
         nil];
    }
    
    //[self.postParams setObject:self.postMessageTextView.text forKey:@"message"];
*/    
    /*
    postParams =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     //@"https://developers.facebook.com/ios", @"link",
     @"https://developers.facebook.com/attachment/iossdk_logo.png", @"picture",
     @"Facebook SDK for iOS", @"name",
     @"Build great social apps and get more installs.", @"caption",
     @"The Facebook SDK for iOS makes it easier and faster to develop Facebook integrated iOS apps.", @"description",
     nil];
    */



/* zs

    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:postParams
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         NSString *alertText;
         if (error)
         {
             if(error.code == 5)
             {
                 alertText = [NSString stringWithFormat:
                              @"You have reached limits of updates for that particular user or tring to publish the same post. Please, try again later.."];
             }
             else
                 alertText = error.localizedDescription;
             
         } else {
             alertText = [NSString stringWithFormat:
                          @"Message has been added to your wall"];
         }
         // Show the result in an alert
         [[[UIAlertView alloc] initWithTitle:nil
                                     message:alertText
                                    delegate:self
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]
          show];
     }];
}
*/

 
@end

