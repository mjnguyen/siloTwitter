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
    User *user = [dbManager findUserForUsername:userTweet.username];
    if (user == nil) {
        // invalid tweet was sent as User doesn't exist.
        // send a notification of such
        return;
    }
    // introduce a delay in the processing
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        // now we can send the tweet
        [dbManager saveTweet:userTweet];
        callback(userTweet, nil);
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
                                                @"description": @"Request for Tweets for user failed unexpectedly"
                                                };
                error = [NSError errorWithDomain:@"Request Error" code:1000 userInfo:errorDetails];
            }

            callback(tweets, error);
        }
    });
}



@end
