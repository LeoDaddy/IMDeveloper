//
//  IMContactViewController.m
//  IMDeveloper
//
//  Created by mac on 14-12-9.
//  Copyright (c) 2014年 IMSDK. All rights reserved.
//

#import "IMContactViewController.h"
#import "IMSearchUserViewController.h"
#import "IMDefine.h"
#import "NSString+IM.h"
#import "IMUserInformationViewController.h"
#import "IMContactTableViewCell.h"

//IMSDK Headers
#import "IMMyself+Relationship.h"
#import "IMSDK+MainPhoto.h"

@interface IMContactViewController ()<UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

// add friends
- (void)addFriends:(id)sender;
//load data
- (NSMutableArray *)classifyData:(NSArray *)array type:(NSInteger)type;
- (void)segementChanged:(id)sender;
- (void)searchUserForCustomUserID:(NSString *)searchString;
- (NSArray *)searchSubString:(NSString *)searchString inArray:(NSArray *)sourceArray;

//notification function
//- (void)reloadFriendlist;
//- (void)reloadBlacklist;
@end

@implementation IMContactViewController {
    //Data
    NSMutableArray *_friendList;
    NSMutableArray *_blacklist;
    NSMutableArray *_searchResult;
    NSMutableArray *_friendTitles;
    NSMutableArray *_blackTitles;
        
    //UI
    UIBarButtonItem *_rightBarButtonItem;
    UISegmentedControl *_segment;
    UITableView *_tableView;
    UISearchBar *_searchBar;
    UISearchDisplayController *_searchDisplayController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTitle:@"联系人"];
