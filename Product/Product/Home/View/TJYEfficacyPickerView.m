//
//  TJYEfficacyPickerView.m
//  Product
//
//  Created by zhuqinlu on 2018/3/22.
//  Copyright © 2018年 TianJi. All rights reserved.
//
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size

#import "TJYEfficacyPickerView.h"

@interface TJYEfficacyPickerView ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak,nonatomic)UIView *bgView;    //屏幕下方看不到的view
@property (weak,nonatomic)UILabel *titleLabel; //中间显示的标题lab

@property (weak,nonatomic)UIButton *cancelButton;
@property (weak,nonatomic)UIButton *doneButton;
@property (strong,nonatomic)NSArray *dataArray;   // 用来记录传递过来的数组数据
@property (strong,nonatomic)NSString *headTitle;  //传递过来的标题头字符串
@property (strong,nonatomic)NSString *backString; //回调的字符串
@property (nonatomic, assign) NSInteger  targetId;
@property (nonatomic ,strong) UILabel *descriptionLab;  // 功效描述
@property (nonatomic ,strong) NSArray *descriptionArray;
@property (nonatomic ,strong) NSArray *targetIdArray;   // 目标id
/// 选中功效
@property (nonatomic, copy) NSString *selectEfficacyStr;

@end

@implementation TJYEfficacyPickerView

+(instancetype)efficacyPickerViewBlockWithTitle:(NSArray *)title andHeadTitle:(NSString *)headTitle Andcall:(TJYEfficacyPickerViewBlock)callBack
{
    TJYEfficacyPickerView *pickerView = [[TJYEfficacyPickerView alloc]initWithFrame:[UIScreen mainScreen].bounds  andTitle:title andHeadTitle:headTitle];
    pickerView.callBack = callBack;
    return pickerView;
}

- (instancetype)initWithFrame:(CGRect)frame andTitle:(NSArray*)title andHeadTitle:(NSString *)headTitle
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataArray = title;
        _headTitle = headTitle;
        _backString = self.dataArray[0];
        [self setupUI];
    }
    return self;
}

- (void)tap
{
    [self dismissPicker];
}
-(void)setupUI
{
    //首先创建一个位于屏幕下方看不到的view
    UIView* bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.45];
    bgView.alpha = 0.0f;
    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [bgView addGestureRecognizer:g];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:bgView];
    self.bgView = bgView;
    
    //  标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width/2-75, 10, 150, 20)];
    titleLabel.font = [UIFont systemFontOfSize:16];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:_headTitle];
    [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    //取消按钮
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(2, 0, kScreenWidth*0.2, 40);
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"取消" attributes:
                                      @{ NSForegroundColorAttributeName: [UIColor grayColor],
                                         NSFontAttributeName :           [UIFont systemFontOfSize:14],
                                         NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone) }];
    [cancelButton setAttributedTitle:attrString forState:UIControlStateNormal];
    cancelButton.adjustsImageWhenHighlighted = NO;
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    self.cancelButton = cancelButton;
    
    //完成按钮
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(kScreenWidth-kScreenWidth*0.2-2, 0, kScreenWidth*0.2, 40);
    NSAttributedString *attrString2 = [[NSAttributedString alloc] initWithString:@"确认" attributes:
                                       @{ NSForegroundColorAttributeName: kSystemColor,
                                          NSFontAttributeName :           [UIFont systemFontOfSize:14],
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone) }];
    [doneButton setAttributedTitle:attrString2 forState:UIControlStateNormal];
    doneButton.adjustsImageWhenHighlighted = NO;
    doneButton.backgroundColor = [UIColor clearColor];
    [doneButton addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:doneButton];
    self.doneButton = doneButton;
    
    CALayer *lens = [[CALayer alloc]init];
    lens.frame = CGRectMake(0, 40,kScreenWidth, 1);
    lens.backgroundColor = UIColorHex(0xe5e5e5).CGColor;
    [self.layer addSublayer:lens];
    
    //选择器
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(5,40, SCREEN_SIZE.width-10, 180)];
    [pickerView setShowsSelectionIndicator:YES];
    [pickerView setDelegate:self];
    [pickerView setDataSource:self];
    [self addSubview:pickerView];
    self.pickerView = pickerView;
    self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // 描述文字
    _descriptionLab = [[UILabel alloc]initWithFrame:CGRectMake(0, pickerView.bottom, kScreenWidth, 20)];
    _descriptionLab.font = kFontSize(15);
    _descriptionLab.textColor = kSystemColor;
    _descriptionLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_descriptionLab];
    
    //self
    self.backgroundColor = [UIColor whiteColor];
    [self setFrame:CGRectMake(0, SCREEN_SIZE.height-300, SCREEN_SIZE.width , 300)];
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    [self setFrame: CGRectMake(0, SCREEN_SIZE.height,SCREEN_SIZE.width , 250)];
}

