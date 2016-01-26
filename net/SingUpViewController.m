//
//  SingUpViewController.m
//  net
//
//  Created by Admin on 11.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//
#import <Quartzcore/QuartzCore.h>

#import "DataSorceProtocol.h"
#import "NetworkDataSorce.h"
#import "SingUpViewController.h"
#import "User.h"
#import "TextFieldValidation.h"

#define R_COLOR 0.88235294117647056
#define G_COLOR 0.21176470588235294
#define B_COLOR 0.33333333333333331
#define COLOR_MULT 1.5


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
        textField.layer.borderColor = [[UIColor colorWithRed:R_COLOR green:G_COLOR blue:B_COLOR alpha:0.5] CGColor];
        textField.layer.borderWidth = 1;
        textField.layer.cornerRadius = 6;
        
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:textField.restorationIdentifier
                                                                                    attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:R_COLOR green:G_COLOR blue:B_COLOR alpha:0.3]}];
       textField.attributedPlaceholder = attrStr;

    }
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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

-(NSString*)pringRectforDebug:(CGRect) rect
{
    return [NSString stringWithFormat:@"rect: (origin: %f,%f) (size: %f, %f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

-(void)keyboardDidShow:(NSNotification*)notification
{
    NSLog(@"ScrollView before: %@\n\n", self.scrollView);
    NSDictionary *dic = notification.userInfo;
    NSValue *keyboardFrame = dic[UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [keyboardFrame CGRectValue];
    CGRect viewFrame = [self.view convertRect:frame fromView:nil];
    CGFloat keyboardHeight = viewFrame.size.height;
    NSLog(@"keyboard height = %f", keyboardHeight);
    
    [self scrollBottomConstraint].constant = keyboardHeight;
    [self.view layoutIfNeeded];
    NSLog(@"-(void)keyboardDidShow, and self.currentTextField = %@", self.currentEditField.restorationIdentifier);

    
    NSLog(@"View : %@\n\n", self.view);
    NSLog(@"ScrollView after: %@\n\n", self.scrollView);
    NSLog(@"ContentView : %@\n\n", self.contentView);
    NSLog(@"KeyboardHeight : %f\n\n", keyboardHeight);
    
    
    
    // code belowe don't work :( and it's important to understand why!
    if (self.currentEditField == nil)
        return;
    
    CGRect visibleRect = [self.scrollView convertRect:self.scrollView.bounds toView:self.contentView];
    NSLog(@"VisibleRect : %@\n\n", [self pringRectforDebug:visibleRect]);

    
    NSLog(@"TextField frame : %@\n\n", [self pringRectforDebug:self.currentEditField.frame]);
    NSLog(@"TextField bounds : %@\n\n", [self pringRectforDebug:self.currentEditField.bounds]);
    
    CGFloat bottomCurrentFieldByScrollView = self.currentEditField.frame.origin.y - visibleRect.origin.y + self.currentEditField.bounds.size.height + TEXTFIELD_OFFSET;
    CGFloat bottomScrollView = self.scrollView.bounds.size.height;
    
    if(bottomCurrentFieldByScrollView != bottomScrollView)
    {
        CGFloat yMove = bottomCurrentFieldByScrollView - bottomScrollView;
        CGFloat newY = (visibleRect.origin.y + yMove < 0) ? 0 : visibleRect.origin.y + yMove;
        
        [UIView animateWithDuration:0.3 animations:^{
          self.scrollView.contentOffset = CGPointMake(visibleRect.origin.x, newY);
        }];
        
        NSLog(@"--------------------------------------\n\n\n\n");
    }

}

-(void)keyboardWillHide
{
    NSLog(@"-(void)keyboardWillHide");
    [self scrollBottomConstraint].constant = 0;
    [self.view layoutIfNeeded];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = @"";
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
                                                                                attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:R_COLOR green:G_COLOR blue:B_COLOR alpha:0.3]}];
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
