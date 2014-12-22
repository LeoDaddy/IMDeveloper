//
//  IMDefine.h
//  IMDeveloper
//
//  Created by mac on 14-12-9.
//  Copyright (c) 2014年 IMSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+IM.h"
#import "UIImage+IM.h"

#define IMDeveloper_APPKey @"d3fecc6841c022fc7b7021dd"

#define RGB(r, g, b) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1]

#define IMLogoutNotification @"IMLogoutNotification"
#define IMGroupListDidInitializeNotification @"IMGroupListDidInitializeNotification"
#define IMRelationshipDidInitializeNotification @"IMRelationshipDidInitializeNotification"
#define IMCustomUserInfoDidInitializeNotification @"IMCustomUserInfoDidInitializeNotification"
#define IMReloadBlacklistNotification @"IMReloadBlacklistNotification"
#define IMReloadFriendlistNotification @"IMReloadFriendlistNotification"
#define IMReloadMainPhotoNotification(customUserID) [NSString stringWithFormat:@"IMReloadMainPhotoNotification%@",customUserID]



