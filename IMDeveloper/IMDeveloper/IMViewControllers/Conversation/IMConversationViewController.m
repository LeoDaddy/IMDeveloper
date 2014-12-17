//
//  IMConversationViewController.m
//  IMDeveloper
//
//  Created by mac on 14-12-9.
//  Copyright (c) 2014年 IMSDK. All rights reserved.
//

#import "IMConversationViewController.h"
#import "IMUserDialogViewController.h"

//IMSDK Headers
#import "IMRecentContactsView.h"
#import "IMMyself+RecentContacts.h"

@interface IMConversationViewController ()<IMRecentContactsViewDelegate, IMRecentContactsViewDatasource>

@end

@implementation IMConversationViewController {
    IMRecentContactsView *_recentContactsView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTitle:@"消息"];
        [_titleLabel setText:@"消息"];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"IM_conversation_normal.png"]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _recentContactsView = [[IMRecentContactsView alloc] initWithFrame:[[self view] bounds]];
    
    [_recentContactsView setDataSource:self];
    [_recentContactsView setDelegate:self];
    [[self view] addSubview:_recentContactsView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_recentContactsView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IMRecentContactView delegate

- (void)recentContactsView:(IMRecentContactsView *)recentContactView didSelectRowWithCustomUserID:(NSString *)customUserID {
    IMUserDialogViewController *controller = [[IMUserDialogViewController alloc] init];
    
    [controller setCustomUserID:customUserID];
    [controller setHidesBottomBarWhenPushed:YES];
    [[self navigationController] pushViewController:controller animated:YES];
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
