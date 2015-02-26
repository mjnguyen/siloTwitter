//
//  MNLoginViewController.m
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import "MNLoginViewController.h"
#import "MNDatabaseManager.h"
#import "MNTweetManager.h"
#import "TSMessage.h"
#import "MBProgressHUD.h"
#import "MNUser.h"

@interface MNLoginViewController ()

@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@end

@implementation MNLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.usernameField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-user-gray"]];
    self.usernameField.leftViewMode = UITextFieldViewModeAlways;

    self.passwordField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-password-gray"]];
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];

    [self.view addGestureRecognizer: tap];
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)registerUser:(id)sender {
    // first find if user already exists
    MNDatabaseManager *dbMgr = [MNDatabaseManager sharedManager];
    MNTweetManager *tweetMgr = [MNTweetManager sharedManager];

    // check to make sure the passwords are equivalent
    if (![self.registerPassword1Field.text isEqualToString: self.registerPassword2Field.text]) {
        [TSMessage showNotificationInViewController:self title:@"Error" subtitle:@"Passwords do not match." type:TSMessageNotificationTypeError duration:2.f canBeDismissedByUser:YES];
    }
    else if ([self.registerFullNameField.text length] < 1) {
        [TSMessage showNotificationInViewController:self title:@"Error" subtitle:@"Full name must not be empty." type:TSMessageNotificationTypeError duration:2.f canBeDismissedByUser:YES];
    }
    else if ([self.registerUsernameField.text length] < 5) {
        [TSMessage showNotificationInViewController:self title:@"Error" subtitle:@"username must be at least 5 letters." type:TSMessageNotificationTypeError duration:2.f canBeDismissedByUser:YES];
    }
    else {

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Registering Account . . .";

        MNUser *newUser = [[MNUser alloc] init];
        newUser.username = self.registerUsernameField.text;
        newUser.fullname = self.registerFullNameField.text;
        newUser.password = self.registerPassword1Field.text;

        __weak MNLoginViewController *weakSelf = self;
        [tweetMgr registerUser:newUser withCompletionBlock:^(id response, NSError *error) {
            [hud hide:YES];
            if (error == nil) {
                [tweetMgr registerUser:newUser withCompletionBlock:^(id response, NSError *error) {
                    [weakSelf.delegate loginViewControllerDidRegisterUserSuccessfully:weakSelf];
                }];
            } else {
                [weakSelf.registerUsernameField becomeFirstResponder];

                [TSMessage showNotificationInViewController:self title:@"Registration Error" subtitle:[error localizedDescription] type:TSMessageNotificationTypeError duration:2.f canBeDismissedByUser:YES];

            }
        }];

    }
}

- (IBAction)loginUser:(id)sender {
    // do some validation of form first
    if (!([self.usernameField.text length] > 0 && [self.passwordField.text length] > 0)) {
        // something is blank
        NSString *errorMessage = @"Username or password can not be blank";
        [TSMessage showNotificationInViewController:self title:@"Login Failed" subtitle:errorMessage type:TSMessageNotificationTypeError duration:2.f canBeDismissedByUser:YES];
        return;
    }

    // first find if user already exists
    __weak MNLoginViewController *weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging you in . . .";
    MNTweetManager *mgr = [MNTweetManager sharedManager];
    MNUser *user = [[MNUser alloc] init];
    user.username = self.usernameField.text;
    user.password = self.passwordField.text;


        [mgr loginUser:user withCompletionBlock:^(id user, NSError *error) {
            [hud hide:YES];
            if (error == nil) {
                [weakSelf loginViewControllerDidLoginSuccessfully:weakSelf];
            }
            else {
                // login failed.
                NSString *errorMessage = [error localizedDescription];
                [TSMessage showNotificationInViewController:self title:@"Login Failed" subtitle:errorMessage type:TSMessageNotificationTypeError duration:2.f canBeDismissedByUser:YES];
            }

        }];
}


#pragma mark - MNLoginViewController Delegate

-(void)loginViewController:(MNLoginViewController *)lvc didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(loginViewController:didFailWithError:)]) {
        [self.delegate loginViewController:lvc didFailWithError:error];
    }
}

-(void)loginViewControllerDidLoginSuccessfully:(MNLoginViewController *)lvc {
    if ([self.delegate respondsToSelector:@selector(loginViewControllerDidLoginSuccessfully:)]) {
        [self.delegate loginViewControllerDidLoginSuccessfully:lvc];
    }
}

-(void)loginViewControllerDidRegisterUserSuccessfully:(MNLoginViewController *)lvc {
    if ([self.delegate respondsToSelector:@selector(loginViewControllerDidRegisterUserSuccessfully:)]) {
        [self.delegate loginViewControllerDidRegisterUserSuccessfully:lvc];
    }
}

#pragma mark - Keyboard delegate
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect bkgndRect = self.activeField.superview.frame;
    bkgndRect.size.height += kbSize.height;
    [self.activeField.superview setFrame:bkgndRect];
    [self.scrollView setContentOffset:CGPointMake(0.0, self.activeField.frame.origin.y-kbSize.height) animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    [self.scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
}

@end