- (void)clicked:(UIButton *)sender
{
    if ([sender isEqual:self.cancelButton]) {
        [self dismissPicker];
    }else{
        if (self.callBack) {
            self.callBack(self,_backString,_targetId);
        }
    }
}

#pragma mark - 该方法的返回值决定该控件包含多少列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

#pragma mark - 该方法的返回值决定该控件指定列包含多少个列表项
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.dataArray.count;
}

#pragma mark - 该方法返回的NSString将作为UIPickerView中指定列和列表项的标题文本
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    return self.dataArray[row];
//}
#pragma mark - 当用户选中UIPickerViewDataSource中指定列和列表项时激发该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel *label;
    label=(UILabel *)[pickerView viewForRow:row forComponent:component];
    [label setTextColor:kSystemColor];
    
    _backString = self.dataArray[row];
    _descriptionLab.text = self.descriptionArray[row];
    _targetId = [self.targetIdArray[row] integerValue];
    label.text = self.dataArray[row];
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* lab = [[UILabel alloc] init];
    lab.textColor = self.textColor;
    lab.font = kFontSize(18);
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = self.dataArray[row];
    
    
    //  设置横线的颜色，实现显示或者隐藏
    ((UILabel *)[_pickerView.subviews objectAtIndex:1]).backgroundColor = UIColorHex(0xe5e5e5);
    
    ((UILabel *)[_pickerView.subviews objectAtIndex:2]).backgroundColor = UIColorHex(0xe5e5e5);
    
    return lab;
}

- (UIColor *)textColor
{
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

- (void)show
{
    [UIView animateWithDuration:0.8f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews animations:^{
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
        self.bgView.alpha = 1.0;
        
        self.frame = CGRectMake(0, SCREEN_SIZE.height-250, SCREEN_SIZE.width, 250);
    } completion:NULL];
}

- (void)dismissPicker
{
    [UIView animateWithDuration:0.8f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews animations:^{
        self.bgView.alpha = 0.0;
        self.frame = CGRectMake(0, SCREEN_SIZE.height,SCREEN_SIZE.width , 250);
        
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
        [self removeFromSuperview];
        
    }];
}
#pragma mark ====== Setter =======

- (void)setEffectDescriptionArray:(NSArray *)effectDescriptionArray{
    
    self.descriptionArray = effectDescriptionArray;
    self.descriptionLab.text = self.descriptionArray[0];
}

- (void)setEffectIdArray:(NSArray *)effectIdArray{
    
    _targetId = [effectIdArray[0]integerValue];
    self.targetIdArray = effectIdArray;
}
- (void)setSelectTextStr:(NSString *)selectTextStr{
    
    self.selectEfficacyStr = selectTextStr;
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        if ([self.dataArray[i] isEqualToString: self.selectEfficacyStr]) {
            [self.pickerView selectRow:i inComponent:0 animated:YES];
        }
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
