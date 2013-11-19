//
//  RegisterViewController_iPhone.m
//  Peek
//
//  Created by Pavel on 14.06.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import "RegisterViewController.h"
#import "HomeViewController.h"
#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "SBJson.h"
//#import <FacebookSDK/FacebookSDK.h>

//#import "FBSession.h"



typedef enum {
	kModeRegister = 0,
	kModeLogin,
	kModeRestorePwd
} KMode;



@interface RegisterViewController ()
//	outlets
@property (nonatomic, retain) IBOutlet UIButton		*buttonForgotPassword;
@property (nonatomic, retain) IBOutlet UIButton		*btnSwRegister;
@property (nonatomic, retain) IBOutlet UIButton		*btnSwLogin;
@property (nonatomic, retain) IBOutlet UIButton		*btnSend;
@property (nonatomic, retain) IBOutlet UIImageView	*limgUsername;
@property (nonatomic, retain) IBOutlet UIImageView	*limgPassword;
@property (nonatomic, retain) IBOutlet UIImageView	*limgEmail;
@property (nonatomic, assign) IBOutlet UITextField	*textUserName;
@property (nonatomic, assign) IBOutlet UITextField	*textPassword;
@property (nonatomic, assign) IBOutlet UITextField	*textEmail;
@property (nonatomic, retain) IBOutletCollection(UITextField) NSArray *allTextFields;
@property (nonatomic, retain) IBOutlet	UIView		*containerView;

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *pwd;
@property (nonatomic, readonly) NSString *email;

@property (nonatomic, readonly) NSString *apnsToken;

@property (nonatomic, retain)   FBSession *fbSession;

@end


@implementation RegisterViewController


