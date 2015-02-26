//
//  Tweet.h
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HashTag;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSManagedObject *user;
@property (nonatomic, retain) NSSet *hashtags;
@end

@interface Tweet (CoreDataGeneratedAccessors)

- (void)addHashtagsObject:(HashTag *)value;
- (void)removeHashtagsObject:(HashTag *)value;
- (void)addHashtags:(NSSet *)values;
- (void)removeHashtags:(NSSet *)values;

@end
