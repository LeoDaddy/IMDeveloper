//
//  IMUserDialogViewController.m
//  IMDeveloper
//
//  Created by mac on 14-12-10.
//  Copyright (c) 2014年 IMSDK. All rights reserved.
//

#import "IMUserDialogViewController.h"
#import "IMDefine.h"
#import "IMUserInformationViewController.h"

//IMSDK Headers
#import "IMChatView.h"

@interface IMUserDialogViewController ()<IMChatViewDelegate>

- (void)rightBarButtonItemClick:(id)sender;

@end


@implementation IMUserDialogViewController {
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人信息" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClick:)];
    
    [[self navigationItem] setRightBarButtonItem:_rightBarButtonItem];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.9) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    if([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]){
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    [self setTitle:_customUserID];
    
    CGFloat height = 480 - 64;
    
    if ([UIScreen mainScreen].bounds.size.height > 480) {
        height = 568 - 64;
    }
    
    IMChatView *view = [[IMChatView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    [view setCustomUserID:_customUserID];
    [view setKeyboardHighLightImage:[UIImage imageNamed:@"IM_keyboard_normal.png"]];
    [view setKeyboardNormalImage:[UIImage imageNamed:@"IM_keyboard_normal.png"]];
    [view setFaceHighLightImage:[UIImage imageNamed:@"IM_face_normal.png"]];
    [view setFaceNormalImage:[UIImage imageNamed:@"IM_face_normal.png"]];
    [view setMoreHighLightImage:[UIImage imageNamed:@"IM_more_normal.png"]];
    [view setMoreNormalImage:[UIImage imageNamed:@"IM_more_normal.png"]];
    [view setMicHighLightImage:[UIImage imageNamed:@"IM_mic_normal.png"]];
    [view setMicNormalImage:[UIImage imageNamed:@"IM_mic_normal.png"]];
    [view setInputViewTintColor:RGB(245, 245, 245)];
    [view setSenderTintColor:RGB(44, 164, 232)];
    [view setReceiverTintColor:[UIColor lightGrayColor]];
    [view setParentController:self];
    [view setDelegate:self];
    [[self view] addSubview:view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAutomaticallyAdjustsScrollViewInsets:(BOOL)flag{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.9) {
        [super setAutomaticallyAdjustsScrollViewInsets:flag];
    }
}

- (void)onHeadViewTaped:(NSString *)customUserID {
    IMUserInformationViewController *controller = [[IMUserInformationViewController alloc] init];
    
    [controller setCustomUserID:_customUserID];
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)rightBarButtonItemClick:(id)sender {
    IMUserInformationViewController *controller = [[IMUserInformationViewController alloc] init];
    
    [controller setFromUserDialogView:YES];
    [controller setCustomUserID:_customUserID];
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
