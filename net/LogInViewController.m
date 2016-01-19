//
//  ViewController.m
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "LogInViewController.h"
#import "DataSorceProtocol.h"
#import "NetworkDataSorce.h"
#import "SingUpViewController.h"
#import "TextFieldValidation.h"


@interface LogInViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userTextFild;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (strong,nonatomic) id <DataSorceProtocol> dataSorce;
@property(strong, nonatomic) TextFieldValidation *textFieldValidator;

@end

@implementation LogInViewController


-(void)viewDidLoad
{
    self.dataSorce = [[NetworkDataSorce alloc] init];
    self.textFieldValidator = [[TextFieldValidation alloc] init];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.placeholder = textField.restorationIdentifier;
    [self.textFieldValidator isValidField:textField];
}

- (IBAction)logInButton:(UIButton *)sender
{
    
    self.textFieldValidator.fields = [NSArray arrayWithObjects:self.userTextFild,
                                      self.passTextField, nil];
    
    if (![self.textFieldValidator isFilled])
        return;
    
    if(![self.textFieldValidator isValidFields])
        return;
    
    [self.dataSorce requestLogInWithUser:self.userTextFild.text
                                 andPass:self.passTextField.text
                andViewControllerHandler:^(User *resPerson)
    {
        if (resPerson == nil)
        {
            NSLog(@"fail!!!!");
            dispatch_async(dispatch_get_main_queue(), ^
                           {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                            message:@"Fail to log in!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"I understood"
                                                  otherButtonTitles:nil];
            [alert show];
                           });

        }
        else
        {
            NSLog(@"good!!!!");
            
            __weak LogInViewController *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^
                       {
                           weakSelf.mapDelegate.currentPerson = resPerson;
                           [weakSelf.navigationController popViewControllerAnimated:YES];
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


#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"fromLogInToSingUp"])
    {
        if([segue.destinationViewController isKindOfClass:[SingUpViewController class]])
        {
            SingUpViewController *logInVC = (SingUpViewController*)segue.destinationViewController;
            logInVC.mapDelegate = self.mapDelegate;
            
        }
    }
}



@end
