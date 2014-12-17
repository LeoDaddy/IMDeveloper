//
//  IMAroundUsersView.h
//  IMSDK
//
//  Created by lyc on 14-10-5.
//  Copyright (c) 2014年 lyc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMUserLocation.h"

@class IMAroundUsersView;

@protocol IMAroundUsersViewDataSource <NSObject>
@optional
- (UIView *)aroundUsersView:(IMAroundUsersView *)aroundUsersView viewAtRowIndex:(NSInteger)rowIndex;
@end

@protocol IMAroundUsersViewDelegate <NSObject>
@optional
- (void)aroundUsersView:(IMAroundUsersView *)aroundUsersView didSelectRowWithUserLocation:(IMUserLocation *)userLocation;
@end

@interface IMAroundUsersView : UIView

@property (nonatomic, weak) id<IMAroundUsersViewDataSource> dataSource;
@property (nonatomic, weak) id<IMAroundUsersViewDelegate> delegate;

- (void)update;
- (void)reloadData;


@end
