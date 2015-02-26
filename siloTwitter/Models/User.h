//
//  User.h
//  siloTwitter
//
//  Created by Michael Nguyen on 2/26/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSSet *tweets;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(Tweet *)value;
- (void)removeTweetsObject:(Tweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
