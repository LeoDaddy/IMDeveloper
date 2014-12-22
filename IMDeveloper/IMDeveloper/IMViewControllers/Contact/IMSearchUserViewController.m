//
//  IMSearchUserViewController.m
//  IMDeveloper
//
//  Created by mac on 14-12-10.
//  Copyright (c) 2014年 IMSDK. All rights reserved.
//

#import "IMSearchUserViewController.h"
#import "IMAroundViewCell.h"
#import "IMUserInformationViewController.h"
#import "IMDefine.h"

//IMSDK Headers
#import "IMSDK+CustomUserInfo.h"
#import "IMSDK+MainPhoto.h"

@interface IMSearchUserViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@end

@implementation IMSearchUserViewController {
    //UI
    UITableView *_tableView;
    UISearchBar *_searchBar;
    UISearchDisplayController *_searchDisplayController;
    
    //data
    NSMutableArray *_searchResult;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [_titleLabel setText:@"添加朋友"];
        
        _searchResult = [[NSMutableArray alloc] initWithCapacity:32];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView = [[UITableView alloc] initWithFrame:[[self view] bounds]  style:UITableViewStylePlain];
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [[self view] addSubview:_tableView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    [_searchBar setPlaceholder:@"请填写你要添加的用户名"];
    [_searchBar setDelegate:self];
    [_tableView setTableHeaderView:_searchBar];
    
    [_tableView setTableFooterView:[[UIView alloc] init]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    IMAroundViewCell *cellView = [[IMAroundViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    
    UIImage *image = [g_pIMSDK mainPhotoOfUser:[_searchBar text]];
    
    if (image == nil) {
        image = [UIImage imageNamed:@"IM_head_default.png"];
        
        [g_pIMSDK requestMainPhotoOfUser:[_searchBar text] success:^(UIImage *mainPhoto) {
            if (mainPhoto) {
                [cellView setHeadPhoto:mainPhoto];
                [[NSNotificationCenter defaultCenter] postNotificationName:IMReloadMainPhotoNotification([_searchBar text]) object:nil];
            }
        } failure:^(NSString *error) {
            
        }];
    }
    
    [cellView setHeadPhoto:image];
    [cellView setCustomUserID:[_searchBar text]];
    
    NSString *customUserInfo = [g_pIMSDK customUserInfoWithCustomUserID:[_searchBar text]];
    
    if (customUserInfo == nil) {
        [g_pIMSDK requestCustomUserInfoWithCustomUserID:[_searchBar text] success:^(NSString *customUserInfo) {
            NSArray *array = [customUserInfo componentsSeparatedByString:@"\n"];
            
            if ([array count] >= 3) {
                [cellView setSignature:[array objectAtIndex:2]];
            }
            
        } failure:^(NSString *error) {
            
        }];
    } else {
        NSArray *array = [customUserInfo componentsSeparatedByString:@"\n"];
        
        if ([array count] >= 3) {
            [cellView setSignature:[array objectAtIndex:2]];
        }
    }
    [cellView setTag:[indexPath row] + 1];

    for (UIView *view in [[cell contentView] subviews]) {
        [view removeFromSuperview];
    }
    [[cell contentView] addSubview:cellView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IMUserInformationViewController *controller = [[IMUserInformationViewController alloc] init];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    IMAroundViewCell *cellView = nil;
    
    for (UIView *view in [[cell contentView] subviews]) {
        if ([view tag] == [indexPath row] + 1 && [view isKindOfClass:[IMAroundViewCell class]]) {
            cellView = (IMAroundViewCell *)view;
            break;
        }
    }
    
    [controller setCustomUserID:[cellView customUserID]];
    [controller setHidesBottomBarWhenPushed:YES];
    [[self navigationController] pushViewController:controller animated:YES];
}


#pragma mark - searchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [[self view] endEditing:YES];
    [_searchResult removeAllObjects];
    
    [g_pIMSDK requestCustomUserInfoWithCustomUserID:[searchBar text] success:^(NSString *customUserInfo) {
        [_searchResult addObject:[searchBar text]];
        [_tableView reloadData];
    } failure:^(NSString *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无结果" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
        [alertView show];
        
        [_tableView reloadData];
    }];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setText:nil];
    [searchBar setShowsCancelButton:NO animated:YES];
    [[self view] endEditing:YES];
    
    [_searchResult removeAllObjects];
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
