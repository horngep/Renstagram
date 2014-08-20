//
//  FriendsViewController.m
//  Renstagram
//
//  Created by Ben Bueltmann on 8/19/14.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import "FriendsViewController.h"
#import "PhotoDetailViewController.h"
#import "Helper.h"

@interface FriendsViewController ()
@property NSArray *photosArray;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation FriendsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"%@'s friends", [PFUser currentUser].username];
    [self getPhotos];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];


}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.photosArray.count == 0) { //If added follower after loadView.. :-)
        [self getPhotos];
    }
}

- (void)getPhotos
{
    PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
    [query whereKey:@"from" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFQuery *secondQuery = [PFQuery queryWithClassName:@"Photo"];
        NSMutableArray *objectIds = [NSMutableArray new];
        for (PFObject *follow in objects) {
            [objectIds addObject:[follow objectForKey:@"to"]];
        }
        [secondQuery whereKey:@"user" containedIn:objectIds];
        [secondQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.photosArray = objects;
            [self createViewsForPhotos];
        }];
    }];




}

- (void)createViewsForPhotos
{
    #define PHOTO_VIEW_HEIGHT 250
    #define MARGIN 20
    int count = 0;
    
    for (PFObject *photo in self.photosArray) {
        UIView *photoView = [[UIView alloc] initWithFrame:CGRectMake(0, count * PHOTO_VIEW_HEIGHT, self.view.frame.size.width, PHOTO_VIEW_HEIGHT)];
        photoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cellBg"]];
        [self.scrollView addSubview:photoView];

        UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN*1.5, self.view.frame.size.width-MARGIN*2, 100)];
        PFFile *file = [photo objectForKey:@"photo"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            photoImageView.image = [Helper roundedRectImageFromImage:[UIImage imageWithData:data] withRadious:8];
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSegue:)];
        photoImageView.userInteractionEnabled = YES;
        [photoImageView addGestureRecognizer:tap];
        photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [photoView addSubview:photoImageView];

        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, photoImageView.frame.origin.y + photoImageView.frame.size.height + MARGIN * 1.4, self.view.frame.size.width-2*MARGIN, MARGIN*3)];
        descriptionLabel.textColor = [UIColor greenColor];
        descriptionLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0];
        descriptionLabel.text = [photo objectForKey:@"description"];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        [photoView addSubview:descriptionLabel];




        NSDate *photoDate = [photo createdAt];
        NSDateFormatter *dateFormat = [NSDateFormatter new];
        dateFormat.timeStyle = NSDateFormatterShortStyle;
        dateFormat.dateStyle = NSDateFormatterShortStyle;

        UILabel *whenAuthorLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, photoImageView.frame.origin.y + photoImageView.frame.size.height + MARGIN * 2.4, self.view.frame.size.width-2*MARGIN, MARGIN*3)];
        whenAuthorLabel.textColor = [UIColor greenColor];
        whenAuthorLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:11.0];
        whenAuthorLabel.textAlignment = NSTextAlignmentCenter;
        [photoView addSubview:whenAuthorLabel];


        PFQuery *userQuery = [PFUser query];
        PFUser *user = [photo objectForKey:@"user"];
        [userQuery whereKey:@"objectId" equalTo:user.objectId];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            whenAuthorLabel.text =  [NSString stringWithFormat:@"on %@  @%@", [dateFormat stringFromDate:photoDate], [object objectForKey:@"username"]];
        }];



        UILabel *numberCommentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, photoImageView.frame.origin.y + photoImageView.frame.size.height + MARGIN*3.4, self.view.frame.size.width-2*MARGIN, MARGIN*3)];
        numberCommentsLabel.textColor = [UIColor greenColor];
        numberCommentsLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:11.0];
        numberCommentsLabel.textAlignment = NSTextAlignmentCenter;
        PFQuery *commentsQuery = [PFQuery queryWithClassName:@"Comment"];
        [commentsQuery whereKey:@"photo" equalTo:photo];
        [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            numberCommentsLabel.text = [NSString stringWithFormat:@"%lu comments", (unsigned long)objects.count];
        }];
        [photoView addSubview:numberCommentsLabel];



        
        count++;
    }
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, count*PHOTO_VIEW_HEIGHT)];

}
-(void)doSegue:(UITapGestureRecognizer *)gestureRecognizer
{
    CGFloat y = [gestureRecognizer locationInView:self.scrollView].y;
    int number = y / PHOTO_VIEW_HEIGHT;
    [self performSegueWithIdentifier:@"comments" sender:@(number)];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"comments"]) {
        PhotoDetailViewController *cvc = segue.destinationViewController;
        cvc.photo = [self.photosArray objectAtIndex:[sender intValue]];
    }
}
@end
