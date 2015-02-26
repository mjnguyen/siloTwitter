//
//  MNTweetManager.h
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserTweet.h"

typedef void(^MNTweetResponseBlock)(id response, NSError *error);

@interface MNTweetManager : NSObject

+(instancetype)sharedManager;

-(void)tweetMessage: (UserTweet *)userTweet withCompletionBlock:(MNTweetResponseBlock)callback;

-(void)getAllTweetsForUser: (NSString *)username from: (NSDate *)startTime to: (NSDate *)endTime withCompletionBlock: (MNTweetResponseBlock)callback;


@end
