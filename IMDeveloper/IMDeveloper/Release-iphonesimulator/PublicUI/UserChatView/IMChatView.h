//
//  IMChatView.h
//  GGTalk
//
//  Created by Daniel Lee on 12-7-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IMHeadViewStyle) {
    IMHeadViewStyleDefault = 0,     //default is squre
    IMHeadViewStyleSqure = 1,
    IMHeadViewStyleRectangle = 2,
    IMHeadViewStyleCircle  = 3,   
};

@protocol IMChatViewDelegate <NSObject>

- (void)onHeadViewTaped:(NSString *)customUserID;

@end

@interface IMChatView : UIView<IMChatViewDelegate>

@property (nonatomic, weak)id<IMChatViewDelegate> delegate;

@property (nonatomic, copy) NSString *customUserID; // Opposite CustomUserID

@property (nonatomic, strong) UIColor *senderTintColor;   // default for green
@property (nonatomic, strong) UIColor *receiverTintColor;   // default for gray

@property (nonatomic, assign) CGFloat cellVerticalInterval; // default for 10
@property (nonatomic, assign) CGFloat cellMaxWidth; // Default for [self frame].size.width
@property (nonatomic, strong) UIFont *font; // Default for systemFont 15
@property (nonatomic, strong) UIColor *fontColor; // Default for black

@property (nonatomic, strong) UIColor *inputViewTintColor;
/*face button state normal,default for DTFace_normal.png*/
@property (nonatomic, strong) UIImage *faceNormalImage;
/*face button state highlight,default for DTFace_selected.png*/
@property (nonatomic, strong) UIImage *faceHighLightImage;
/*keyborad button state normal,default for DTKeyboard_normal.png*/
@property (nonatomic, strong) UIImage *keyboardNormalImage;
/*keyborad button state hightlight,default for DTKeyboard_selected.png*/
@property (nonatomic, strong) UIImage *keyboardHighLightImage;

@property (nonatomic, strong) UIImage *micNormalImage;
@property (nonatomic, strong) UIImage *micHighLightImage;

@property (nonatomic, strong) UIImage *moreNormalImage;
@property (nonatomic, strong) UIImage *moreHighLightImage;
/*bubble mask image,default for DTImageMask.png*/
@property (nonatomic, strong) UIImage *bubbleMaskImage;

@property (nonatomic, strong) UIImage *defaultHeadImage;

@property (nonatomic, assign) IMHeadViewStyle headViewStyle;

/*if backgroundImage != nil && backgroundColor != nil,backgroundImage  has higher priority;
 so if you want to set backgroundColor,you must ensure backgroundImage is equal nil*/
@property (nonatomic, strong) UIImage *backgroundImage;


@property (nonatomic, weak)UIViewController *parentController;
@end







