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
#import "TextFieldValidation.h"
#define kOFFSET_FOR_KEYBOARD 215.0


@interface SingUpViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fullNameText;
@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;

@property (strong, nonatomic) UITextField *currentEditField;
@property (weak, nonatomic) IBOutlet UIView *viewSize;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottonConstraint;


@property (strong,nonatomic) id <DataSorceProtocol> dataSorce;
@property (strong, nonatomic) TextFieldValidation *textFieldValidator;

@end

@implementation SingUpViewController

-(void)viewDidLoad
{
    self.dataSorce = [[NetworkDataSorce alloc] init];
    _textFieldValidator = [[TextFieldValidation alloc] init];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#define TEXTFIELD_OFFSET 3

-(void)keyboardWillShow
{
    
    self.scrollViewBottonConstraint.constant = kOFFSET_FOR_KEYBOARD;
    [self.view layoutIfNeeded];
}

-(void)keyboardDidShow
{
    if (self.currentEditField == nil)
        return;
    
    CGRect visibleRect = [self.scrollView convertRect:self.scrollView.bounds toView:self.contentView];

    CGFloat bottomCurrentField = self.currentEditField.frame.origin.y - visibleRect.origin.y + self.currentEditField.bounds.size.height + TEXTFIELD_OFFSET;
    CGFloat bottomScrollView = self.scrollView.bounds.size.height;
    
    if(bottomCurrentField > bottomScrollView)
    {
        CGFloat yMove = bottomCurrentField - bottomScrollView;
        CGRect newVisibleRect = CGRectMake(visibleRect.origin.x, visibleRect.origin.y + yMove, visibleRect.size.width, visibleRect.size.height);
        [self.scrollView scrollRectToVisible:newVisibleRect animated:YES];
        
    }

}

-(void)keyboardWillHide
{
    self.scrollViewBottonConstraint.constant = 0;
    [self.view layoutIfNeeded];


}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = nil;
    self.currentEditField = textField;
    
    
//    CGRect oldBounds =  self.scrollView.bounds;
//    CGRect newBounds = CGRectMake(oldBounds.origin.x, oldBounds.origin.y, oldBounds.size.width, oldBounds.size.height - kOFFSET_FOR_KEYBOARD);
//    self.scrollView.bounds = newBounds;

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.placeholder = textField.restorationIdentifier;
    self.currentEditField = nil;
    if([textField.restorationIdentifier isEqualToString:@"Confirm password"])
    {
        if(![self.passwordText.text isEqualToString:self.confirmPassword.text])
            self.confirmPassword.backgroundColor = [UIColor redColor];
    }
    else
        [self.textFieldValidator isValidField:textField];
}



- (IBAction)backButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];

}
- (IBAction)singUpButton:(UIButton *)sender
{
 
    self.textFieldValidator.fields = [NSArray arrayWithObjects: self.fullNameText, self.userNameText,
                               self.emailText, self.passwordText, nil];
    
    if (![self.textFieldValidator isFilled])
        return;
    
    if(![self.textFieldValidator isValidFields])
        return;

    if(![self.passwordText.text isEqualToString:self.confirmPassword.text])
    {
        self.confirmPassword.backgroundColor = [UIColor redColor];
        return;
    }
    
    
    User *tempUser = [[User alloc] initWithName:self.fullNameText.text
                                       andLogin:self.userNameText.text
                                        andPass:self.passwordText.text
                                       andEmail:self.emailText.text];
    

    [self.dataSorce requestSingUpWithUser:tempUser
                 andViewControllerHandler:^(User *resUser)
    {
        if (resUser == nil)
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
                               weakSelf.mapDelegate.currentUser = resUser;
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




@end
