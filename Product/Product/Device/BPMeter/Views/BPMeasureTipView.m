//
//  BPMeasureTipView.m
//  Product
//
//  Created by mk-imac2 on 2017/7/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BPMeasureTipView.h"

@interface BPMeasureTipView()

@property (nonatomic,assign) BOOL isNoLonger;

@property (nonatomic,copy) MeasureTipBlock measureBlock;

@property (nonatomic,strong) UIButton * btnClock;

@property (nonatomic,strong) UIView * bgView;


@end

@implementation BPMeasureTipView

-(id)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initView];
    }
    return self;
}


/**
 *  实例化页面
 */
-(void)initView
{
    CGFloat viewWidth = 270.0f;
    CGFloat viewHeight = 400.0f;

    CGFloat viewTop = (SCREEN_HEIGHT - viewHeight) / 2.0f;
    CGFloat margin = 18.0f;
    
    self.btnClock = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnClock.frame = self.frame;
    self.btnClock.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.3f];
    [self.btnClock addTarget:self action:@selector(onBtnClock:) forControlEvents:UIControlEventTouchUpInside];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-viewWidth)/ 2, viewTop, viewWidth,viewHeight)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.layer.cornerRadius = 10.0;
    [self addSubview:self.bgView];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bgView.width, 40.0f)];
    lblTitle.font = [UIFont systemFontOfSize:18.0f];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"温馨提示";
    [self.bgView addSubview:lblTitle];
    
    UIImageView * imageShow = [[UIImageView alloc] initWithFrame:CGRectMake(lblTitle.left, lblTitle.bottom, self.bgView.width, 140.0f)];
    imageShow.image = [UIImage imageNamed:@"xyj_tips_bg.png"];
    imageShow.contentMode = UIViewContentModeScaleAspectFit;
    [self.bgView addSubview:imageShow];
    
    UILabel * lblContent = [[UILabel alloc] initWithFrame:CGRectMake(margin, imageShow.bottom + 15.0f, self.bgView.width - margin * 2, 110.0f)];
    lblContent.font = [UIFont systemFontOfSize:15.0f];
    lblContent.textColor = [UIColor colorWithHexString:@"#626262"];
    lblContent.numberOfLines = 0;
    lblContent.lineBreakMode = NSLineBreakByWordWrapping;
    lblContent.text = @"1、请将袖带套在离手臂肘关节2~3cm处。\n2、如图所示坐好，测量前请先静坐一小会。\n3、按下血压计的[开/关]键开始测量。";
    [self.bgView addSubview:lblContent];
    
    UIButton * btnTip = [UIButton buttonWithType:UIButtonTypeCustom];
    BOOL flag = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isNoLonger"] boolValue];
    if (flag) {
        self.isNoLonger = YES;
    }else{
        self.isNoLonger = NO;
    }
    btnTip.selected = flag?YES:NO;
    btnTip.frame = CGRectMake((self.bgView.width - 100.0f) / 2, lblContent.bottom + 10.0f, 110.0f, 30.0f);
    [btnTip setTitle:@"下次不再提醒" forState:UIControlStateNormal];
    btnTip.titleEdgeInsets = UIEdgeInsetsMake(0, 8.0f, 0, 0);
    btnTip.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [btnTip setTitleColor:[UIColor colorWithHexString:@"#626262"] forState:UIControlStateNormal];
    [btnTip setImage:[UIImage imageNamed:@"xyj_tips_ch_nor.png"] forState:UIControlStateNormal];
    [btnTip setImage:[UIImage imageNamed:@"xyj_tips_ch_sel.png"] forState:UIControlStateSelected];
    [btnTip addTarget:self action:@selector(onBtnTip:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:btnTip];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, btnTip.bottom + 10.0f, self.bgView.width, 0.5f)];
    line.backgroundColor = [UIColor colorWithHexString:@"#626262"];
    [self.bgView addSubview:line];
    
    UIButton * btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    btnConfirm.frame = CGRectMake(lblTitle.left, line.bottom, self.bgView.width, 40.0f);
    [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
    [btnConfirm setTitleColor:[UIColor colorWithHexString:@"#FF8314"] forState:UIControlStateNormal];
    [btnConfirm setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [btnConfirm addTarget:self action:@selector(onBtnConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:btnConfirm];
}

#pragma mark -
#pragma mark ==== onBtnAction ====
#pragma mark -

/**
 *  选择是否不再提示
 */
-(void)onBtnTip:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    if (btn.selected)
    {
        btn.selected = NO;
        self.isNoLonger = NO;
    }
    else
    {
        btn.selected = YES;
        self.isNoLonger = YES;
    }
}

/**
 *  确定
 */
-(void)onBtnConfirm:(id)sender
{
    if (self.measureBlock) {
        self.measureBlock(self.isNoLonger);
    }
    [self closeAction];
}

/**
 *  关闭
 */
-(void)onBtnClock:(id)sender
{
    [self closeAction];
}

#pragma mark -
#pragma mark ==== Action ====
#pragma mark -

-(void)closeAction
{
    [self.bgView removeFromSuperview];
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3f];
}

-(void)viewRemoveFromSuperview
{
    [self.btnClock removeFromSuperview];
    [self removeFromSuperview];
}

-(void)showInView:(UIView *)view withMeasureTipBlock:(MeasureTipBlock)block
{
    if (block) {
        self.measureBlock = block;
    }
    
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.bgView.layer addAnimation:animation forKey:@"BPMeasureTipView"];
    [view addSubview:self];
    
    [self addSubview:self.btnClock];
    [self sendSubviewToBack:self.btnClock];
}





@end
