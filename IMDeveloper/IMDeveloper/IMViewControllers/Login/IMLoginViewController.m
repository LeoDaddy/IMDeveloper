//
//  IMLoginViewController.m
//  IMDeveloper
//
//  Created by mac on 14-12-9.
//  Copyright (c) 2014年 IMSDK. All rights reserved.
//

#import "IMLoginViewController.h"
#import "IMDefine.h"
#import "UIView+IM.h"
#import "IMRootViewController.h"

//third-party
#import "SFCountdownView.h"

//IMSDK Header
#import "IMMyself.h"
#import "IMSDK+MainPhoto.h"

@interface IMLoginViewController ()<UITableViewDataSource, UITableViewDelegate ,UITextFieldDelegate>

//login
- (void)login:(id)sender;

@end

@implementation IMLoginViewController {
    UITableView *_tableview;
    UITextField *_userNameField;
    UITextField *_passwordField;
    UIButton *_loginBtn;
    UIImageView *_backgroundView;
    UIView *_backHeadView;
    UIImageView *_headView;
    
    //third-party
    SFCountdownView *_countdownView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _backgroundView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [_backgroundView setImage:[UIImage imageNamed:@"IM_login_background.png"]];
    [[self view] addSubview:_backgroundView];
    
    CGRect rect = [[self view] bounds];
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, rect.size.height / 2 - 44, 320, 88) style:UITableViewStyleGrouped];
    
    [_tableview setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableview setDataSource:self];
    [_tableview setDelegate:self];
    [_tableview setTableFooterView:nil];
    [[self view] addSubview:_tableview];
    
    _backHeadView = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width / 2 - 42 , _tableview.top - 134, 84, 84)];
    
    [_backHeadView setBackgroundColor:[UIColor whiteColor]];
    [[_backHeadView layer] setCornerRadius:42.0f];
    [[self view] addSubview:_backHeadView];
    
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 80, 80)];
    
    [[_headView layer] setCornerRadius:40.0f];
    [_headView setImage:[UIImage imageNamed:@"IM_head_default.png"]];
    [_headView setContentMode:UIViewContentModeScaleAspectFill];
    [_headView setClipsToBounds:YES];
    [_backHeadView addSubview:_headView];
    
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, rect.size.height / 2 - 46, 320, 2)];
    
    [line1 setBackgroundColor:[UIColor whiteColor]];
    [_tableview setTableHeaderView:line1];
    [[self view] addSubview:line1];
    
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, rect.size.height / 2 + 44, 320, 2)];
    
    [line2 setBackgroundColor:[UIColor whiteColor]];
    [[self view] addSubview:line2];

    _userNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    [_userNameField setPlaceholder:@"请输入用户名"];
    [_userNameField setTextAlignment:NSTextAlignmentCenter];
    [_userNameField setBackgroundColor:[UIColor clearColor]];
    [_userNameField setDelegate:self];
    [_userNameField setReturnKeyType:UIReturnKeyNext];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    [_passwordField setPlaceholder:@"请输入密码"];
    [_passwordField setTextAlignment:NSTextAlignmentCenter];
    [_passwordField setBackgroundColor:[UIColor clearColor]];
    [_passwordField setSecureTextEntry:YES];
    [_passwordField setDelegate:self];
    [_passwordField setReturnKeyType:UIReturnKeyDone];
    
    _loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, line2.bottom + 60, 240, 50)];
    
    [_loginBtn setBackgroundColor:[UIColor clearColor]];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"IM_loginBtn_background.png"] forState:UIControlStateNormal];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [[_loginBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:18]];
    [[self view] addSubview:_loginBtn];
    
    [_loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSMutableString *customUserID = [[NSMutableString alloc] initWithFormat:@"%@",[_userNameField text]];
    
    UIImage *image = [g_pIMSDK mainPhotoOfUser:customUserID];
    
    if (image) {
        [_headView setImage:image];
    } else {
        [_headView setImage:[UIImage imageNamed:@"IM_head_default.png"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login:(id)sender {
    if (sender != _loginBtn) {
        return;
    }
    
    NSString *customUserID = [_userNameField text];
    NSString *password = [_passwordField text];
    
    if ([customUserID length] > 0) {
        if ([password length] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请输入密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alertView show];
            return;
        }
        
        [g_pIMMyself initWithCustomUserID:customUserID appKey:@"00b6413a92d4c1c84ad99e0a"];
        
        [g_pIMMyself setPassword:password];
        [g_pIMMyself setAutoLogin:NO];
        [g_pIMMyself loginWithTimeoutInterval:10
                                      success:^(BOOL autoLogin) {
                                          NSLog(@"login successed");
                                          IMRootViewController *controller = [[IMRootViewController alloc] init];
                                          
                                          [self presentViewController:controller animated:NO completion:NULL];
                                          
                                          [_countdownView removeFromSuperview];
                                          _countdownView = nil;
                                          
                                          [_passwordField setText:nil];
                                          [[self view] endEditing:YES];
                                      }
                                      failure:^(NSString *error) {
                                          NSLog(@"login failed for %@",error);
                                          
                                          if ([error isEqualToString:@"Wrong Password"]) {
                                              error = @"密码错误,请重新输入";
                                          }
                                          
                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录失败" message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                          
                                          [alertView show];
                                          
                                          [_countdownView removeFromSuperview];
                                          _countdownView = nil;
                                      }];
        
        _countdownView = [[SFCountdownView alloc] initWithFrame:[self view].bounds];
        
        [_countdownView setCountdownFrom:10];
        [_countdownView start];
        [[self view] addSubview:_countdownView];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请输入用户名" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alertView show];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}


#pragma mark - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    if ([indexPath row] == 0) {
        [[cell contentView] addSubview:_userNameField];
    } else if ([indexPath row] == 1) {
        [[cell contentView] addSubview:_passwordField];
    }
    
    [cell setBackgroundColor:RGB(223, 235, 240)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}


#pragma mark - textfield

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _userNameField) {
        [_userNameField resignFirstResponder];
        [_passwordField becomeFirstResponder];
        
        return NO;
    } else if (textField == _passwordField) {
        [_userNameField resignFirstResponder];
        [_passwordField resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _userNameField) {
        if ([[textField text] length] + [string length] > 32 ) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"用户名不能超过32个字节" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alertView show];
            
            return NO;
        }
        
        NSMutableString *customUserID = [[NSMutableString alloc] initWithFormat:@"%@",[textField text]];
        
        [customUserID replaceCharactersInRange:range withString:string];
        
         UIImage *image = [g_pIMSDK mainPhotoOfUser:customUserID];
        
        if (image) {
            [_headView setImage:image];
        } else {
            [_headView setImage:[UIImage imageNamed:@"IM_head_default.png"]];
        }
    }
    
    if (textField == _passwordField) {
        if ([[textField text] length] + [string length] > 16 ) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"密码不能超过16位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alertView show];
            
            return NO;
        }
    }
    return YES;
}


#pragma mark - keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note {
    
}

- (void)keyboardWillHide:(NSNotification *)note {
    
}
@end