- (void)releaseOutlets {
	[super releaseOutlets];
	self.buttonForgotPassword = nil;
	self.btnSwRegister = nil;
	self.btnSwLogin = nil;
	self.btnSend = nil;
	self.limgUsername = nil;
	self.limgPassword = nil;
	self.limgEmail = nil;
	self.allTextFields = nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font) {
		[self.allTextFields makeObjectsPerformSelector:@selector(setFont:) withObject:font];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	ZUserModel *userModel = APP_DLG.currentUser;
	if (!userModel) {
		userModel = [ZUserModel restoreUser];
	}
	NSString *username	= userModel.username;
	NSString *password	= userModel.pwd;
	NSString *email		= userModel.email;
	
	[super subscribeForKeyboardNotifications];
	
	if (username) {
		self.textUserName.text = username;
	}
	if (password) {
		self.textPassword.text = password;
	}
	if (email) {
		self.textEmail.text = email;
	}
	
	[self selectMode:(username == nil) ? kModeRegister : kModeLogin];
	
	[self validate];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
//  [self.fbSession release];
    self.fbSession = nil;
    APP_DLG.facebook = nil;
    
	[super unsubscribeFromKeyboardNotifications];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Actions

- (IBAction)actSwLoginRegister:(UIButton *)sender {
	[self selectMode:sender.tag];
}

- (IBAction)actForgotPwd:(id)sender {
	self.btnSwLogin.enabled = YES;
	self.btnSwRegister.enabled = YES;
	self.limgPassword.hidden = YES;
	self.textPassword.hidden = YES;
	self.limgEmail.hidden = YES;
	self.textEmail.hidden = YES;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password?" message:@"Enter you Login and press Ok. Your information will be sent to registered e-mail" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (IBAction)buttonOkPressed {
	
	[self.view endEditing:YES];
	
	switch ([self selectedMode]) {
		case kModeLogin: {
			ZUserModel *userModel = [[ZUserModel new] autorelease];
			userModel.username = self.username;
			userModel.pwd = self.pwd;
			[self runLoginRequestWithUserModel:userModel];
			break;
		}
			
		case kModeRegister:
			[self runRegisterRequest];
			break;
			
		case kModeRestorePwd:
			[self runRestorePwdRequest];
			break;
	}
}

/* //zsf
-(void)fbResync
{
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    if ((accountStore = [[ACAccountStore alloc] init]) && (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
        
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 && (account = [fbAccounts objectAtIndex:0])){
            
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                //we don't actually need to inspect renewResult or error.
                if (error){
                    
                }
            }];
        }
    }
}
 */

/* //zsf
- (IBAction)buttonFacebookPressed
{
        
    [FBSession openActiveSessionWithReadPermissions:nil //@[@"basic_info", @"email"] //nil
                                       allowLoginUI:YES    
//[FBSession openActiveSessionWithPublishPermissions:nil
//                                   defaultAudience:FBSessionDefaultAudienceEveryone 
//                                      allowLoginUI:YES
     
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error)
     {
     if (error)
         {
             
             NSLog(@"Session error");
             
//             [self fbResync];
//             [NSThread sleepForTimeInterval:1.0];   //half a second
//             [FBSession openActiveSessionWithReadPermissions:nil //nil
//                                                allowLoginUI:YES
//                                           completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
             
                                               if (error) {
                                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                       message:error.localizedDescription
                                                                                                      delegate:nil
                                                                                             cancelButtonTitle:@"OK"
                                                                                             otherButtonTitles:nil];
                                                   [alertView show];                                                   
                                               }
                                               
//                                           }];
             
         }
         else             
             if (session.isOpen)
         {
             BOOL isFbLogin = [[NSUserDefaults standardUserDefaults] boolForKey:SETTING_KEY_IS_FACEBOOK_LOGIN];
             if(isFbLogin)
             {
                 
             }
             
             [FBRequestConnection startForMeWithCompletionHandler:
              ^(FBRequestConnection *connection, id result, NSError *error)
              {
                  NSLog(@"facebook result: %@", result);
                  FBGraphObject *graphObject = (FBGraphObject*)result;
                  NSLog(@"Id = %@", [graphObject objectForKey:@"id"]);
                  NSLog(@"Username = %@", [graphObject objectForKey:@"username"]);
                  
                  ZUserModel *userModel = [[ZUserModel new] autorelease];
                  userModel.facebookUsername = [graphObject objectForKey:@"username"];
                  [self runLoginRequestWithUserModel:userModel isFBLogin:YES];
                  
              }];
         }
     }];
         
         
         
//   }];
    
}
 */

#pragma mark - Facebook Login

- (IBAction)buttonFacebookPressed
{
    if (!_fbSession)
        self.fbSession = [[[FBSession alloc] initWithDelegate:self] autorelease];
    [_fbSession facebookLogin];    
}

#pragma mark - delegate for FaceBookSeccion
//===============================================================================
- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date
{

    NSLog(@"-delegate:token:%@",token);
    NSLog(@"-delegate:date:%@",date);

    [_fbSession facebookGetInfo];
    
//    [_fbSession facebookGetPicture];
    
}

- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date withInfo:(NSDictionary*)result
{
//    NSString *email = [result valueForKey:@"email"];
//    NSString *name = [result valueForKey:@"name"];
    NSString *username = [result valueForKey:@"username"];

//    NSLog(@"delegate:token:%@",token);
//    NSLog(@"delegate:date:%@",date);
//    NSLog(@"(%@)(%@)(%@)",email,name,username);    
//    NSLog(@"res=(%@)",result);
    
// get picture
//    NSURL *fbPictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=640&height=640", [result objectForKey:@"id"]]];
//    NSData *dat = [NSData dataWithContentsOfURL:fbPictureURL];
//    UIImage *im = [UIImage imageWithData:dat];
//    _imgTest.image = im;

    
//  FBGraphObject *graphObject = (FBGraphObject*)result;
    NSLog(@"FB_Id = %@", [result objectForKey:@"id"]);
    NSLog(@"FB_Username = %@", [result objectForKey:@"username"]);
    
    ZUserModel *userModel = [[ZUserModel new] autorelease];
    userModel.facebookUsername = username;
    //userModel.email = email;
    //userModel.username = name;
    [self runLoginRequestWithUserModel:userModel isFBLogin:YES];
    
}

#pragma mark -

- (void)selectMode:(KMode)mode {
	
	BOOL isLogin = (mode == kModeLogin);
	
	self.btnSwLogin.enabled = !isLogin;
	self.btnSwRegister.enabled = isLogin;
    _buttonFacebookConnect.hidden = !isLogin;
	
	self.limgPassword.hidden = NO;
	self.textPassword.hidden = NO;
	
	self.limgEmail.hidden = isLogin;
	self.textEmail.hidden = isLogin;
	
	_buttonForgotPassword.hidden = !isLogin;
}

- (KMode)selectedMode {
	if (!self.btnSwLogin.enabled) {
		return kModeLogin;
	}
	else if (!self.btnSwRegister.enabled) {
		return kModeRegister;
	}
	return kModeRestorePwd;
}

- (NSString *)username {
	return [self.textUserName.text trimWhitespace];
}

- (NSString *)pwd {
	return [self.textPassword.text trimWhitespace];
}

- (NSString *)email {
	return [self.textEmail.text trimWhitespace];
}

- (BOOL)isValid {
	BOOL isEmail = self.email.length != 0;
	BOOL isPwd = self.pwd.length != 0;
	BOOL isUsername = self.username.length != 0;
	BOOL isValid = YES;
	
	switch ([self selectedMode]) {
		case kModeLogin:
			isValid = isUsername && isPwd;
			break;
			
		case kModeRegister:
			isValid = isUsername && isPwd && isEmail;
			break;
		
			default:
			isValid = isUsername;
			break;
	}
	
	return isValid;
}

- (void)validate {
	self.btnSend.enabled = [self isValid];
}

- (NSString *)apnsToken {
	return APP_DLG.apnsToken;
}

#pragma mark - Requests

- (void)runLoginRequestWithUserModel:(ZUserModel *)userModel {
    [self runLoginRequestWithUserModel:userModel isFBLogin:NO];
}

- (void)runLoginRequestWithUserModel:(ZUserModel *)userModel isFBLogin:(BOOL)isFBLogin
{
    if(APP_DLG.currentUser.sessionID.length != 0)
        [self dismissModalViewControllerAnimated:YES];
    
	ZCommonRequest * request = isFBLogin ? [ZCommonRequest requestFBLoginUser:userModel] : [ZCommonRequest requestLoginUser:userModel];
	
	[super showProgress];
	
	dispatch_async(dispatch_queue_create("request.login", NULL), ^{
        
		[request startSynchronous];
		
		LLog(@"LOGIN RESPONSE:'%@'", [request responseString]);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[super hideProgress];
			
			NSError *rqError = request.error;
			if (rqError) {
				LLog(@"%@", rqError);
                
                [APP_DLG showAlertWithMessage:@"Server is not reachable, check your Internet connection" title:@"Error"];
				
				return;
			}
			
			NSString *responseString = [request responseString];
			NSDictionary *resultDic = [NSDictionary dictionaryWithResponseString:responseString];
			ZUserModel *userModel = request.userModel;
			
			if ([userModel applyLoginDictionary:resultDic]) {
				[APP_DLG updateUser:userModel];
				
				LLog(@"LOGIN OK:{{{%@}}}", userModel);
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kDidLoginSuccessfullyNotification object:self userInfo:@{@"userModel" : userModel}];
				
				[APP_DLG updateAPNSTokenOnServer];
				[APP_DLG loadFriends];
                
                //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:SETTING_KEY_IS_FACEBOOK_LOGIN];
				
				[self dismissModalViewControllerAnimated:YES];
			}
			else {
				NSString *errorStr = resultDic[@"msg"];
                [APP_DLG showAlertWithMessage:errorStr title:@"Cannot log in"];
			}
		});
	});
}

