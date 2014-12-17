//
//  ModifyPasswordViewController.m
//  IMSDK
//
//  Created by mac on 14-12-9.
//  Copyright (c) 2014年 lyc. All rights reserved.
//

#import "IMModifyPasswordViewController.h"
#import "IMDefine.h"

//IMSDK Headers
#import "IMMyself+UserPassword.h"

@interface IMModifyPasswordViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation IMModifyPasswordViewController {
    UITableView *_tableView;
    UITextField *_oldPasswordField;
    UITextField *_newPasswordField;
    UITextField *_confirmField;
    UIBarButtonItem *_rightBarButtonItem;
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

    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    _tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStyleGrouped];
    
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)]];
    [_tableView setTableFooterView:[[UIView alloc] init]];
    [[self view] addSubview:_tableView];
    
    _oldPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(120, 0, 190, 40)];
    
    [_oldPasswordField setPlaceholder:@"请输入当前密码"];
    [_oldPasswordField setSecureTextEntry:YES];
    [_oldPasswordField setBorderStyle:UITextBorderStyleNone];
    [_oldPasswordField setDelegate:self];
    [_oldPasswordField becomeFirstResponder];
    [_oldPasswordField setFont:[UIFont systemFontOfSize:16]];
    [_oldPasswordField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [_oldPasswordField setTextColor:[UIColor lightGrayColor]];
    [_oldPasswordField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    _newPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(120, 0, 190, 40)];
    
    [_newPasswordField setPlaceholder:@"不能超过16位"];
    [_newPasswordField setSecureTextEntry:YES];
    [_newPasswordField setBorderStyle:UITextBorderStyleNone];
    [_newPasswordField setDelegate:self];
    [_newPasswordField setFont:[UIFont systemFontOfSize:16]];
    [_newPasswordField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [_newPasswordField setTextColor:[UIColor lightGrayColor]];
    [_newPasswordField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    _confirmField = [[UITextField alloc] initWithFrame:CGRectMake(120, 0, 190, 40)];
    
    [_confirmField setPlaceholder:@"请再次输入新密码"];
    [_confirmField setSecureTextEntry:YES];
    [_confirmField setBorderStyle:UITextBorderStyleNone];
    [_confirmField setDelegate:self];
    [_confirmField setFont:[UIFont systemFontOfSize:16]];
    [_confirmField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [_confirmField setTextColor:[UIColor lightGrayColor]];
    [_confirmField setClearButtonMode:UITextFieldViewModeWhileEditing];
 
    _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];
    
    [[self navigationItem] setRightBarButtonItem:_rightBarButtonItem];

}

- (void)rightBarButtonClick:(id)sender {
    if (sender == _rightBarButtonItem) {
        if ([[_oldPasswordField text] length] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请输入当前密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            [alertView show];
            
            return;
        }
        
        if ([[_newPasswordField text] length] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请输入新密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            [alertView show];
            
            return;
        }
        
        if ([[_confirmField text] length] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请重复新密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            [alertView show];
            
            return;
        }
        
        if (![[_newPasswordField text] isEqualToString:[_confirmField text]]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"两次输入密码不一致" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            [alertView show];
            
            return;
        }
        
        [g_pIMMyself modifyOldPassword:[_oldPasswordField text]
                         toNewPassword:[_newPasswordField text] success:^{
                                   NSLog(@"modify password successed");
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                             
                             [alert show];
                                }
                               failure:^(NSString *error) {
                                   NSLog(@"modify password failed for %@",error);
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改失败" message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                   
                                   [alert show];
                               }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - textField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [[self view] endEditing:YES];
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([[textField text] length] + [string length] > 16 ) {
        
        return NO;
    }
    
    return YES;
}


#pragma mark - table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    switch ([indexPath row]) {
        case 0:
        {
            [[cell textLabel] setText:@"当前密码"];
            [[cell contentView] addSubview:_oldPasswordField];
            [[cell textLabel] setFont:[UIFont systemFontOfSize:16]];
        }
            break;
        case 1:
        {
            [[cell textLabel] setText:@"新密码"];
            [[cell contentView] addSubview:_newPasswordField];
        }
            break;
        case 2:
        {
            [[cell textLabel] setText:@"重复密码"];
            [[cell contentView] addSubview:_confirmField];
        }
            break;
        default:
            break;
    }
    
    return cell;
}
@end
