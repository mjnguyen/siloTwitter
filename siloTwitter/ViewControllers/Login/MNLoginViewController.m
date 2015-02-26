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
    [self.spinner stopAnimating];
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hide:YES];
            if ([dbMgr findUserForUsername:self.registerUsernameField.text]) {
                // user exists, display error message and refocus to username field
                [weakSelf.registerUsernameField becomeFirstResponder];

                [TSMessage showNotificationInViewController:self title:@"Error" subtitle:@"Username already exists. Please try another one." type:TSMessageNotificationTypeError duration:2.f canBeDismissedByUser:YES];
            }

            else {
                // basic check is good.  Now register the user and dismiss the screen
                [tweetMgr registerUser:newUser withCompletionBlock:^(id response, NSError *error) {
                    [weakSelf.delegate loginViewControllerDidRegisterUserSuccessfully:weakSelf];
                }];
            }

        });
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

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

    });

}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
