//
//  IMRecentContactsView.h
//  IMSDK
//
//  Created by lyc on 14-10-4.
//  Copyright (c) 2014年 lyc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMRecentContactsView;

@protocol IMRecentContactsViewDatasource <NSObject>

@optional

- (UIView *)recentContactsView:(IMRecentContactsView *)recentContactView viewAtIndex:(NSInteger)index;

@end

@protocol IMRecentContactsViewDelegate <NSObject>

- (void)recentContactsView:(IMRecentContactsView *)recentContactView didSelectRowWithCustomUserID:(NSString *)customUserID;

@end

@interface IMRecentContactsView : UIView<IMRecentContactsViewDatasource, IMRecentContactsViewDelegate>

@property (nonatomic, weak) id<IMRecentContactsViewDatasource> dataSource;
@property (nonatomic, weak) id<IMRecentContactsViewDelegate> delegate;

- (void)reloadData;
@end
