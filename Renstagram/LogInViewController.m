//
//  LogInViewController.m
//  Renstagram
//
//  Created by I-Horng Huang on 18/08/2014.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()

@end

@implementation LogInViewController
//Subclass PFLoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.fields = PFLogInFieldsDismissButton; //seems that this shit doesnt care i dont know why we are missing something.
    self.logInView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.logInView.usernameField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    self.logInView.passwordField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];

   
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logoImageView.frame = CGRectMake(0, 0, 200, 150);
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.logInView setLogo:logoImageView];

    self.logInView.passwordForgottenButton.backgroundColor = [UIColor clearColor];
    
}

- (void)viewDidLayoutSubviews
{
    
    NSLog(@"FRAME %@", NSStringFromCGRect(self.logInView.passwordForgottenButton.frame));
    self.logInView.passwordForgottenButton.backgroundColor = [UIColor clearColor];


}
@end
