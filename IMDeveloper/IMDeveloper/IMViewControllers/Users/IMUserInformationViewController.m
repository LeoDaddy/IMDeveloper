//
//  IMUserInformationViewController.m
//  IMDeveloper
//
//  Created by mac on 14-12-10.
//  Copyright (c) 2014年 IMSDK. All rights reserved.
//

#import "IMUserInformationViewController.h"
#import "IMDefine.h"
#import "IMFriendRequestViewController.h"
#import "IMUserDialogViewController.h"

//IMSDK Headers
#import "IMSDK+MainPhoto.h"
#import "IMSDK+CustomUserInfo.h"
#import "IMMyself+Relationship.h"

@interface IMUserInformationViewController () <UITableViewDataSource, UITableViewDelegate>

// load head image
- (void)loadHeadImage;
// load custom user information
- (void)loadCustomUserInfomation;
// load relationships
- (void)loadUserRelations;

- (void)buttonClick:(id)sender;
@end

@implementation IMUserInformationViewController {
    UITableView *_tableView;
    
    UIView *_tableHeaderView;
    UIImageView *_headView;
    UILabel *_userNameLabel;
    UILabel *_sexLabel;
    
    UIView *_tableFooterView;
    UIButton *_blackListBtn;
    UIButton *_removeBlacklistBtn;
    UIButton *_chatBtn;
    UIButton *_sendFriendsRequestBtn;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [_titleLabel setText:@"详细资料"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:IMRelationshipDidInitializeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:IMReloadFriendlistNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:IMReloadFriendlistNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStyleGrouped];
    
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [[self view] addSubview:_tableView];
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    
    [_tableView setTableHeaderView:_tableHeaderView];
    
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
    
    [[_headView layer] setCornerRadius:5.0];
    [[_headView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[_headView layer] setBorderWidth:0.3];
    [_headView setContentMode:UIViewContentModeScaleAspectFill];
    [_headView setClipsToBounds:YES];
    [_headView setBackgroundColor:[UIColor clearColor]];
    [_tableHeaderView addSubview:_headView];
    
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headView.right + 10, 10, 200, 30)];
    
    [_userNameLabel setBackgroundColor:[UIColor clearColor]];
    [_userNameLabel setText:_customUserID];
    [_userNameLabel setTextColor:[UIColor blackColor]];
    [_userNameLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [_tableHeaderView addSubview:_userNameLabel];
    
    _sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headView.right + 10, _userNameLabel.bottom, 200, 30)];
    
    [_sexLabel setBackgroundColor:[UIColor clearColor]];
    [_sexLabel setTextColor:[UIColor grayColor]];
    [_sexLabel setFont:[UIFont systemFontOfSize:15]];
    [_tableHeaderView addSubview:_sexLabel];
    
    _tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
    
    [_tableView setTableFooterView:_tableFooterView];
    
    _sendFriendsRequestBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 60, 240, 40)];
    
    [[_sendFriendsRequestBtn layer] setCornerRadius:10.0f];
    [_sendFriendsRequestBtn setBackgroundColor:RGB(41, 140, 38)];
    [_sendFriendsRequestBtn setTitle:@"加为好友" forState:UIControlStateNormal];
    [_tableFooterView addSubview:_sendFriendsRequestBtn];
    
    [_sendFriendsRequestBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    _chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 60, 240, 40)];
    
    [[_chatBtn layer] setCornerRadius:10.0f];
    [_chatBtn setBackgroundColor:RGB(44, 164, 232)];
    [_chatBtn setTitle:@"发送消息" forState:UIControlStateNormal];
    [_tableFooterView addSubview:_chatBtn];
    
    [_chatBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    _blackListBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 120, 240, 40)];
    
    [[_blackListBtn layer] setCornerRadius:10.0f];
    [_blackListBtn setBackgroundColor:RGB(210, 0, 8)];
    [_blackListBtn setTitle:@"加入黑名单" forState:UIControlStateNormal];
    [_tableFooterView addSubview:_blackListBtn];
    
    [_blackListBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _removeBlacklistBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 120, 240, 40)];
    
    [[_removeBlacklistBtn layer] setCornerRadius:10.0f];
    [_removeBlacklistBtn setBackgroundColor:RGB(210, 0, 8)];
    [_removeBlacklistBtn setTitle:@"从黑名单移除" forState:UIControlStateNormal];
    [_tableFooterView addSubview:_removeBlacklistBtn];
    
    [_removeBlacklistBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self loadHeadImage];
    [self loadCustomUserInfomation];
    [self loadUserRelations];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadHeadImage {
    UIImage *image = [g_pIMSDK mainPhotoOfUser:_customUserID];
    
    if (image == nil) {
        [_headView setImage:[UIImage imageNamed:@"IM_head_default.png"]];
        
        [g_pIMSDK requestMainPhotoOfUser:_customUserID success:^(UIImage *mainPhoto) {
            if (mainPhoto) {
                [_headView setImage:mainPhoto];
            }
        } failure:^(NSString *error) {
            NSLog(@"load head image failed for %@",error);
        }];
    } else {
        [_headView setImage:image];
    }
}

