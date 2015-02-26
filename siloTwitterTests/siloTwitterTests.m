//
//  siloTwitterTests.m
//  siloTwitterTests
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import "MNDatabaseManager.h"
#import "UserTweet.h"
#import "MNTweetManager.h"

@interface siloTwitterTests : XCTestCase {
    MNDatabaseManager *dbMgr;
    MNTweetManager *tweetMgr;
}
@end

@implementation siloTwitterTests

static NSString *testUserName = @"MichaelNguyen";
static NSString *testUserFullName = @"Michael Nguyen";
// ensure our test user exists, if not create him
- (void)initializeDb {

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([User class])];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF.username = %@",testUserName];
    [request setPredicate:filter];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator: app.persistentStoreCoordinator];

    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (error != nil) {
        // if an error happened abort the test
//        XCTFail(@"Failed to setup test properly, database already has test user populated!");
        NSLog(@"Test User already exists. \nError:%@", [error localizedDescription]);
    }

    // get a handle on the managers
    dbMgr = [app dbManager];
    tweetMgr = [app tweetManager];

    if ([results count] == 0) {
    // create the User in the db
        [dbMgr createUser:testUserName withName:testUserFullName andPassword:@"password"];
    }

}

- (void)deleteTestUser {

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([User class])];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF.username = %@",testUserName];
    [request setPredicate:filter];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator: app.persistentStoreCoordinator];

    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (error != nil || [results count] == 0) {
        // if an error happened abort the test
        XCTFail(@"Failed to tear down test properly, database is missing test user!");
    }

    [moc deleteObject: [results firstObject]];
    if (![moc save: &error ]) {
        NSLog(@"Failed to remove User from table. \nError: %@", [error localizedDescription]);
    }

}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self initializeDb];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self deleteTestUser];
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testTweetPost {
    UserTweet *userTweet = [[UserTweet alloc] init];
    userTweet.username = testUserName;
    userTweet.message = @"Whoopee this is my first Tweet!";
    userTweet.tags = @[ @"firstTweet", @"Fun"];

    XCTestExpectation *postTweet = [self expectationWithDescription:@"Posting First Tweet for user."];

    [tweetMgr tweetMessage:userTweet withCompletionBlock:^(id response, NSError *error) {
        if (error == nil) {
            // post was successful
            XCTAssertEqual(@"Whoopee this is my first Tweet!", [response message]);
            XCTAssertNil(error);
            [postTweet fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Test Failed! \nError: %@", [error localizedDescription]);
        }
    }];
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
