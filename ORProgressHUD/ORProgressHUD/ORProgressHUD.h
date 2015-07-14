//
//  ORProgressHUD.h
//  ORProgressHUD
//
//  Created by 郭存 on 15-7-14.
//  Copyright (c) 2015年 lucius. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ORProgressHUD : UIView

+ (void)show;
+ (void)hide;
+ (void)showMessage:(NSString *)message;
+ (void)showHudInView:(UIView *)view animated:(BOOL)animated;

// 倒计时
+ (void)showCountdown:(void (^)())failureBlock;;
+ (void)showCountdownWith:(NSInteger)count failure:(void (^)())failureBlock;

@end
