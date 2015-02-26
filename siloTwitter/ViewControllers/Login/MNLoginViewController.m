//
//  MNLoginViewController.m
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import "MNLoginViewController.h"
#import "MNDatabaseManager.h"
#import "TSMessage.h"

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
    if ([dbMgr findUserForUsername:self.registerUsernameField.text]) {
        // user exists, display error message and refocus to username field
        [self.registerUsernameField becomeFirstResponder];

        [TSMessage showNotificationInViewController:self title:@"Error" subtitle:@"Username already exists. Please try another one." type:TSMessageNotificationTypeError duration:2.f canBeDismissedByUser:YES];
        return;
    }

    // check to make sure the passwords are equivalent
    if (![self.registerPassword1Field.text isEqualToString: self.registerPassword2Field.text]) {
        [TSMessage showNotificationWithTitle:@"Passwords do not match." type:TSMessageNotificationTypeError];
    }
    else if ([self.registerFullNameField.text length] < 5) {
        [TSMessage showNotificationWithTitle:@"Full name must not be empty." type:TSMessageNotificationTypeError];
    }
    else if ([self.registerUsernameField.text length] < 5) {
        [TSMessage showNotificationWithTitle:@"Username must be at least 5 characters." type:TSMessageNotificationTypeError];
    } else {
        // basic check is good.  Now register the user and dismiss the screen
        __weak MNLoginViewController *weakSelf = self;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [dbMgr createUser:weakSelf.registerUsernameField.text withName:weakSelf.registerFullNameField.text andPassword:weakSelf.registerPassword1Field.text];
            [weakSelf.delegate loginViewControllerDidRegisterUserSuccessfully:self];
        });
    }
}

- (IBAction)loginUser:(id)sender {
    // first find if user already exists
    MNDatabaseManager *dbMgr = [MNDatabaseManager sharedManager];
    User *user = [dbMgr findUserForUsername:self.registerUsernameField.text];
    if (user != nil) {
        [self loginViewControllerDidLoginSuccessfully:self];
    }
    else {
        // login failed.
        [TSMessage showNotificationInViewController:self title:@"Login Failed" subtitle:@"Username/password do not match." type:TSMessageNotificationTypeError duration:2.f canBeDismissedByUser:YES];
    }

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
