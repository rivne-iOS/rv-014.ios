//
//  SingUpViewController.m
//  net
//
//  Created by Admin on 11.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "UIColor+Bawl.h"
#import "DataSorceProtocol.h"
#import "NetworkDataSorce.h"
#import "SingUpViewController.h"
#import "User.h"
#import "TextFieldValidation.h"
#import "CurrentItems.h"



@interface SingUpViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fullNameText;
@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (strong, nonatomic) NSArray <UITextField*> *textFields;

@property (strong, nonatomic) UITextField *currentEditField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong,nonatomic) id <DataSorceProtocol> dataSorce;
@property (strong, nonatomic) TextFieldValidation *textFieldValidator;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation SingUpViewController

-(void)viewDidLoad
{
    self.dataSorce = [[NetworkDataSorce alloc] init];
    _textFieldValidator = [[TextFieldValidation alloc] init];
    self.textFields = [NSArray arrayWithObjects:self.fullNameText, self.userNameText, self.emailText, self.passwordText, self.confirmPassword, nil];
    // frame color
    for (__weak UITextField *textField in self.textFields)
    {
        textField.layer.borderColor = [[UIColor bawlRedColorWithAlpha:0.5] CGColor];
        textField.layer.borderWidth = 1;
        textField.layer.cornerRadius = 6;
        
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:textField.restorationIdentifier
                                                                                    attributes:@{NSForegroundColorAttributeName : [UIColor bawlRedColorWithAlpha:0.3]}];
        textField.attributedPlaceholder = attrStr;
        self.signupButton.backgroundColor = [UIColor bawlRedColor];
        self.backButton.backgroundColor = [UIColor bawlRedColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(dismissKeyboard)];
        
        [self.view addGestureRecognizer:tap];
    }
}

-(void)dismissKeyboard
{
    [self.currentEditField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#define TEXTFIELD_OFFSET 5

-(NSLayoutConstraint*)scrollBottomConstraint
{
    for(NSLayoutConstraint *constraint in self.view.constraints)
    {
        if ([constraint.identifier isEqualToString:@"BottomScrollViewConstraint"])
        {
            return constraint;
            
        }
    }
    return nil;

}

-(void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary *dic = notification.userInfo;
    NSValue *keyboardFrame = dic[UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [keyboardFrame CGRectValue];
    CGRect viewFrame = [self.view convertRect:frame fromView:nil];
    CGFloat keyboardHeight = viewFrame.size.height;
    
    [self scrollBottomConstraint].constant = keyboardHeight;
    [self.view layoutIfNeeded];

    
    if (self.currentEditField == nil)
        return;
    
    CGRect visibleRect = [self.scrollView convertRect:self.scrollView.bounds toView:self.contentView];

    CGFloat bottomCurrentFieldByScrollView = self.currentEditField.frame.origin.y - visibleRect.origin.y + self.currentEditField.bounds.size.height + TEXTFIELD_OFFSET;
    CGFloat bottomScrollView = self.scrollView.bounds.size.height;
    
    if(bottomCurrentFieldByScrollView != bottomScrollView)
    {
        CGFloat yMove = bottomCurrentFieldByScrollView - bottomScrollView;
        CGFloat newY = (visibleRect.origin.y + yMove < 0) ? 0 : visibleRect.origin.y + yMove;
        
        [UIView animateWithDuration:0.3 animations:^{
          self.scrollView.contentOffset = CGPointMake(visibleRect.origin.x, newY);
        }];
        
    }

}

-(void)keyboardWillHide
{
    [self scrollBottomConstraint].constant = 0;
    [self.view layoutIfNeeded];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = nil;
    self.currentEditField = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.placeholder = textField.restorationIdentifier;
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:textField.restorationIdentifier
                                                                                attributes:@{NSForegroundColorAttributeName : [UIColor bawlRedColor03alpha]}];
    textField.attributedPlaceholder = attrStr;

    
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
                 andViewControllerHandler:^(User *resUser, NSError *error) 
    {
        if (resUser == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up"
                                                                               message:@"Fail to sign Up!"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil];
                               [alert show];
                           });
            
        }
        else
        {
            __weak SingUpViewController *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^
           {
               [CurrentItems sharedItems].user = resUser;
               [weakSelf.navigationController popToRootViewControllerAnimated:YES];
           });
        }
        
    
    }];
}




@end
