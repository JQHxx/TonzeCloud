    //
//  TJYMenuFilterView.m
//  Product
//
//  Created by mk-imac2 on 2017/9/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYMenuFilterView.h"
#import "TTGTextTagCollectionView.h"

@interface FilterTitle : UIView

/**
 *  标题
 */
@property (nonatomic,strong) UILabel * lblTitle;

/**
 *  选择内容
 */
@property (nonatomic,strong) UILabel * lblSelect;

@end

@implementation FilterTitle

-(id)init
{
    self = [super init];
    if (self) {
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

-(void)initView
{
    CGFloat viewWidth = self.frame.size.width;
    
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 12.0f, 80.0f, 20.0f)];
    self.lblTitle.font = [UIFont systemFontOfSize:16.0f];
    self.lblTitle.textColor = UIColorHex(0x313131);
    [self addSubview:self.lblTitle];

    self.lblSelect = [[UILabel alloc] initWithFrame:CGRectMake(self.lblTitle.right, self.lblTitle.top, viewWidth - self.lblTitle.width - 30.0f, self.lblTitle.height)];
    self.lblSelect.font = [UIFont systemFontOfSize:14.0f];
    self.lblSelect.textColor = UIColorHex(0xff6600);
    self.lblSelect.textAlignment = NSTextAlignmentRight;
    self.lblSelect.numberOfLines = 1;
    [self addSubview:self.lblSelect];
    
}

@end


@interface TJYMenuFilterView()<TTGTextTagCollectionViewDelegate>

@property (nonatomic,strong) UIButton * btnClock;

@property (nonatomic,strong) UIView * bgView;

@property (nonatomic,strong) UIView * line;

@property (nonatomic,strong) UIView * bgColor;

@property (nonatomic,strong) UIScrollView * scrollView;


/**
 *  选择的菜谱
 */
@property (nonatomic,strong) NSMutableArray * arraySelect;


/**
 *  菜谱
 */
@property (nonatomic,strong) NSMutableArray * arrayMenu;
@property (nonatomic,strong) FilterTitle * viewMenu;
@property (nonatomic,strong) TTGTextTagCollectionView * viewMenuContent;


/**
 *  设备
 */
@property (nonatomic,strong) NSMutableArray * arrayDevice;
@property (nonatomic,strong) FilterTitle * viewDevice;
@property (nonatomic,strong) TTGTextTagCollectionView * viewDeviceContent;

/**
 * 功效
 */
@property (nonatomic,strong) NSMutableArray * arrayEffect;
@property (nonatomic,strong) FilterTitle * viewEffect;
@property (nonatomic,strong) TTGTextTagCollectionView * viewEffectContent;

@end

