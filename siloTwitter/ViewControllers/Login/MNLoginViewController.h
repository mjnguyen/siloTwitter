//
//  MNLoginViewController.h
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MNLoginViewController;
@protocol MNLoginViewControllerDelegate;

@protocol MNLoginViewControllerDelegate <NSObject>

// The methods declared here are all optional
@optional

// We name the methods here in a way that explains what the purpose of each message is
// Each takes a LoginViewController as the first argument, allowing one object to serve
// as the delegate of many MNLoginViewControllers
- (void)loginViewControllerDidLoginSuccessfully:(MNLoginViewController *)lvc;
- (void)loginViewController:(MNLoginViewController *)lvc didFailWithError:(NSError *)error;
- (void)loginViewControllerDidReceivePasswordResetRequest:(MNLoginViewController *)lvc;
- (void)loginViewControllerDidRegisterUserSuccessfully:(MNLoginViewController *)lvc;

@end


@interface MNLoginViewController : UIViewController <MNLoginViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, weak) id<MNLoginViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel, *passwordLabel;
@property (nonatomic, weak) IBOutlet UITextField *usernameField, *passwordField;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

@property (nonatomic, weak) IBOutlet UILabel *registerUsernameLabel, *registerFullNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *registerPassword1Label, *registerPassword2Label;
@property (nonatomic, weak) IBOutlet UITextField *registerUsernameField, *registerFullNameField;
@property (nonatomic, weak) IBOutlet UITextField *registerPassword1Field, *registerPassword2Field;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;

@end