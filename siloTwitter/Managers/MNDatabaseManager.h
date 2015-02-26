//
//  MNDatabaseManager.h
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "User.h"
#import "Tweet.h"
#import "HashTag.h"
#import "UserTweet.h"
#import "MNTweetManager.h"

@interface MNDatabaseManager : NSObject

+(instancetype)sharedManager;

-(void)saveTweet:(UserTweet *)userTweet;
-(NSArray *)getAllTweetsForUser: (NSString *)username from: (NSDate *)startTime to: (NSDate *)endTime;
// CRUD operations for users
- (void)createUser: (NSString *)username withName: (NSString *)fullName andPassword: (NSString *)password;
-(void)deleteUser: (NSString *)username;
-(User *)findUserForUsername: (NSString *)username;

@end