@implementation TJYMenuFilterView


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
    CGFloat viewWidth = SCREEN_WIDTH * 0.8;
    CGFloat viewHeight = SCREEN_HEIGHT;
    
    CGFloat viewTop = 0;
    
    self.btnClock = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnClock.frame = self.frame;
    self.btnClock.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.3f];
    [self.btnClock addTarget:self action:@selector(onBtnClock:) forControlEvents:UIControlEventTouchUpInside];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-viewWidth, viewTop, viewWidth,viewHeight)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 20, viewWidth, viewHeight - 45)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:self.scrollView];
    
    // 菜谱
    self.viewMenu = [[FilterTitle alloc] initWithFrame:CGRectMake(0.0f, 0.0f,viewWidth, 44.0f)];
    self.viewMenu.lblTitle.text = @"菜谱类型";
    self.viewMenu.lblSelect.text = @"全部";
    [self.scrollView addSubview:self.viewMenu];
    [self.scrollView addSubview:self.viewMenuContent];
    
    // 设备
    self.viewDevice = [[FilterTitle alloc] initWithFrame:CGRectMake(0.0f, self.viewMenuContent.bottom,viewWidth, 44.0f)];
    self.viewDevice.lblTitle.text = @"适用设备";
    self.viewDevice.lblSelect.text = @"全部";
    self.viewDevice.hidden = YES;
    [self.scrollView addSubview:self.viewDevice];
    [self.scrollView addSubview:self.viewDeviceContent];
    
    // 功效
    self.viewEffect = [[FilterTitle alloc] initWithFrame:CGRectMake(0.0f, self.viewDeviceContent.bottom,viewWidth, 44.0f)];
    self.viewEffect.lblTitle.text = @"菜谱功效";
    self.viewEffect.lblSelect.text = @"全部";
    [self.scrollView addSubview:self.viewEffect];
    [self.scrollView addSubview:self.viewEffectContent];
    
    [self.scrollView addSubview:self.line];
    [self.scrollView addSubview:self.bgColor];
    
    UIView * btnLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, viewHeight - 45.0f, viewWidth, 1)];
    btnLine.backgroundColor = UIColorHex(0xeeeeee);
    [self.bgView addSubview:btnLine];

    UIButton * btnReset = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReset.frame = CGRectMake(0.0f, viewHeight - 44.0f, viewWidth/2, 44);
    btnReset.backgroundColor = [UIColor whiteColor];
    [btnReset setTitleColor:UIColorHex(0xff6600) forState:UIControlStateNormal];
    [btnReset setTitle:@"重置" forState:UIControlStateNormal];
    [btnReset addTarget:self action:@selector(onBtnReset:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:btnReset];
    
    UIButton * btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSure.frame = CGRectMake(btnReset.right, btnReset.top, btnReset.width, btnReset.height);
    btnSure.backgroundColor = UIColorHex(0xff9d38);
    [btnSure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSure setTitle:@"确定" forState:UIControlStateNormal];
    [btnSure addTarget:self action:@selector(onBtnSure:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:btnSure];
    
    [self.viewMenuContent addObjTags:self.arrayMenu];
    [self.viewMenuContent reload];
    
    [self.viewEffectContent addObjTags:self.arrayEffect];
    [self.viewEffectContent reload];
    
}

/**
 *  菜谱
 */
-(TTGTextTagCollectionView *)viewMenuContent
{
    if (!_viewMenuContent)
    {
        _viewMenuContent = [[TTGTextTagCollectionView alloc] init];
        [_viewMenuContent setFrame:CGRectMake(15.0f,self.viewMenu.bottom,self.viewMenu.width - 30.0f,50)];
        [_viewMenuContent setTagTextFont:[UIFont systemFontOfSize:14.0f]];
        _viewMenuContent.radioTag = YES;
        [_viewMenuContent setVerticalSpacing:15];
        [_viewMenuContent setHorizontalSpacing:20];
        _viewMenuContent.tagTextColor =  UIColorHex(0x666666);
        _viewMenuContent.tagSelectedTextColor =  UIColorHex(0xff6600);
        _viewMenuContent.tagBackgroundColor =  UIColorHex(0xefeff4);
        _viewMenuContent.tagSelectedBackgroundColor =  UIColorHex(0xfff2dc);
        _viewMenuContent.tagBorderWidth = 0;
        _viewMenuContent.extraSpace = CGSizeMake(20.0f, 16.0f);
        [_viewMenuContent setDelegate:self];
    }
    
    return _viewMenuContent;
}

/**
 *  设备
 */
-(TTGTextTagCollectionView *)viewDeviceContent
{
    if (!_viewDeviceContent)
    {
        _viewDeviceContent = [[TTGTextTagCollectionView alloc] init];
        [_viewDeviceContent setFrame:CGRectMake(15.0f,self.viewDevice.bottom,self.viewDevice.width - 30.0f,50)];
        [_viewDeviceContent setTagTextFont:[UIFont systemFontOfSize:14.0f]];
        _viewDeviceContent.radioTag = YES;
        [_viewDeviceContent setVerticalSpacing:15];
        [_viewDeviceContent setHorizontalSpacing:20];
        _viewDeviceContent.tagTextColor =  UIColorHex(0x666666);
        _viewDeviceContent.tagSelectedTextColor =  UIColorHex(0xff6600);
        _viewDeviceContent.tagBackgroundColor =  UIColorHex(0xefeff4);
        _viewDeviceContent.tagSelectedBackgroundColor =  UIColorHex(0xfff2dc);
        _viewDeviceContent.tagBorderWidth = 0;
        _viewDeviceContent.extraSpace = CGSizeMake(20.0f, 16.0f);
        _viewDeviceContent.hidden = YES;
        [_viewDeviceContent setDelegate:self];
    }
    
    return _viewDeviceContent;
}

/**
 *  功效
 */
-(TTGTextTagCollectionView *)viewEffectContent
{
    if (!_viewEffectContent)
    {
        _viewEffectContent = [[TTGTextTagCollectionView alloc] init];
        [_viewEffectContent setFrame:CGRectMake(15.0f,self.viewEffect.bottom,self.viewEffect.width - 30.0f,50)];
        [_viewEffectContent setTagTextFont:[UIFont systemFontOfSize:14.0f]];
        [_viewEffectContent setVerticalSpacing:15];
        [_viewEffectContent setHorizontalSpacing:20];
        _viewEffectContent.tagTextColor =  UIColorHex(0x666666);
        _viewEffectContent.tagSelectedTextColor =  UIColorHex(0xff6600);
        _viewEffectContent.tagBackgroundColor =  UIColorHex(0xefeff4);
        _viewEffectContent.tagSelectedBackgroundColor =  UIColorHex(0xfff2dc);
        _viewEffectContent.tagBorderWidth = 0;
        _viewEffectContent.extraSpace = CGSizeMake(20.0f, 16.0f);
        [_viewEffectContent setDelegate:self];
    }
    
    return _viewEffectContent;
}

-(UIView *)line
{
    if (_line == nil) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = UIColorHex(0xeeeeee);

    }
    return _line;
}

