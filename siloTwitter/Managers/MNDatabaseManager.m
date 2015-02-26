//
//  MNDatabaseManager.m
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import "MNDatabaseManager.h"
#import "AppDelegate.h"


@implementation MNDatabaseManager

+ (instancetype)sharedManager {
    static MNDatabaseManager *sharedSomeManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSomeManager = [[self alloc] init];
    });

    return sharedSomeManager;
}

- (void)deleteUser: (NSString *)username {
    // remove all data associated with username
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator: app.managedObjectContext.persistentStoreCoordinator];

    User *userToDelete = [self findUserForUsername:username];

    [moc deleteObject:userToDelete];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"Failed to remove User [%@] from database!\nError: %@", username, [error localizedDescription]);
        
    }

}
- (void)createUser: (NSString *)username withName: (NSString *)fullName andPassword: (NSString *)password {
    NSError *error = nil;
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator: app.managedObjectContext.persistentStoreCoordinator];

    User *newUser = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([User class]) inManagedObjectContext:moc];
    [newUser setUsername:username];
    [newUser setName: fullName];
    [newUser setPassword: password];
    
    if (![moc save:&error]) {
        NSLog(@"Failed to create user!\nError: %@\nUser: %@", [error localizedDescription], newUser);
    }

}

-(NSArray *)getAllTweetsForUser:(NSString *)username from:(NSDate *)startTime to:(NSDate *)endTime {
    NSArray *tweets = nil;
    User *currentUser = [self findUserForUsername:username];

    if (currentUser == nil) {
        return tweets;
    }

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Tweet class])];
    NSPredicate *userFilter = [NSPredicate predicateWithFormat:@"SELF.username == %@", username];
    NSPredicate *startTimeFilter = [NSPredicate predicateWithFormat:@"SELF.timestamp >= %@", startTime];
    NSPredicate *endTimeFilter = [NSPredicate predicateWithFormat:@"SELF.timestamp < %@", endTime];

    NSArray *predicates = nil;
    if ((startTime != nil) && (endTime != nil)) {
        predicates = @[ userFilter, startTimeFilter, endTimeFilter];
    }
    else if (startTime != nil) {
        predicates = @[userFilter, startTimeFilter];
    }
    else if (endTime != nil) {
        predicates = @[userFilter, endTimeFilter];
    }
    else {
        predicates = @[userFilter];
    }

    NSCompoundPredicate *compoundPredicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];

    [request setPredicate:compoundPredicate];

    NSError *error = nil;
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator: app.managedObjectContext.persistentStoreCoordinator];

    tweets = [moc executeFetchRequest:request error:&error];

    if (error != nil) {
        NSLog(@"Failed to retrieve tweets for user [%@]!\nError: %@", username, [error localizedDescription]);
    }

    return tweets;
}


-(User *)findUserForUsername: (NSString *)username {

    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([User class])];
    NSPredicate *userFilter = [NSPredicate predicateWithFormat:@"SELF.username == %@", username];
    [request setPredicate:userFilter];

    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator: app.managedObjectContext.persistentStoreCoordinator];

    NSArray *results = [moc executeFetchRequest:request error:&error];

    if (error != nil) {
        NSLog(@"Error happened while getting user [%@]\nError: %@", username, [error localizedDescription]);
        return nil;
    }
    return [results firstObject];

}

-(void)saveTweet:(UserTweet *)userTweet {
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = app.managedObjectContext; 

    User *user = [self findUserForUsername:userTweet.username];
    if (user == nil) {
        // send out a notification that
        return;
    }

    NSManagedObjectID *userContextId = [user objectID];
    NSError *error = nil;

    // now that we have a valid user create the tweet and save it to the database
    Tweet *tweet = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Tweet class]) inManagedObjectContext:moc];
    tweet.user = (User *)[moc existingObjectWithID:userContextId error:&error];
    tweet.message = userTweet.message;

    if ([userTweet.tags count] > 0) {
        // create tags associated with the tweet
        NSMutableSet *tagsToAdd = [[NSMutableSet alloc] init];
        NSMutableSet *newTags = [[NSMutableSet alloc] initWithArray:userTweet.tags];
        for (NSString *hashtag in newTags) {
            HashTag *tag = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([HashTag class]) inManagedObjectContext:moc];
            tag.tweet = tweet;
            tag.name = hashtag;
            [tagsToAdd addObject:tag];
        }
        [tweet setHashtags:tagsToAdd];
    }

    if (![moc save:&error]) {
        NSLog(@"Error while saving Tweet! %@", [error localizedDescription]);
        // Ideally, have a error handling system rather than just using straight notificiations.
        NSDictionary *details = [NSDictionary dictionaryWithObjectsAndKeys:userTweet, @"object", error, @"error", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Error" object:details];
    }

}


@end
