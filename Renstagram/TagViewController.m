//
//  TagViewController.m
//  Renstagram
//
//  Created by I-Horng Huang on 19/08/2014.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import "TagViewController.h"

@interface TagViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *followersArray;

@end

@implementation TagViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.followersArray = [NSArray new];

    //can only tag followers
    PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
    [query whereKey:@"from" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error : %@",error);
        } else {
            self.followersArray = objects;
            [self.tableView reloadData];
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.selectedObject = [self.followersArray objectAtIndex:[self.tableView indexPathForSelectedRow].row];
}

#pragma mark - table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    PFObject *follower = [self.followersArray objectAtIndex:indexPath.row];
    PFUser *user = [follower objectForKey:@"to"];
    [user fetchIfNeeded]; //to be able to access username
    cell.textLabel.text = [user objectForKey:@"username"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.followersArray.count;
}

@end
