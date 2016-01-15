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


@interface LogInViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userTextFild;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (strong,nonatomic) id <DataSorceProtocol> dataSorce;

@end

@implementation LogInViewController


-(void)viewDidLoad
{
    self.dataSorce = [[NetworkDataSorce alloc] init];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.placeholder = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.placeholder = textField.restorationIdentifier;
}

- (IBAction)logInButton:(UIButton *)sender
{
    
    
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
            
            __weak LogInViewController *weakVC = self;
            dispatch_async(dispatch_get_main_queue(), ^
                       {
                           self.mapDelegate.currentPerson = resPerson;
                           [weakVC.navigationController popViewControllerAnimated:YES];
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



//-(UIViewController*)giveViewControllerByTittleUpToStackWithTitle:(NSString*)tittle
//{
//    for (UIViewController *vc in ((UINavigationController*)self.parentViewController).viewControllers)
//    {
//        
//        NSString *t = vc.title;
//        if([vc.title isEqualToString:tittle])
//            return vc;
//    }
//    
//    return nil;
//    
//}


@end