- (void)runRegisterRequest {
	
	///iphone/auth.php?action=register&login=coyotter&password=qweqwe&email=coyotter@gmail.com
	
	ZUserModel *userModel = [[ZUserModel new] autorelease];
	userModel.username = self.username;
	userModel.pwd = self.pwd;
	userModel.email = self.email;
	ZCommonRequest * request = [ZCommonRequest requestRegisterUser:userModel];

	NSString *apnsDevToken = self.apnsToken;
	if (apnsDevToken) {
		[request setPostValue:apnsDevToken forKey:@"token"];
	}

	[super showProgress];
	
	dispatch_async(dispatch_queue_create("request.register", NULL), ^{
		[request startSynchronous];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[super hideProgress];
			
			NSError *rqError = request.error;
			if (rqError) {
				LLog(@"%@", rqError);
				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
																message:@"Server is not reachable, check your Internet connection"
															   delegate:nil
													  cancelButtonTitle:@"Ok"
													  otherButtonTitles:nil];
				[alert show];
				[alert release];
				
				return;
			}
			
			NSDictionary *resultDic = [NSDictionary dictionaryWithResponseString:[request responseString]];
			
			NSString *status = resultDic[@"status"];
			if ([status isEqualToString:@"ok"]) {
				
				ZUserModel *uModel = request.userModel;
				uModel.apnsToken = apnsDevToken;
				[uModel resetTimeFilters];
				[uModel saveUser];
				APP_DLG.currentUser = uModel;
				
				[self runLoginRequestWithUserModel:uModel];
			}
			else {
				NSString *msg = resultDic[@"msg"];
				NSString *errorStr = msg.length ? msg : @"Register error";
				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorStr message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
				[alert release];
			}	
		});
	});
}


