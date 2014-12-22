//
//  IMFriendRequestViewController.m
//  IMDeveloper
//
//  Created by mac on 14-12-10.
//  Copyright (c) 2014年 IMSDK. All rights reserved.
//

#import "IMFriendRequestViewController.h"

//IMSDK Headers
#import "IMMyself+Relationship.h"

@interface IMFriendRequestViewController ()<UITableViewDataSource, UITextFieldDelegate>

- (void)rightBarButtonItemClick;

@end

@implementation IMFriendRequestViewController {
    UITableView *_tableView;
    UITextField *_textField;
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
    _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClick)];
    
    [[self navigationItem] setRightBarButtonItem:_rightBarButtonItem];
    
    _tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStyleGrouped];
    
    [_tableView setDataSource:self];
    [[self view] addSubview:_tableView];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    
    [_tableView setTableHeaderView:tableHeaderView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 310, 40)];
    
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:@"你需要发送验证申请，等对方通过"];
    [label setTextColor:[UIColor grayColor]];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    [tableHeaderView addSubview:label];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
    
    [_textField setDelegate:self];
    [_textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightBarButtonItemClick {
    [g_pIMMyself sendFriendRequest:[_textField text] toUser:_customUserID success:^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发送好友请求成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
        [alertView show];
        
        [[self navigationController] popViewControllerAnimated:YES];
    } failure:^(NSString *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发送好友请求失败" message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
        [alertView show];
    }];
}


#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_textField resignFirstResponder];
    
    return NO;
}


#pragma mark - table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    [[cell contentView] addSubview:_textField];
    
    return cell;
}

@end
