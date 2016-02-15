//
//  ViewController.m
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "UIColor+Bawl.h"
#import "LogInViewController.h"
#import "DataSorceProtocol.h"
#import "NetworkDataSorce.h"
#import "SingUpViewController.h"
#import "TextFieldValidation.h"
#import "CurrentItems.h"



@interface LogInViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userTextFild;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (strong, nonatomic) NSArray <UITextField*> *textFields;

@property (strong, nonatomic) UITextField *currentEditField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong,nonatomic) id <DataSorceProtocol> dataSorce;
@property(strong, nonatomic) TextFieldValidation *textFieldValidator;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@end

@implementation LogInViewController


-(void)viewDidLoad
{
    self.dataSorce = [[NetworkDataSorce alloc] init];
    self.textFieldValidator = [[TextFieldValidation alloc] init];
    // frame color
    self.textFields = [NSArray arrayWithObjects:self.userTextFild, self.passTextField, nil];
    for (UITextField *textField in self.textFields)
    {
        textField.layer.borderColor = [[UIColor bawlRedColor] CGColor];
        textField.layer.borderWidth = 1;
        textField.layer.cornerRadius = 6;
        
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:textField.restorationIdentifier
                                                                                    attributes:@{NSForegroundColorAttributeName : [UIColor bawlRedColor03alpha]}];
        textField.attributedPlaceholder = attrStr;
    }
    self.loginButton.backgroundColor = [UIColor bawlRedColor];
    self.signupButton.backgroundColor = [UIColor bawlRedColor];
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
    [self.textFieldValidator isValidField:textField];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:textField.restorationIdentifier
                                                                                attributes:@{NSForegroundColorAttributeName : [UIColor bawlRedColorWithAlpha:0.3]}];
    textField.attributedPlaceholder = attrStr;
    
    
    self.currentEditField = nil;
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
                andViewControllerHandler:^(User *resUser)
    {
        if (resUser == nil)
        {
            NSLog(@"fail!!!!");
            dispatch_async(dispatch_get_main_queue(), ^
                           {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In"
                                                            message:@"Fail to log in!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
                           });

        }
        else
        {
            NSLog(@"good!!!!");
            
            dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [CurrentItems sharedItems].user = resUser;
                           [self.navigationController popViewControllerAnimated:YES];
                       });
        }
    } andErrorHandler:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In"
                                                        message:@"Fail yo log in (problem with internet conection)!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }];
}


//#pragma mark - Navigation
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if([segue.identifier isEqualToString:@"fromLogInToSingUp"])
//    {
//        if([segue.destinationViewController isKindOfClass:[SingUpViewController class]])
//        {
//            SingUpViewController *logInVC = (SingUpViewController*)segue.destinationViewController;
//            logInVC.mapDelegate = self.mapDelegate;
//            
//        }
//    }
//}



@end
