//
//  ViewController.m
//  Renstagram
//
//  Created by Ivan Ruiz Monjo on 18/08/14.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import "MyProfileViewController.h"
#import "PhotoDetailViewController.h"
#import "LogInViewController.h"
#import "SignUpViewController.h"
#import "CustomCollectionViewCell.h"
#import "Helper.h"

@interface MyProfileViewController () <PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSArray *photosArray; //Of PFObject
@property NSString *followIdString;
@end

@implementation MyProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.title =@"My Profile";

    if ([PFUser currentUser]) { // if logged in
        [self displayUserPhotos];
    }
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    if (![PFUser currentUser]) { // if not logged in
        [self showLoginView];
    } else {
        // reload when upload
        [self displayUserPhotos];
    }
#define BUTTON_WIDTH 90
#define BUTTON_HEIGHT 30
#define MARGIN 20
    if (!(self.user == [PFUser currentUser]) && self.user) {
        UIButton *followButton = [UIButton new];
        followButton.frame = CGRectMake(self.view.frame.size.width-BUTTON_WIDTH-MARGIN*2, MARGIN*3, BUTTON_WIDTH, BUTTON_HEIGHT+ MARGIN);
        [followButton addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
        followButton.titleLabel.textColor = [UIColor whiteColor];
        [followButton setTitle:@"Follow" forState:UIControlStateNormal];
        PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject *object in objects) {
                NSLog(@"entro!");
                PFUser *userFrom = [object objectForKey:@"from"];
                PFUser *userTo = [object objectForKey:@"to"];

                if ([userFrom.objectId isEqualToString:[PFUser currentUser].objectId] && [userTo.objectId isEqualToString:self.user.objectId] ) {
                    self.followIdString = object.objectId;
                [followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
                }
            }
        }];
        NSLog(@"heee");

        [self.view addSubview:followButton];
        [self.view bringSubviewToFront:followButton];
    }

}

-(void)follow:(UIButton *)button
{

    if ([button.titleLabel.text isEqualToString:@"Follow"]) {
        NSLog(@"PREEESD 1");
        PFObject *follow = [PFObject objectWithClassName:@"Follow"];
        [follow setObject:[PFUser currentUser] forKey:@"from"];
        [follow setObject:self.user forKey:@"to"];
        [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"saved!");
            self.followIdString = follow.objectId;
        }];
        [button setTitle:@"Unfollow" forState:UIControlStateNormal];

    } else

    if ([button.titleLabel.text isEqualToString:@"Unfollow"]) {
        NSLog(@"PREEESD 2");
        PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
        [query whereKey:@"objectId" equalTo:self.followIdString];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            PFObject *object = objects.firstObject;
            [object delete];
        }];
        [button setTitle:@"Follow" forState:UIControlStateNormal];
    }

}

- (void)displayUserPhotos
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    if (!self.user) {
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
    } else {
        [query whereKey:@"user" equalTo:self.user];
        self.title = [NSString stringWithFormat:@"%@'s Profile",self.user.username];
    }
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.photosArray = objects;
        [self.collectionView reloadData];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // send photo to detail view controller
    if ([segue.identifier isEqualToString:@"detail"]) {
        PhotoDetailViewController *pdvc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems].firstObject;
        pdvc.photo = [self.photosArray objectAtIndex:indexPath.row];
    }
}

#pragma mark - Loggin in and out

-(void)showLoginView
{
    //custom login and sign up view controller
    LogInViewController *logInViewController = [[LogInViewController alloc] init];
    logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsFacebook | PFLogInFieldsTwitter | PFLogInFieldsSignUpButton |PFLogInFieldsPasswordForgotten;
    logInViewController.delegate = self;

    SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
    signUpViewController.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsEmail | PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton | PFSignUpFieldsAdditional | PFSignUpFieldsDefault;
    [signUpViewController setDelegate:self];

    [logInViewController setSignUpController:signUpViewController];
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (IBAction)logoutButtonPressed:(id)sender
{
    [PFUser logOut];
    [self showLoginView];
}

#pragma mark - Parse delegate
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [signUpController dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self displayUserPhotos];
    self.user = [PFUser currentUser];
}

#pragma mark - Collection View delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // use custom collection view cell
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    PFObject *photo = [self.photosArray objectAtIndex:indexPath.row];
    PFFile *file = [photo objectForKey:@"photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];

            cell.imageView.image = [Helper roundedRectImageFromImage:image withRadious:9];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.descriptionLabel.text = [photo objectForKey:@"description"];

            NSDate *photoDate = [photo createdAt];
            NSDateFormatter *dateFormat = [NSDateFormatter new];
            dateFormat.timeStyle = NSDateFormatterShortStyle;
            dateFormat.dateStyle = NSDateFormatterShortStyle;
            cell.infoLabel.text = [NSString stringWithFormat:@"on %@", [dateFormat stringFromDate:photoDate]];

            // get comments associated with the photo
            PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
            [query whereKey:@"photo" equalTo:photo];
            [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                cell.commentsLabel.text = [NSString stringWithFormat:@"%d comments", number];
            }];
        } else {
            NSLog(@"error : %@",error);
        }
    }];
    return cell;
}


@end
