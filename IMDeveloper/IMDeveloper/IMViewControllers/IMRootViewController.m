//
//  IMRootViewController.m
//  IMDeveloper
//
//  Created by mac on 14-12-9.
//  Copyright (c) 2014年 IMSDK. All rights reserved.
//

#import "IMRootViewController.h"
#import "IMConversationViewController.h"
#import "IMContactViewController.h"
#import "IMAroundViewController.h"
#import "IMSettingViewController.h"
#import "IMLoginViewController.h"
#import "IMDefine.h"

//IMSDK Headers
#import "IMMyself.h"
#import "IMMyself+CustomMessage.h"
#import "IMMyself+Relationship.h"
#import "IMMyself+Group.h"
#import "IMMyself+CustomUserInfo.h"

#define IM_CONVERSATION_TAG 1
#define IM_CONTACT_TAG 2
#define IM_AROUND_TAG 3
#define IM_SETTING_TAG 4

@interface IMExtraAlertView : UIAlertView

@property (nonatomic, strong) NSObject *extraData;

@end

@implementation IMExtraAlertView

@end

@interface IMRootViewController ()<UITabBarControllerDelegate, IMRelationshipDelegate, IMMyselfDelegate, IMCustomUserInfoDelegate, IMGroupDelegate>

- (void)logout;

@end

@implementation IMRootViewController{
    UITabBarController *_tabBarController;
    UINavigationController *_contactNav;
    UINavigationController *_conversationNav;
    UINavigationController *_aroundNav;
    UINavigationController *_settingNav;
    
    IMLoginViewController *_loginController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:IMLogoutNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationController] setNavigationBarHidden:YES];
    
    _tabBarController = [[UITabBarController alloc] init];
    
    [self addChildViewController:_tabBarController];
    [[_tabBarController view] setFrame:[[self view] bounds]];
    [[_tabBarController view] setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    _tabBarController.delegate = self;
    
    [self.view addSubview:_tabBarController.view];
    
    IMConversationViewController *coversationCtrl = [[IMConversationViewController alloc] init];
    _conversationNav = [[UINavigationController alloc] initWithRootViewController:coversationCtrl];
    
    [[_conversationNav tabBarItem] setTag:IM_CONVERSATION_TAG];
    
    IMContactViewController *contactCtrl = [[IMContactViewController alloc] init];
    _contactNav = [[UINavigationController alloc] initWithRootViewController:contactCtrl];
    
    [[_contactNav tabBarItem] setTag:IM_CONTACT_TAG];
    
    IMAroundViewController *aroundCtrl = [[IMAroundViewController alloc] init];
    _aroundNav = [[UINavigationController alloc] initWithRootViewController:aroundCtrl];
    
    [[_aroundNav tabBarItem] setTag:IM_AROUND_TAG];
    
    IMSettingViewController *settingCtrl = [[IMSettingViewController alloc] init];
    _settingNav = [[UINavigationController alloc] initWithRootViewController:settingCtrl];
    
    [[_settingNav tabBarItem] setTag:IM_SETTING_TAG];
    
    NSArray *navArray = [NSArray arrayWithObjects:_conversationNav,_contactNav,_aroundNav,_settingNav, nil];
    
    [_tabBarController setViewControllers:navArray];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //设置IMMyself 代理
    [g_pIMMyself setDelegate:self];
    [g_pIMMyself setRelationshipDelegate:self];
    [g_pIMMyself setGroupDelegate:self];
    [g_pIMMyself setCustomUserInfoDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logout {
    [_tabBarController setSelectedIndex:0];
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - IMMyself delegate

- (void)didLogoutFor:(NSString *)reason {
    NSLog(@"%@",[g_pIMMyself customUserID]);
    if ([[reason uppercaseString] isEqualToString:@"USER LOGOUT"] || [[reason uppercaseString] isEqualToString:@"LOGIN CONFLICT"]) {
        if ([[reason uppercaseString] isEqualToString:@"LOGIN CONFLICT"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的账号在别处登录" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            [alert show];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:IMLogoutNotification object:nil];
        return;
    }
    
    [g_pIMMyself login];
}


#pragma mark - IMMyself custom userinfo delegate

- (void)customUserInfoDidInitialize {
    [[NSNotificationCenter defaultCenter] postNotificationName:IMCustomUserInfoDidInitializeNotification object:nil];
}


#pragma mark - IMMyself group delegate

- (void)groupListDidInitialize {
    [[NSNotificationCenter defaultCenter] postNotificationName:IMGroupListDidInitializeNotification object:nil];
}

#pragma mark - IMMyself relationship delegate

- (void)relationshipDidInitialize {
    [[NSNotificationCenter defaultCenter] postNotificationName:IMRelationshipDidInitializeNotification object:nil];
}

- (void)didReceiveAgreeToFriendRequestFromUser:(NSString *)customUserID serverSendTime:(UInt32)timeIntervalSince1970 {
    [[NSNotificationCenter defaultCenter] postNotificationName:IMReloadFriendlistNotification object:nil];
}

- (void)didReceiveFriendRequest:(NSString *)text fromCustomUserID:(NSString *)customUserID serverSendTime:(UInt32)timeIntervalSince1970 {
    IMExtraAlertView *alertView = [[IMExtraAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ 请求加为好友", customUserID] message:text delegate:nil cancelButtonTitle:@"忽略" otherButtonTitles:@"同意", @"拒绝", nil];
    
    [alertView setExtraData:customUserID];
    [alertView setDelegate:self];
    [alertView show];
}

- (void)didBuildFriendRelationshipWithUser:(NSString *)customUserID {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"添加好友成功" message:[NSString stringWithFormat:@"你已添加 %@ 为好友", customUserID] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alertView show];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userRelationUpdated" object:nil];
}

- (void)didReceiveRejectFromCustomUserID:(NSString *)customUserID serverSendTime:(UInt32)timeIntervalSince1970 reason:(NSString *)reason {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"%@ 拒绝加你为好友", customUserID] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alertView show];
}

#pragma mark - alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![alertView isKindOfClass:[IMExtraAlertView class]]) {
        return;
    }
    
    IMExtraAlertView *extraAlertView = (IMExtraAlertView *)alertView;
    NSString *customUserID = (NSString *)[extraAlertView extraData];
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [g_pIMMyself agreeToFriendRequestFromUser:customUserID];
            break;
        case 2:
            [g_pIMMyself rejectToFriendRequestFromUser:customUserID reason:@""];
            break;
        default:
            break;
    }
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