-(UIView *)bgColor
{
    if(_bgColor == nil){
        _bgColor = [[UIView alloc] init];
        _bgColor.backgroundColor = UIColorHex(0xf5f9fa);
    }
    return _bgColor;
}

-(NSMutableArray *)arrayMenu
{
    if (_arrayMenu == nil) {
        _arrayMenu = [[NSMutableArray alloc] initWithObjects:@"云菜谱",@"普通菜谱",nil];
    }
    
    return _arrayMenu;
}

-(NSMutableArray *)arrayDevice
{
    if (_arrayDevice == nil) {
        _arrayDevice = [[NSMutableArray alloc] init];
    }
    
    return _arrayDevice;
}

-(NSMutableArray *)arrayEffect
{
    if (_arrayEffect == nil) {
        _arrayEffect = [[NSMutableArray alloc] init];
    }
    
    return _arrayEffect;
}

-(NSMutableArray *)arraySelect
{
    if (_arraySelect == nil) {
        _arraySelect = [[NSMutableArray alloc] init];
    }
    
    return _arraySelect;
}

-(void)setMenuIndex:(NSInteger)menuIndex
{
    _menuIndex = menuIndex;
    if (menuIndex == -1) {
        return;
    }
    self.viewMenu.lblSelect.text = self.arrayMenu[menuIndex];
    [self.viewMenuContent setTagAtIndex:menuIndex selected:YES];
}

-(void)setDeviceIndex:(NSInteger)deviceIndex
{
    _deviceIndex = deviceIndex;
    if (deviceIndex == -1) {
        return;
    }
    self.viewDevice.lblSelect.text = self.arrayDevice[deviceIndex];
    [self.viewDeviceContent setTagAtIndex:deviceIndex selected:YES];
}

-(void)setArrayEffectIndex:(NSMutableArray *)arrayEffectIndex
{
    _arrayEffectIndex = [arrayEffectIndex mutableCopy];
    for (int i = 0; i < arrayEffectIndex.count; i ++) {
        NSString * index = arrayEffectIndex[i];
        [self.arraySelect addObject:self.arrayEffect[[index integerValue]]];
        
        [self.viewEffectContent setTagAtIndex:[index integerValue] selected:YES];
    }
    
    NSString * content = @"";
    for (NSString * obj in self.arraySelect) {
        content = kIsEmptyString(content)? obj : [content stringByAppendingFormat:@",%@",obj];
    }
    self.viewEffect.lblSelect.text = !kIsEmptyString(content) ? content : @"全部";

}

