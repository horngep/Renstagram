//
//  PictureViewController.m
//  Renstagram
//
//  Created by Ivan Ruiz Monjo on 18/08/14.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import "AddPictureViewController.h"
#import "TagViewController.h"
#import "Helper.h"

@interface AddPictureViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property NSMutableArray *taggedArray;
@property (weak, nonatomic) IBOutlet UILabel *taggedTextLabel;

@property UIImage *image;

@end

@implementation AddPictureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.taggedArray = [NSMutableArray new];
    self.title = @"Add a photo";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    [self showPicker];
}

#pragma mark - Picking picture
- (IBAction)imagePick:(UITapGestureRecognizer *)sender {
    [self showPicker];
}

-(void)showPicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.backgroundColor = [UIColor blackColor];
    picker.navigationBar.barTintColor = [UIColor blackColor];
    picker.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)tapOnView:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)addPictureButtonPressed:(id)sender
{
    if (self.imageView.image) {  //Prevent saving blank images.
        PFFile *file = [PFFile fileWithData:UIImagePNGRepresentation(self.imageView.image)];
        PFObject *photo = [PFObject objectWithClassName:@"Photo"];
        [photo setObject:file forKey:@"photo"];
        [photo setObject:self.descriptionTextField.text forKey:@"description"];
        [photo setObject:[PFUser currentUser] forKey:@"user"];
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // save tag to associate with photo for PFObject class name "Tag" (from unwind)
            for (PFUser *user in self.taggedArray ) {
                PFObject *tag = [PFObject objectWithClassName:@"Tag"];
                [tag setObject:user forKey:@"userGotTag"];
                [tag setObject:photo forKey:@"photoContainTag"];
                [tag saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                }];
            }
        }];
        self.descriptionTextField.text = @"";
    }
    [self.descriptionTextField resignFirstResponder];
}

#pragma mark - descriptions
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.descriptionTextField]) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - tagging followers
-(IBAction)unwind:(UIStoryboardSegue *)sender
{
    // get PFUser from tag view and addObject to mutable array
    TagViewController *tvc = sender.sourceViewController;
    PFObject *follower = tvc.selectedObject;
    //get PFUser from follow
    PFUser *user = [follower objectForKey:@"to"];
    [user fetchIfNeeded]; // need this to get to user?
    [self.taggedArray addObject:user];
    //now we have array of PFUsers who was tagged
    [self displayTaggedFollowers];
}

-(void)displayTaggedFollowers
{
    NSMutableString *taggedString = [NSMutableString new];
    for (PFUser *taggedUser in self.taggedArray) {
        NSString *username = [taggedUser objectForKey:@"username"];
        [taggedString appendString:[NSString stringWithFormat:@"%@   ",username]];
        NSLog(@"user %@", taggedString);
    }
    self.taggedTextLabel.text = taggedString;
}

#pragma mark - image filter 
// CIIMAGE & CIFILTER !
- (IBAction)changedFilterSegmentedControl:(UISegmentedControl *)sender //segmented control
{
    [self.activityIndicator startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating]; //I know its a fake activity, but since
        //there is not completion block on core image to stop im faking it :-) #badIvan
    });
    CIFilter *filter;
    CIImage *beginImage = [CIImage imageWithData:UIImagePNGRepresentation(self.image)];

    switch (sender.selectedSegmentIndex) {
        case 0:
            NSLog(@"no filter!");
            self.imageView.image  = [Helper roundedRectImageFromImage:self.image withRadious:8]; // <- need this?, default ?
            break;
        case 1: {
            filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues: kCIInputImageKey, beginImage, @"inputIntensity", @0.8, nil];
            break;
        }
        case 2: {
            filter = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues: kCIInputImageKey, beginImage, nil];
        }
            break;
        default:
            break;
    }

    if (sender.selectedSegmentIndex) {
        CIImage *outputImage = [filter outputImage];
        UIImage *newImage = [UIImage imageWithCIImage:outputImage];
        self.imageView.image = [Helper roundedRectImageFromImage:newImage withRadious:8];
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.imageView.image = [Helper roundedRectImageFromImage:image withRadious:8];
    self.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
