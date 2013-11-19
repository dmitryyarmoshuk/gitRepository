//
//  ZVenueConversationDetailsVC.m
//  ZVeqtr
//
//  Created by Maxim on 6/21/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZVenueConversationDetailsVC.h"
#import "ZConversationModel.h"
#import "ZVenueModel.h"

#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"

#import "ZVenueConversationVC.h"

@interface ZVenueConversationDetailsVC ()

@end

@implementation ZVenueConversationDetailsVC


- (void)dealloc {
	[super dealloc];
}

- (void)releaseOutlets
{
	[super releaseOutlets];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self presentBackBarButtonItem];
    
    self.title = @"Conversation details";
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(btnSaveConversation_Action)] autorelease];
    
    if(self.conversationModel)
        _textName.text = self.conversationModel.name;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [_textName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnSaveConversation_Action
{
    if(_textName.text)
        [self runRequestSaveConversations];
}

- (void)runRequestSaveConversations
{
    //venues.php?sess_id=[sid]&action=get_convers&venue_id=[venue_id]
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
    [args setObject:self.venueModel.ID forKey:@"venue_id"];
    [args setObject:@"add_convers" forKey:@"action"];
    
    [args setObject:_textName.text forKey:@"title"];
    
    NSString *name = self.venueModel.name;
    NSString *adr = self.venueModel.address;
    [args setObject:name forKey:@"name"];
    if(adr)
        [args setObject:adr forKey:@"address"];
    
    
    [super showProgress];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"venues" arguments:args];
    
	dispatch_async(dispatch_queue_create("request.friends", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
            [super hideProgress];
            
			if (request.error)
            {
                [APP_DLG showAlertWithMessage:request.error.localizedDescription title:@"Request error"];
                
                return;
            }
            
            NSString *responseString = [request responseString];
            NSLog(@"%@", responseString);
            
            self.conversationModel = [ZConversationModel modelWithID:responseString];
            self.conversationModel.name = _textName.text;
            
            ZVenueConversationVC *ctrl = [ZVenueConversationVC controller];
///zs            ctrl.venueModel = self.venueModel;
            ctrl.conversationModel = self.conversationModel;
            
            [self.navigationController popViewControllerAnimated:NO];
           // [self.navigationController pushViewController:ctrl animated:NO];
		});
	});
}

@end