#pragma mark -
#pragma mark ==== TTGTextTagCollectionViewDelegate ====
#pragma mark -

-(void)textTagCollectionView:(TTGTextTagCollectionView *)textTagCollectionView didTapTag:(NSString *)tagText atIndex:(NSUInteger)index selected:(BOOL)selected
{
    NSLog(@"text %@",tagText);
    
    if ([textTagCollectionView isEqual:self.viewMenuContent])
    {
        if (selected) {
            _menuIndex = index;
            self.viewMenu.lblSelect.text = tagText;
            if ([tagText isEqualToString:@"云菜谱"]) {
                self.viewDevice.hidden = NO;
                self.viewDeviceContent.hidden = NO;
                self.bgColor.frame = CGRectMake(0.0f, self.viewDeviceContent.bottom + 15, self.bgView.width, 30);
                self.viewEffect.frame = CGRectMake(self.viewEffect.left, self.bgColor.bottom, self.viewEffect.width, self.viewEffect.height);
                self.viewEffectContent.frame = CGRectMake(self.viewEffectContent.left, self.viewEffect.bottom, self.viewEffectContent.width, self.viewEffectContent.height);
                self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.viewEffectContent.bottom + 50);
            } else {
                self.viewDevice.hidden = YES;
                self.viewDeviceContent.hidden = YES;
                self.bgColor.frame = CGRectMake(0.0f, self.viewMenuContent.bottom + 15, self.bgView.width, 30);
                self.viewEffect.frame = CGRectMake(self.viewEffect.left, self.bgColor.bottom, self.viewEffect.width, self.viewEffect.height);
                self.viewEffectContent.frame = CGRectMake(self.viewEffectContent.left, self.viewEffect.bottom, self.viewEffectContent.width, self.viewEffectContent.height);
                self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.viewEffectContent.bottom + 50);
            }
        }else{
            _menuIndex = -1;
            self.viewMenu.lblSelect.text = @"全部";
            self.viewDevice.hidden = YES;
            self.viewDeviceContent.hidden = YES;
            self.bgColor.frame = CGRectMake(0.0f, self.viewMenuContent.bottom + 15, self.bgView.width, 30);
            self.viewEffect.frame = CGRectMake(self.viewEffect.left, self.bgColor.bottom, self.viewEffect.width, self.viewEffect.height);
            self.viewEffectContent.frame = CGRectMake(self.viewEffectContent.left, self.viewEffect.bottom, self.viewEffectContent.width, self.viewEffectContent.height);
            self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.viewEffectContent.bottom + 50);
        }
    }
    else if ([textTagCollectionView isEqual:self.viewDeviceContent])
    {
        if (selected) {
            _deviceIndex = index;
            self.viewDevice.lblSelect.text = tagText;
        }else{
            _deviceIndex = -1;
            self.viewDevice.lblSelect.text = @"全部";
        }
    }
    else if ([textTagCollectionView isEqual:self.viewEffectContent])
    {
        NSString * content = @"";

        if (selected)
        {
            [self.arraySelect addObject:tagText];
            [self.arrayEffectIndex addObject:[NSString stringWithFormat:@"%ld",(long)index]];
        }else{
            if ([self.arraySelect containsObject:tagText]) {
                [self.arraySelect removeObject:tagText];
                [self.arrayEffectIndex removeObject:[NSString stringWithFormat:@"%ld",(long)index]];
            }
        }
        if ([self.arraySelect count] != 0) {
            for (NSString * obj in self.arraySelect) {
                content = kIsEmptyString(content)? obj : [content stringByAppendingFormat:@",%@",obj];
            }
        }else{
            content = @"全部";
        }
        
        self.viewEffect.lblSelect.text = content;
    }
}