- (void)loadCustomUserInfomation {
    [g_pIMSDK requestCustomUserInfoWithCustomUserID:_customUserID success:^(NSString *customUserInfo) {
        if (customUserInfo == nil) {
            return ;
        }
        
        NSArray *array = [customUserInfo componentsSeparatedByString:@"\n"];
        
        if ([array count] > 0) {
            NSString *sex = [array objectAtIndex:0];
            
            if (![sex isEqualToString:@"男"] && ![sex isEqualToString:@"女"] ) {
                sex = @"男";
            }
            [_sexLabel setText:sex];
        }
        
        [_tableView reloadData];
        
    } failure:^(NSString *error) {
        NSLog(@"load custom user information failed for %@",error);
    }];
}

- (void)loadUserRelations {
    if ([[g_pIMMyself customUserID] isEqualToString:_customUserID]) {
        [_chatBtn setHidden:NO];
        [_blackListBtn setHidden:YES];
        [_sendFriendsRequestBtn setHidden:YES];
        [_removeBlacklistBtn setHidden:YES];
    } else if ([g_pIMMyself isMyFriend:_customUserID]) {
        [_chatBtn setHidden:NO];
        [_blackListBtn setHidden:NO];
        [_sendFriendsRequestBtn setHidden:YES];
        [_removeBlacklistBtn setHidden:YES];
    } else if ([g_pIMMyself isMyBlacklistUser:_customUserID]) {
        [_chatBtn setHidden:YES];
        [_blackListBtn setHidden:YES];
        [_sendFriendsRequestBtn setHidden:YES];
        [_removeBlacklistBtn setHidden:NO];
    } else {
        [_chatBtn setHidden:YES];
        [_blackListBtn setHidden:NO];
        [_sendFriendsRequestBtn setHidden:NO];
        [_removeBlacklistBtn setHidden:YES];
    }
    
}

- (void)buttonClick:(id)sender {
    if (sender == _chatBtn) {
        //send message
        if (_fromUserDialogView) {
            [[self navigationController] popViewControllerAnimated:YES];
        } else {
            IMUserDialogViewController *controller = [[IMUserDialogViewController alloc] init];
            
            [controller setCustomUserID:_customUserID];
            [[self navigationController] pushViewController:controller animated:YES];
        }
        
    } else if (sender == _sendFriendsRequestBtn) {
        //send friend request
        IMFriendRequestViewController *controller = [[IMFriendRequestViewController alloc] init];
        
        [controller setCustomUserID:_customUserID];
        [[self navigationController] pushViewController:controller animated:YES];
        
    } else if (sender == _blackListBtn) {
        //move to blacklist
        [g_pIMMyself moveToBlacklist:_customUserID success:^{
            [self loadUserRelations];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:IMReloadBlacklistNotification object:nil];
        } failure:^(NSString *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"加入黑名单失败" message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            [alertView show];
        }];
        
    } else if (sender == _removeBlacklistBtn) {
        //remove from blacklist
        [g_pIMMyself removeUserFromBlacklist:_customUserID success:^{
            [self loadUserRelations];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:IMReloadBlacklistNotification object:nil];
        } failure:^(NSString *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"移除黑名单失败" message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            [alertView show];
        }];
        
    }
}


#pragma mark - table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    NSString *customUserInfo = [g_pIMSDK customUserInfoWithCustomUserID:_customUserID];
    
    NSArray *array = [customUserInfo componentsSeparatedByString:@"\n"];
    
    if ([indexPath row] == 0) {
        [[cell textLabel] setText:@"地区"];
        
        NSString *location = nil;
        if ([array count] >= 2) {
            location = [array objectAtIndex:1];
        }
        
        if (location == nil || [location length] == 0) {
            location = @"未填写";
        }
        [[cell detailTextLabel] setText:location];
        
    } else if ([indexPath row] == 1) {
        [[cell textLabel] setText:@"个性签名"];
        
        NSString *signature = nil;
        if ([array count] >= 3) {
            signature = [array objectAtIndex:2];
        }
        
        if (signature == nil || [signature length] == 0) {
            signature = @"未填写";
        }
        [[cell detailTextLabel] setText:signature];
    }
    
    [[cell detailTextLabel] setTextColor:[UIColor grayColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}


#pragma mark - notifications

- (void)loadData {
    [self loadUserRelations];
    [_tableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
