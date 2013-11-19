//
//  RegisterViewController_iPhone.h
//  Peek
//
//  Created by Pavel on 14.06.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSuperViewController.h"
#import "FBSession.h"

@interface RegisterViewController : ZSuperViewController <FBSeccionDelegate>
{
    __weak IBOutlet UIButton *_buttonFacebookConnect;
    
    IBOutlet UIImageView *_imgTest;
}


- (IBAction)actSwLoginRegister:(id)sender;
- (IBAction)buttonOkPressed;
- (IBAction)actForgotPwd:(id)sender;
- (IBAction)actTextDidChange:(UITextField *)txtField;


- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date;
- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date withInfo:(NSDictionary*)result;

@end
