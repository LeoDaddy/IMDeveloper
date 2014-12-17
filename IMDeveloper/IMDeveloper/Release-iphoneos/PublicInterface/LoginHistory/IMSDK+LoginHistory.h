//
//  IMSDK+LoginHistory.h
//  IMSDK
//
//  Created by mac on 14-12-5.
//  Copyright (c) 2014年 lyc. All rights reserved.
//

#import "IMSDK.h"

@interface IMSDK (LoginHistory)

@property (nonatomic, assign)BOOL saveHistory;

- (NSArray *)loginHistories;
- (void)removeLoginHistoryWithCustomUserID:(NSString *)customUserID;
- (void)removeLoginHistories;

@end
