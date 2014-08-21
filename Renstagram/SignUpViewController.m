//
//  SignUpViewController.m
//  Renstagram
//
//  Created by Ivan Ruiz Monjo on 19/08/14.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logoImageView.frame = CGRectMake(0, 0, 200, 150);
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.signUpView setLogo:logoImageView];
}

@end
