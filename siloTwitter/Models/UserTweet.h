//
//  UserTweet.h
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserTweet : NSObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSDate   *timestamp;
@property (nonatomic, copy) NSArray     *tags;


@end
