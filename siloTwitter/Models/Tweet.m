//
//  Tweet.m
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import "Tweet.h"
#import "User.h"
#import "HashTag.h"


@implementation Tweet

@dynamic timeStamp;
@dynamic message;
@dynamic user;
@dynamic hashtags;


- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.timeStamp = [NSDate date];
}

-(NSString *)description {
    NSDate *tweetDate = self.timeStamp;

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeStyle:NSDateFormatterMediumStyle];
    NSString *dateString = [dateFormat stringFromDate:tweetDate];

    User *user= (User *) self.user;

    return [NSString stringWithFormat:@"%@ - Posted by %@, %@", self.message, [user username], dateString];
}
@end
