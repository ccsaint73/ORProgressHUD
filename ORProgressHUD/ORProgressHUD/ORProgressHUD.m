//
//  ORProgressHUD.m
//  ORProgressHUD
//
//  Created by 郭存 on 15-7-14.
//  Copyright (c) 2015年 lucius. All rights reserved.
//

#import "ORProgressHUD.h"

#define ORScreenH  [UIScreen mainScreen].bounds.size.height
#define ORScreenW  [UIScreen mainScreen].bounds.size.width
#define ORMargin   10.0f
#define ProgressW  60.0f
#define ORFont     [UIFont boldSystemFontOfSize:13]
#define CountFont  [UIFont boldSystemFontOfSize:36]
#define ORInterval 1.0f

@interface ORProgressHUD()

@property (nonatomic, strong) UIView      *contentView;
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIImageView *progressView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *detailLabel;
@property (nonatomic, assign) NSInteger   count;
@property (nonatomic, strong) NSTimer     *timer;
@property (nonatomic, copy) void (^failureBlock)();

@end

@implementation ORProgressHUD

#pragma mark -- --
+ (ORProgressHUD *)sharedHUD
{
    static ORProgressHUD *sharedView = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedView = [[ORProgressHUD alloc] init];
    });
    
    return sharedView;
}

- (instancetype)init
{
    if ([super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.frame = CGRectMake((ORScreenW - ProgressW) * 0.5 - ORMargin, (ORScreenH - ProgressW) * 0.5 - ORMargin, ProgressW + ORMargin * 2, ProgressW + ORMargin *2);
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.alpha = 0.75;
        self.progressView.image = [UIImage imageNamed:@"ORProgressHUD.bundle/HRProgress"];
        self.progressView.backgroundColor = [UIColor clearColor];
        self.bgView.layer.cornerRadius = 5.0f;
        self.count = 60;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)showHudInView:(UIView *)view animated:(BOOL)animated
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    
    self.frame = view.bounds;
    self.userInteractionEnabled = YES;
    
    [view addSubview:self];
    
    if (animated) {
        [self showAnimation];
    }
}

+ (void)showHudInView:(UIView *)view animated:(BOOL)animated
{
    [[self sharedHUD] showHudInView:view animated:animated];
}

- (void)showMessage:(NSString *)message
{
    if (message && message.length > 0) {
        [self updateViewWithMessage:message];
        [self showHudInView:nil animated:YES];
    } else {
        [self showHudInView:nil animated:YES];
    }
}

- (void)updateViewWithMessage:(NSString *)message
{
    [self updateViewWithMessage:message withFont:ORFont];
}

- (void)updateViewWithMessage:(NSString *)message withFont:(UIFont *)font
{
    CGSize maxSize = CGSizeMake(138.0f, MAXFLOAT);
    CGSize msgSize = [message sizeWithFont:font constrainedToSize:maxSize];
    
    CGFloat viewW = msgSize.width > ProgressW * 2? msgSize.width + (ORMargin * 2) : ProgressW * 2;
    CGFloat viewH = msgSize.height + ORMargin + ProgressW;
    
    self.contentView.frame = CGRectMake((ORScreenW - viewW) / 2 - ORMargin, (ORScreenH - viewH) / 2 - ORMargin, viewW + ORMargin * 2, viewH + ORMargin * 2);
    
    self.detailLabel.frame = CGRectMake(ORMargin, ORMargin * 1.5 + ProgressW, self.contentView.frame.size.width - ORMargin * 2, self.contentView.frame.size.height - (ORMargin * 2) - ProgressW);
    
    self.detailLabel.font = font;
    self.detailLabel.backgroundColor = [UIColor clearColor];
    self.detailLabel.text = message;
    self.bgView.frame = self.contentView.bounds;
    self.progressView.frame = CGRectMake((self.contentView.frame.size.width - ProgressW) / 2, ORMargin, ProgressW, ProgressW);
}

+ (void)showMessage:(NSString *)message
{
    [[self sharedHUD] showMessage:message];
}

+ (void)show
{
    [[self sharedHUD] showMessage:nil];
}

+ (void)hide
{
    [[self sharedHUD] invalidateTimer];
    [[self sharedHUD] removeFromSuperview];
}

- (void)showAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @(M_PI * 2);
    rotationAnimation.toValue = @(0);
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [self.progressView.layer addAnimation:rotationAnimation
                                   forKey:@"rotationAnimation"];
}

#pragma mark -- --
+ (void)showCountdownWith:(NSInteger)count failure:(void (^)())failureBlock
{
    [[self sharedHUD] showCountdownWith:count failure:failureBlock];
}

- (void)showCountdownWith:(NSInteger)count failure:(void (^)())failureBlock
{
    _count = count;
    _failureBlock = failureBlock;
    
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:ORInterval target:self selector:@selector(updateCount) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        [_timer fire];
        
        [self showHudInView:nil animated:YES];
    }
}

- (void)updateCount
{
    _count --;
    
    if (_count < 0) {
        if (_failureBlock) {
            _failureBlock();
        }
        
        [_timer invalidate];
        _timer = nil;
        [self removeFromSuperview];
    }else{
        self.detailLabel.font = CountFont;
        [self updateViewWithMessage:[NSString stringWithFormat:@"%ld", _count] withFont:CountFont];
    }
}

- (void)invalidateTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

+ (void)showCountdown:(void (^)())failureBlock;
{
    [self showCountdownWith:60 failure:failureBlock];
}

#pragma mark -- -- 
- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIImageView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIImageView alloc] initWithFrame:CGRectMake((self.contentView.frame.size.width - ProgressW) / 2, ORMargin, ProgressW, ProgressW)];
        [self.contentView addSubview:_progressView];
    }
    return _progressView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(ORMargin, ORMargin * 2 + ProgressW, self.contentView.frame.size.width - ORMargin * 2, self.contentView.frame.size.height - (ORMargin * 3) - ProgressW)];
        _detailLabel.font = ORFont;
        _detailLabel.numberOfLines = 0;
        _detailLabel.textColor = [UIColor whiteColor];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (UIImageView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_bgView];
    }
    return _bgView;
}


@end