//        [_titleLabel setText:@"联系人"];
        [[self tabBarItem] setImage:[UIImage imageNamed:@"IM_contact_normal.png"]];
     
        _friendTitles = [[NSMutableArray alloc] initWithCapacity:32];
        _blackTitles = [[NSMutableArray alloc] initWithCapacity:32];
        _searchResult = [[NSMutableArray alloc] initWithCapacity:32];
        
        //notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:IMReloadFriendlistNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:IMReloadBlacklistNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:IMRelationshipDidInitializeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addFriends:)];
    
    [[self navigationItem] setRightBarButtonItem:_rightBarButtonItem];
    
    _segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    
    [_segment insertSegmentWithTitle:@"好友列表" atIndex:0 animated:NO];
    [_segment insertSegmentWithTitle:@"黑名单" atIndex:1 animated:NO];
    [_segment setSelectedSegmentIndex:0];
    [_segment setTintColor:RGB(25, 103, 200)];
    [_segment setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor whiteColor],
                                      NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    [[self navigationItem] setTitleView:_segment];
    
    [_segment addTarget:self action:@selector(segementChanged:) forControlEvents:UIControlEventValueChanged];
    
    CGRect rect = [[self view] bounds];
    
    rect.size.height -= 114;
    
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [[self view] addSubview:_tableView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    [_searchBar setDelegate:self];
    [_searchBar setBackgroundColor:[UIColor whiteColor]];
    [_searchBar setPlaceholder:@"搜索好友"];
    
    UIView *customTableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    
    [customTableHeaderView addSubview:_searchBar];
    
    [_tableView setTableHeaderView:customTableHeaderView];

    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    
    [_searchDisplayController setDelegate:self];
    [_searchDisplayController setSearchResultsDataSource:self];
    [_searchDisplayController setSearchResultsDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFriends:(id)sender {
    if (sender != _rightBarButtonItem) {
        return;
    }
    
    IMSearchUserViewController *controller = [[IMSearchUserViewController alloc] init];
    
    [controller setHidesBottomBarWhenPushed:YES];
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)loadData {
    [_friendTitles removeAllObjects];
    [_blackTitles removeAllObjects];
    
    NSArray *friendList = [g_pIMMyself friends];
    
    _friendList = [self classifyData:friendList type:0];
    
    NSArray *blackList = [g_pIMMyself blacklistUsers];
    
    _blacklist = [self classifyData:blackList type:1];
    
    [_tableView reloadData];
}


- (NSMutableArray *)classifyData:(NSArray *)array type:(NSInteger)type {
    NSMutableArray *classificationArray = [[NSMutableArray alloc] initWithCapacity:32];
    
    array = [array sortedArrayUsingFunction:Array_sortByPinyin context:NULL];
    
    NSInteger offset = 0;
    
    NSMutableArray *symbolArray = [[NSMutableArray alloc] initWithCapacity:32];
    
    for (char c = 'A'; c <= 'Z'; c ++) {
        NSMutableArray *characterArray = [[NSMutableArray alloc] initWithCapacity:32];
        
        for (NSInteger i = offset; i < [array count]; i ++) {
            NSString *customUserID = [array objectAtIndex:i];
            
            if (![customUserID isKindOfClass:[NSString class]]) {
                offset ++;
                continue;
            }
            
            if (![[customUserID firstCharactor] isEqualToString:[NSString stringWithFormat:@"%c",c]]) {
                if ([[customUserID firstCharactor] compare:@"A"] == NSOrderedAscending ||
                    [[customUserID firstCharactor] compare:@"Z"] == NSOrderedDescending) {
                    [symbolArray addObject:customUserID];
                    offset ++;
                    continue;
                }
                
                break;
            }
            
            [characterArray addObject:customUserID];
            offset ++;
        }
        
        if ([characterArray count] > 0) {
            if (type == 0) {
                [_friendTitles addObject:[NSString stringWithFormat:@"%c",c]];
            } else {
                [_blackTitles addObject:[NSString stringWithFormat:@"%c",c]];
            }
            
            [classificationArray addObject:characterArray];
        }
    }
    
    if ([symbolArray count] > 0) {
        if (type == 0) {
            [_friendTitles addObject:@"#"];
        } else {
            [_blackTitles addObject:@"#"];
        }
        
        [classificationArray addObject:symbolArray];
    }
    
    return classificationArray;
}

- (void)segementChanged:(id)sender {
    if (sender != _segment) {
        return;
    }
    
    [_tableView reloadData];
}

- (void)searchUserForCustomUserID:(NSString *)searchString {
    [_searchResult removeAllObjects];
    
    if ([_segment selectedSegmentIndex] == 0) {
        [_searchResult addObjectsFromArray:[self searchSubString:searchString inArray:_friendList]];
    } else {
        [_searchResult addObjectsFromArray:[self searchSubString:searchString inArray:_blacklist]];
    }
    
}

- (NSArray *)searchSubString:(NSString *)searchString inArray:(NSArray *)sourceArray {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    for (NSArray *array in sourceArray) {
        if (![array isKindOfClass:[NSArray class]]) {
            continue;
        }
        
        for (NSString *customUserID in array) {
            if (![customUserID isKindOfClass:[NSString class]]) {
                continue;
            }
            
            NSRange range = [[[customUserID pinYin] uppercaseString] rangeOfString:[searchString uppercaseString]];
            
            if (range.location != NSNotFound) {
                [resultArray addObject:customUserID];
            }
        }
    }
    
    NSArray *sortArray = [resultArray sortedArrayUsingFunction:Array_sortByPinyin context:NULL];
    
    return sortArray;
}


#pragma mark - searchBar delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searchUserForCustomUserID:searchString];
    return YES;
}

#pragma mark - table view datasource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == _tableView) {
        if ([_segment selectedSegmentIndex] == 0) {
            return _friendTitles;
        } else {
            return _blackTitles;
        }
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView) {
        if ([_segment selectedSegmentIndex] == 0) {
            if ([_friendTitles count] <= section) {
                return nil;
            }
            
            return [_friendTitles objectAtIndex:section];
        }  else {
            if ([_blackTitles count] <= section) {
                return nil;
            }
            
            return [_blackTitles objectAtIndex:section];
        }

    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView) {
        return 24.0f;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _tableView) {
        if ([_segment selectedSegmentIndex] == 0) {
            return [_friendList count];
        } else if ([_segment selectedSegmentIndex] == 1) {
            return [_blacklist count];
        }
        
        return 0;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tableView) {
        if ([_segment selectedSegmentIndex] == 0) {
            if ([_friendList count] <= section) {
                return 0;
            }
            
            NSMutableArray *array = [_friendList objectAtIndex:section];
            
            return [array count];
        } else if ([_segment selectedSegmentIndex] == 1) {
            if ([_blacklist count] <= section) {
                return 0;
            }
            
            NSMutableArray *array = [_blacklist objectAtIndex:section];
            
            return [array count];
        }
        
        return 0;
    }
    
    return [_searchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[IMContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSString *customUserID = nil;
    
    if (tableView == _tableView) {
        //list
        NSMutableArray *array = nil;
        
        if ([_segment selectedSegmentIndex] == 0) {
            if ([_friendList count] <= [indexPath section]) {
                return cell;
            }
            
            array = [_friendList objectAtIndex:[indexPath section]];
        } else {
            if ([_blacklist count] <= [indexPath section]) {
                return cell;
            }
            
            array = [_blacklist objectAtIndex:[indexPath section]];
        }
        
        if ([array count] <= [indexPath row]) {
            return cell;
        }
        
        customUserID = [array objectAtIndex:[indexPath row]];
    } else {
        //search result
        if ([_searchResult count] <= [indexPath row]) {
            return cell;
        }
        
        customUserID = [_searchResult objectAtIndex:[indexPath row]];
    }
    
    [(IMContactTableViewCell *)cell setCustomUserID: customUserID];
    
    UIImage *image = [g_pIMSDK mainPhotoOfUser:customUserID];
    
    if (image == nil) {
        image = [UIImage imageNamed:@"IM_head_default.png"];
    }
    
    [(IMContactTableViewCell *)cell setHeadPhoto:image];
    
    return cell;
}


#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *customUserID = nil;
    
    if (_tableView == tableView) {
        if ([_segment selectedSegmentIndex] == 0) {
            if ([_friendList count] <= [indexPath section]) {
                return;
            }
            
            NSArray *array = [_friendList objectAtIndex:[indexPath section]];
            
            if (![array isKindOfClass:[NSArray class]]) {
                return;
            }
            
            if ([array count] <= [indexPath row]) {
                return;
            }

            customUserID = [array objectAtIndex:[indexPath row]];
            
            if (![customUserID isKindOfClass:[NSString class]]) {
                return;
            }
            
        } else {
            if ([_blacklist count] <= [indexPath section]) {
                return;
            }
            
            NSArray *array = [_blacklist objectAtIndex:[indexPath section]];
            
            if (![array isKindOfClass:[NSArray class]]) {
                return;
            }
            
            if ([array count] <= [indexPath row]) {
                return;
            }
            
            customUserID = [array objectAtIndex:[indexPath row]];
            
            if (![customUserID isKindOfClass:[NSString class]]) {
                return;
            }

        }
    } else {
        if ([_searchResult count] <= [indexPath row]) {
            return;
        }
        
        customUserID = [_searchResult objectAtIndex:[indexPath row]];
        
        if (![customUserID isKindOfClass:[NSString class]]) {
            return;
        }
    }
    
    IMUserInformationViewController *controller = [[IMUserInformationViewController alloc] init];
    
    [controller setCustomUserID:customUserID];
    [controller setHidesBottomBarWhenPushed:YES];
    [[self navigationController] pushViewController:controller animated:YES];
}


#pragma mark - notifications

- (void)reloadData {
    [self loadData];
}


@end
