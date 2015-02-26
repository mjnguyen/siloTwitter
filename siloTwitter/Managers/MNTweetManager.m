//
//  MNTweetManager.m
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import "MNTweetManager.h"
#import "MNDatabaseManager.h"

@implementation MNTweetManager


+ (instancetype)sharedManager {
    static MNTweetManager *sharedSomeManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSomeManager = [[self alloc] init];
    });

    return sharedSomeManager;
}

- (void)tweetMessage:(UserTweet *)userTweet withCompletionBlock: (MNTweetResponseBlock)callback {
    MNDatabaseManager *dbManager = [MNDatabaseManager sharedManager];
    // verify user exists
    NSError *error = nil;
    User *user = [dbManager findUserForUsername:userTweet.username];
    if (user == nil) {
        // invalid tweet was sent as User doesn't exist.
        // send a notification of such
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: @"Unknown User"};

        error = [[NSError alloc] initWithDomain:@"Uknown User" code:2000 userInfo:userInfo];
    }
    // introduce a delay in the processing
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (error == nil) {
            // now we can send the tweet
            [dbManager saveTweet:userTweet];
        }

        callback(userTweet, error);
    });
}

- (void)getAllTweetsForUser:(NSString *)username from:(NSDate *)startTime to:(NSDate *)endTime withCompletionBlock:(MNTweetResponseBlock)callback {
    MNDatabaseManager *dbManager = [MNDatabaseManager sharedManager];

    NSArray *tweets = [dbManager getAllTweetsForUser:username from:startTime to:endTime];

    // introduce a delay in the processing
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (callback) {
            NSError *error = nil;
            if (tweets == nil) {
                NSDictionary *errorDetails = @{ @"errorCode": @1000,
                                                NSLocalizedDescriptionKey: @"Request for Tweets for user failed unexpectedly"
                                                };
                error = [NSError errorWithDomain:@"Request Error" code:1000 userInfo:errorDetails];
            }

            callback(tweets, error);
        }
    });
}

-(void)registerUser:(MNUser *)newUser withCompletionBlock:(MNTweetResponseBlock)callback {
    MNDatabaseManager *mgr = [MNDatabaseManager sharedManager];
    [mgr createUser:newUser.username withName:newUser.fullname andPassword:newUser.password];
    if (callback) {
        callback(newUser, nil);
    }
}

-(void)loginUser:(MNUser *)user withCompletionBlock:(MNTweetResponseBlock)callback {
    // first find the user
    MNDatabaseManager *mgr = [MNDatabaseManager sharedManager];
    User *dbUser = [mgr findUserForUsername:user.username];
    NSDictionary *userInfo = nil;
    NSError *error = nil;

    if (dbUser == nil) {
        if (callback) {
            userInfo = @{ NSLocalizedDescriptionKey: @"User doesn't exist.",
                                        @"code" : @3000
                                        };
            error = [NSError errorWithDomain:@"Login" code:3000 userInfo:userInfo];
        }
    }

    else if (![dbUser.password isEqualToString:user.password]) {
        userInfo = @{ NSLocalizedDescriptionKey: @"username/password do not match.",
                      @"code" : @4000
                      };
        error = [NSError errorWithDomain:@"Login" code:4000 userInfo:userInfo];
    }
    
    if (callback) {
        callback(user, error);
    }
}
@end
