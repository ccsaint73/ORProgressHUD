//
//  ORViewController.m
//  ORProgressHUD
//
//  Created by 郭存 on 15-7-14.
//  Copyright (c) 2015年 lucius. All rights reserved.
//

#import "ORViewController.h"
#import "ORProgressHUD.h"

@interface ORViewController ()

@end

@implementation ORViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[ORProgressHUD showMessage:@"正在加载"];
    
    [ORProgressHUD showCountdownWith:10 failure:^{
        [ORProgressHUD hide];
    }];
}

@end