-(void)textTagCollectionView:(TTGTextTagCollectionView *)textTagCollectionView updateContentHeight:(CGFloat)newContentHeight
{
    if ([textTagCollectionView isEqual:self.viewMenuContent])
    {
        self.viewMenuContent.height = newContentHeight;
        self.line.frame = CGRectMake(0.0f, self.viewMenuContent.bottom + 15, self.bgView.width, 1.0f);
        self.viewDevice.frame = CGRectMake(self.viewDevice.left, self.line.bottom, self.viewDevice.width, self.viewDevice.height);
        self.viewDeviceContent.frame = CGRectMake(self.viewDeviceContent.left, self.viewDevice.bottom, self.viewDeviceContent.width, self.viewDeviceContent.height);
    }
    else if ([textTagCollectionView isEqual:self.viewDeviceContent])
    {
        self.viewDevice.hidden = _menuIndex==0?NO:YES;
        self.viewDeviceContent.hidden = _menuIndex==0?NO:YES;
        self.viewDeviceContent.height =  newContentHeight;
    }
    else if ([textTagCollectionView isEqual:self.viewEffectContent])
    {
        if (_menuIndex==0) {
            self.bgColor.frame = CGRectMake(0.0f, self.viewDeviceContent.bottom + 15, self.bgView.width, 30);
            self.viewEffect.frame = CGRectMake(self.viewEffect.left, self.bgColor.bottom, self.viewEffect.width, self.viewEffect.height);
            self.viewEffectContent.frame = CGRectMake(self.viewEffectContent.left, self.viewEffect.bottom, self.viewEffectContent.width, self.viewEffectContent.height);
        } else {
            self.bgColor.frame = CGRectMake(0.0f, self.viewMenuContent.bottom + 15, self.bgView.width, 30);
            self.viewEffect.frame = CGRectMake(self.viewEffect.left, self.bgColor.bottom, self.viewEffect.width, self.viewEffect.height);
            self.viewEffectContent.frame = CGRectMake(self.viewEffectContent.left, self.viewEffect.bottom, self.viewEffectContent.width, self.viewEffectContent.height);
        }
        self.viewEffectContent.height = newContentHeight;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.viewEffectContent.bottom + 50);
    }
}

#pragma mark -
#pragma mark ==== onBtnAction ====
#pragma mark -


/**
 *  关闭
 */
-(void)onBtnClock:(id)sender
{
    [self closeAction];
}

/**
 *  重置
 */
-(void)onBtnReset:(id)sender
{
    _menuIndex = -1;
    self.viewMenu.lblSelect.text = @"全部";
    [self.viewMenuContent resetAllTagStyle];
    
    _deviceIndex = -1;
    self.viewDevice.lblSelect.text = @"全部";
    [self.viewDeviceContent resetAllTagStyle];
    
    [_arrayEffectIndex removeAllObjects];
    [_arraySelect removeAllObjects];
    self.viewEffect.lblSelect.text = @"全部";
    [self.viewEffectContent resetAllTagStyle];
}

/**
 *  确定
 */
-(void)onBtnSure:(id)sender
{
    if (self.fillerBlock) {
        self.fillerBlock(self.menuIndex,self.deviceIndex,self.arrayEffectIndex);
    }
    [self closeAction];
}

#pragma mark -
#pragma mark ==== Action ====
#pragma mark -

-(void)closeAction
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromLeft;
    [self.bgView setAlpha:0.0f];
    [self.bgView.layer addAnimation:animation forKey:@"MenuFilterView"];
    
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3f];
}

-(void)viewRemoveFromSuperview
{
    [self.btnClock removeFromSuperview];
    [self.bgView removeFromSuperview];
    [self removeFromSuperview];
}

/**
 *  显示页面
 */
-(void)showMenuFilterView:(UIView *)view withDeviceArray:(NSMutableArray *)arrayDevice withEffectArray:(NSMutableArray *)arrayEffect
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromRight;
    [self setAlpha:1.0f];
    [self.bgView.layer addAnimation:animation forKey:@"MenuFilterView"];
    [view addSubview:self];
    
    [self addSubview:self.btnClock];
    [self sendSubviewToBack:self.btnClock];
    
    self.arrayDevice = arrayDevice;
    [self.viewDeviceContent addObjTags:self.arrayDevice];
    [self.viewDeviceContent reload];
    
    self.arrayEffect = arrayEffect;
    [self.viewEffectContent addObjTags:self.arrayEffect];
    [self.viewEffectContent reload];
}

@end