- (void)runRestorePwdRequest {
	
	ZUserModel *userModel = [[ZUserModel new] autorelease];
	userModel.username = self.username;
	ZCommonRequest *request = [ZCommonRequest requestRestorePwdUser:userModel];
	
	[super showProgress];
	
	[request startSynchronous];
	
	[super hideProgress];
	
	NSError *rqError = request.error;
	if (rqError) {
		LLog(@"%@", rqError);
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Server is not reachable, check your Internet connection"
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;
	}
	
	LLog(@"RESPONSE:'%@'", [request responseString]);
	NSDictionary *resultDic = [NSDictionary dictionaryWithResponseString:[request responseString]];
	NSString *msg = resultDic[@"msg"];
	
	if (msg.length) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	} else {
		
		self.limgPassword.hidden = NO;
		self.textPassword.hidden = NO;
	}
}


#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//	NSString *txt = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//	if (txt.length == 0) {
//		return NO;
//	}
	
//	NSMutableArray *activeTxtFields = [NSMutableArray arrayWithCapacity:4];
//	for (UITextField *tf in self.allTextFields) {
//		if (tf.enabled && !tf.hidden) {
//			[activeTxtFields addObject:tf];
//		}
//	}
	
//	const NSUInteger indx = [activeTxtFields indexOfObject:textField];
//	if (indx < activeTxtFields.count) {
//		if (indx + 1 < activeTxtFields.count) {
//			UITextField *next = [activeTxtFields objectAtIndex:indx+1];
//			[next performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
//		}
//		else {
//			[textField performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0];
//		}
//	}
    
    [textField performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0];
    
	return YES;
}

- (IBAction)actTextDidChange:(UITextField *)txtField {
	[self validate];
}


#pragma mark - Keyboard

- (void)keyboardDidShowNotification:(NSNotification *)notification {
	[UIView animateWithDuration:0.3
					 animations:^{
						 CGRect frame = self.containerView.frame;
						 frame.origin.y = 10;
						 self.containerView.frame = frame;
					 }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
	[UIView animateWithDuration:0.3
					 animations:^{
						 CGRect frame = self.containerView.frame;
						 frame.origin.y = 45;
						 self.containerView.frame = frame;
					 }];
}

- (void)dealloc {
    [_imgTest release];
    [super dealloc];
}
- (void)viewDidUnload {
    [_imgTest release];
    _imgTest = nil;
    [super viewDidUnload];
}
@end
