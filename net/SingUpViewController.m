//
//  SingUpViewController.m
//  net
//
//  Created by Admin on 11.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//
#import "DataSorceProtocol.h"
#import "NetworkDataSorce.h"
#import "SingUpViewController.h"
#import "User.h"

@interface SingUpViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fullNameText;
@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;

@property (strong,nonatomic) id <DataSorceProtocol> dataSorce;
@property (strong, nonatomic) User *tempUser;

@end

@implementation SingUpViewController

-(void)viewDidLoad
{
    self.dataSorce = [[NetworkDataSorce alloc] init];
    self.tempUser = [[User alloc] init];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.placeholder = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.placeholder = textField.restorationIdentifier;
}


- (IBAction)backButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];

}
- (IBAction)singUpButton:(UIButton *)sender
{
    self.tempUser.name = self.fullNameText.text;
    self.tempUser.login = self.userNameText.text;
    self.tempUser.password = self.passwordText.text;
    self.tempUser.email = self.emailText.text;

    if([self isValidationGood])
    {
        [self.dataSorce requestSingUpWithUser:self.tempUser
                     andViewControllerHandler:^(User *resPerson)
        {
            if (resPerson == nil)
            {
                NSLog(@"fail!!!!");
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                                                   message:@"Fail to sing Up!"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"I understood"
                                                                         otherButtonTitles:nil];
                                   [alert show];
                               });
                
            }
            else
            {
                NSLog(@"good!!!!");
                
                __weak SingUpViewController *weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   weakSelf.mapDelegate.currentPerson = resPerson;
                                   [weakSelf.navigationController popToViewController:weakSelf.mapDelegate animated:YES];
                               });
            }
            
        
        } andErrorHandler:^(NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                            message:@"some system problem!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"I understood"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
}

-(bool)isValidationGood
{
    return YES;
}



@end
