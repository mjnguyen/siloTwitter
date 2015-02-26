//
//  MasterViewController.m
//  siloTwitter
//
//  Created by Michael Nguyen on 2/25/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//
#import "MasterViewController.h"
#import "TSMessage.h"
#import "MBProgressHUD.h"
#import "MNTweetManager.h"
#import "Tweet.h"
#import "DetailViewController.h"
#import "MNLoginViewController.h"

@interface MasterViewController ()

@property (nonatomic, copy) NSString *currentUsername;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showTweetInputDialog:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.spinner setHidesWhenStopped:YES];

    [self.tableView addSubview:self.spinner];
    [self.tableView bringSubviewToFront: self.spinner];

    
}

-(void)viewWillAppear:(BOOL)animated {
    if (self.currentUsername == nil) {
        // show login screen
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MNLoginViewController *loginController = (MNLoginViewController *) [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
        loginController.delegate = self;
        [self.parentViewController presentViewController:loginController animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showTweetInputDialog:(id)sender {
    UIAlertView *popup = [[UIAlertView alloc] initWithTitle:@"Tweet it!" message:@"Tell me your thoughts!" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"OK", nil];
    [popup setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [popup show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];

    if ( [buttonTitle isEqualToString:@"Nevermind"]) {
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Posting Tweet...";
        // create a new Tweet for this user
        UserTweet *userTweet = [[UserTweet alloc] init];
        userTweet.username = self.currentUsername;
        userTweet.message = [[alertView textFieldAtIndex:0] text];
        MNTweetManager *mgr = [MNTweetManager sharedManager];
        [mgr tweetMessage:userTweet withCompletionBlock:^(id response, NSError *error) {
            if (error == nil) {
                [TSMessage showNotificationInViewController:self title:@"Tweet Posted!"  subtitle:@"Thanks!" type:TSMessageNotificationTypeSuccess duration:2.f canBeDismissedByUser:YES];
            }
            else {
                NSString *errorMessage = [NSString stringWithFormat:@"Tweet Failed to Post!"];
                [TSMessage showNotificationInViewController:self title:@"Tweet Unsuccessful!" subtitle:errorMessage type:TSMessageNotificationTypeError duration:2.f canBeDismissedByUser:YES];
            }
            [hud hide:YES];
        }];

    }
}

#pragma mark - MNLoginViewController delegates

-(void)loginViewControllerDidRegisterUserSuccessfully:(MNLoginViewController *)lvc {
    self.currentUsername = lvc.registerUsernameField.text;
    self.fetchedResultsController = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    });

    [TSMessage showNotificationInViewController:self title:@"Registration" subtitle:@"You have successfully been registered! Welcome!" type:TSMessageNotificationTypeSuccess duration:2.f canBeDismissedByUser:YES];
}

-(void)loginViewControllerDidReceivePasswordResetRequest:(MNLoginViewController *)lvc {
    // do something here to handle password resets
}

-(void)loginViewController:(MNLoginViewController *)lvc didFailWithError:(NSError *)error {
    // this is already handled in the login view controller. nothing to do here.
}

-(void)loginViewControllerDidLoginSuccessfully:(MNLoginViewController *)lvc {
    self.currentUsername = lvc.usernameField.text;
    self.fetchedResultsController = nil;

    [self dismissViewControllerAnimated:YES completion:^{
        [TSMessage showNotificationInViewController:self title:@"Login Successful" subtitle:@"Welcome Back!" type:TSMessageNotificationTypeMessage duration:1.f canBeDismissedByUser:YES];
    }];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Tweet *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSDate *tweetDate = object.timeStamp;

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeStyle:NSDateFormatterMediumStyle];
    NSString *dateString = [dateFormat stringFromDate:tweetDate];

    NSString *message = object.message;
    NSString *username = [object.user valueForKey:@"username"];
    NSString *tweet = [NSString stringWithFormat:@"%@", message ];

    cell.textLabel.text = tweet;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Posted by %@ - on %@", username, dateString];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Tweet class]) inManagedObjectContext:self.managedObjectContext];
    NSPredicate *userFilter = [NSPredicate predicateWithFormat:@"SELF.user.username == %@", self.currentUsername];
    [fetchRequest setPredicate:userFilter];

    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
