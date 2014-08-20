//
//  SearchedUserViewController.m
//  Renstagram
//
//  Created by I-Horng Huang on 19/08/2014.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import "Helper.h"
#import "SearchedUserViewController.h"


@interface SearchedUserViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSArray *photosArray; //Of PFObject

@end

@implementation SearchedUserViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.usernameLabel.text = [self.user objectForKey:@"username"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];

    [self displaySearchedUserPhotos];
}

- (void)displaySearchedUserPhotos
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.photosArray = objects;
        [self.collectionView reloadData];
    }];
}

#pragma mark - Following
- (IBAction)onFollowButtonPressed:(id)sender
{
    PFObject *follow = [PFObject objectWithClassName:@"Follow"];
    [follow setObject:[PFUser currentUser] forKey:@"from"];
    [follow setObject:self.user forKey:@"to"];
    [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"saved!");
    }];
}

#pragma mark - Collection View delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellly" forIndexPath:indexPath];
    PFObject *photo = [self.photosArray objectAtIndex:indexPath.row];
    PFFile *file = [photo objectForKey:@"photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[Helper roundedRectImageFromImage:image withRadious:8]];
            imageView.frame = CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height/2);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:imageView];
        }
    }];
    return cell;
}

@end
