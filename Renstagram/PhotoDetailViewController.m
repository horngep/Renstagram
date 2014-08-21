//
//  CommentsViewController.m
//  Renstagram
//
//  Created by Ivan Ruiz Monjo on 19/08/14.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import "PhotoDetailViewController.h"

@interface PhotoDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property IBOutlet UITableView *tableView;
@property IBOutlet UITextField *textField;
@property IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *taggedLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property NSArray *commentsArray;

@end

@implementation PhotoDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.tableView.backgroundColor = [UIColor clearColor];

    // whos photo
    PFQuery *userQuery = [PFUser query];
    PFUser *user = [self.photo objectForKey:@"user"];
    [userQuery whereKey:@"objectId" equalTo:user.objectId];
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.title = [NSString stringWithFormat:@"Photo by %@", [object objectForKey:@"username"]];

    }];

    //if its current user
    [user fetchIfNeeded];
    NSString *name = [user objectForKey:@"username"];
    if (![name isEqual:[[PFUser currentUser] objectForKey:@"username"]]) { //if the photo doenst belong to current user
        [self.deleteButton setHidden:YES];
    }

    // display photo, comments, tags
    PFFile *file = [self.photo objectForKey:@"photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        self.imageView.image = image;
        self.imageView.layer.cornerRadius = 8.0;
        self.imageView.clipsToBounds = YES;
    }];
    [self loadComments];
    [self displayTaggedFollowers];

}
#pragma mark - deleting photo
- (IBAction)onDeletePhotoButtonPressed:(id)sender
{
    [self.photo delete];
    NSLog(@"deleted");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tagged
-(void)displayTaggedFollowers
{
    NSMutableString *tagString = [NSMutableString new];
    PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
    [query whereKey:@"photoContainTag" equalTo:self.photo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // now we have array of Tags~
        for (PFObject *tags in objects) {
            PFUser *user = [tags objectForKey:@"userGotTag"];
            [user fetchIfNeeded];
            [tagString appendString:[NSString stringWithFormat:@"%@  ",[user objectForKey:@"username"]]];
        }
        self.taggedLabel.text = tagString;
    }];
}

#pragma mark - Comments
- (IBAction)onButtonPressedAddComment:(id)sender
{
    // add comments to Parse
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    [comment setObject:[PFUser currentUser] forKey:@"user"];
    [comment setObject:self.photo forKey:@"photo"];
    [comment setObject:self.textField.text forKey:@"comment"];
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self loadComments];
    }];

    self.textField.text = @"";
    [self.textField resignFirstResponder];

}

-(void)loadComments
{
    // get comments associated with The photo from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"photo" equalTo:self.photo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.commentsArray = objects;
        [self.tableView reloadData];
    }];
}

#pragma mark - table view delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.backgroundColor = [UIColor clearColor];
    PFObject *comment = [self.commentsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [comment objectForKey:@"comment"];

    PFQuery *userQuery = [PFUser query];
    PFUser *user = [comment objectForKey:@"user"];
    [userQuery whereKey:@"objectId" equalTo:user.objectId];

    NSDate *updated = [comment updatedAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeStyle = NSDateFormatterShortStyle;
    dateFormat.dateStyle = NSDateFormatterShortStyle;
    //[dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Lasted Updated: %@", [dateFormat stringFromDate:updated]];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor whiteColor];

    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFUser *user = objects.firstObject;
            cell.detailTextLabel.text =[NSString stringWithFormat:@"by %@ at %@",[user objectForKey:@"username"],[dateFormat stringFromDate:updated]];
    }];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentsArray.count;
}


@end
