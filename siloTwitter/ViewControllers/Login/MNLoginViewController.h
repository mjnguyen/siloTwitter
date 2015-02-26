//
//  MNLoginViewController.h
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNLoginViewController : UIViewController

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
