//
//  SearchViewController.m
//  Renstagram
//
//  Created by I-Horng Huang on 18/08/2014.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchedUserViewController.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *searchResults;
@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Search";
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.searchResults = [NSArray new];
    
}

- (IBAction)onSearchButtonPressed:(id)sender
{
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SearchedUserViewController *suvc = segue.destinationViewController;
    suvc.user = [self.searchResults objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    NSLog(@"%@",suvc.user);
}

#pragma mark - table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    PFUser *user = [self.searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [user objectForKey:@"username"];
    cell.textLabel.textColor = [UIColor greenColor];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

@end
