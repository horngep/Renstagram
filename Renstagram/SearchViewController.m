//
//  SearchViewController.m
//  Renstagram
//
//  Created by I-Horng Huang on 18/08/2014.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import "SearchViewController.h"
#import "PhotoDetailViewController.h"
#import "MyProfileViewController.h"
#import "Helper.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSArray *photosArray;
@property NSArray *searchResults;
@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Search";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.searchResults = [NSArray new];

    [self.tableView setHidden:YES];
    [self.cancelButton setHidden:YES];

    [self showPhotoOnCollectionView];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"searchSegue"]) {
        MyProfileViewController *suvc = segue.destinationViewController;
        suvc.user = [self.searchResults objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    } else {
        PhotoDetailViewController *pdvc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems].firstObject;
        pdvc.photo = [self.photosArray objectAtIndex:indexPath.row];
    }
}

#pragma mark -
#pragma mark - TABLE VIEW
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ( [textField isEqual:self.searchTextField] ) {
        // hide collection, show table
        [self.tableView setHidden:NO];
        [self.cancelButton setHidden:NO];
        [self.collectionView setHidden:YES];
    }
}

-(IBAction)onCancelButtonPressed:(id)sender
{
    // hide table, show collection
    [self.cancelButton setHidden:YES];
    [self.tableView setHidden:YES];
    [self.collectionView setHidden:NO];
    [self.searchTextField endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.searchTextField]) {
        // search for user to follow
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" containsString:self.searchTextField.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"error : %@",error);
            } else {
                self.searchResults = objects;
                [self.tableView reloadData];
            }
        }];
        [self.searchTextField resignFirstResponder];
    }
    return YES;
}

#pragma mark - table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    PFUser *user = [self.searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [user objectForKey:@"username"];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

#pragma mark -
#pragma mark - COLLECTION VIEW
-(void)showPhotoOnCollectionView
{
    // show all photos: "Explore"
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.photosArray = objects;
        [self.collectionView reloadData];
    }];
}
#pragma mark - Collection View delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    PFObject *photo = [self.photosArray objectAtIndex:indexPath.row];
    PFFile *file = [photo objectForKey:@"photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[Helper roundedRectImageFromImage:image withRadious:8]];
            imageView.frame = CGRectMake(0, 0, 155, 155); //this is the size of cell
            imageView.backgroundColor = [UIColor clearColor];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            for (UIView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
            }
            [cell.contentView addSubview:imageView];
        }
    }];
    return cell;
}



@end
