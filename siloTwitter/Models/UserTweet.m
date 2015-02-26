//
//  UserTweet.m
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import "UserTweet.h"

@implementation UserTweet

-(instancetype)init {
    self = [super init];
    if (self != nil) {
        self.timestamp = [NSDate date];
    }

    return self;
}

@end
