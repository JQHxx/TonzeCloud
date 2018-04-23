
//
//  CityPickerView.m
//  Product
//
//  Created by zhuqinlu on 2017/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "CityPickerView.h"

static CGFloat bgViewHeith = 240;
static CGFloat cityPickViewHeigh = 200;
static CGFloat toolsViewHeith = 40;
static CGFloat animationTime = 0.25;

@interface CityPickerView()<UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSString  *_cityNumStr;
}
@property (nonatomic, strong) UIButton *sureButton;        /** 确认按钮 */
@property (nonatomic, strong) UIButton *canselButton;      /** 取消按钮 */
@property (nonatomic, strong) UIView *toolsView;           /** 自定义标签栏 */
@property (nonatomic, strong) UIView *bgView;              /** 背景view */
@property (nonatomic ,strong) UILabel *titleLab;           /** 标题  **/


@end
@implementation CityPickerView
- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
        [self initBaseData];
    }
    return self;
}

- (void)initSubViews{
    
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.toolsView];
    [self.toolsView addSubview:self.canselButton];
    [self.toolsView addSubview:self.sureButton];
    [self.toolsView addSubview:self.titleLab];
    
    [self.bgView addSubview:self.cityPickerView];
    
    [self showPickView];
}

- (void)initBaseData{
    

}
#pragma event menthods
- (void)canselButtonClick{
    [self hidePickView];
    if (self.config) {
        //        self.config(self.province,self.city,self.town);
    }
}

- (void)sureButtonClick{
    [self hidePickView];
    if (self.config) {
        self.config(self.province,self.city,self.town);
    }
}

#pragma mark private methods
- (void)showPickView{
    [UIView animateWithDuration:animationTime animations:^{
        self.bgView.frame = CGRectMake(0, self.frame.size.height - bgViewHeith, self.frame.size.width, bgViewHeith);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hidePickView{
    
    [UIView animateWithDuration:animationTime animations:^{
        self.bgView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, bgViewHeith);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (NSArray *)getNameforProvince:(NSInteger)row{
    self.allProvinceArray = [self.allCityInfo[row] objectForKey:@"City"];
    NSMutableArray *tempMutArray = [NSMutableArray array];
    for (int i = 0; i < self.allProvinceArray.count; i++) {
        NSDictionary *dic =self.allProvinceArray[i];
        [tempMutArray addObject:dic];
    }
    return tempMutArray;
}

#pragma mark - pickerViewDatasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return self.provinceArr.count;
    }
    else if(component == 1){
        return  self.cityArr.count;
    }
    else if(component == 2){
        return self.townArr.count;
    }
    return 0;
}

#pragma mark - pickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/3.0, 30)];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    if (component == 0) {
        NSString *provinceString = self.provinceArr[row];
        NSRange rang = [provinceString rangeOfString:@":"];
        NSString *provinceStr = [provinceString substringToIndex:rang.location];
        label.text = provinceStr;
    }else if (component == 1){
        NSString *cityString = self.cityArr[row];
        NSRange rang = [cityString rangeOfString:@":"];
        NSString *cityStr = [cityString substringToIndex:rang.location];
        label.text = cityStr;
    }else if (component == 2){
        NSString *townString = self.townArr[row];
        NSRange rang = [townString rangeOfString:@":"];
        NSString *townStr = [townString substringToIndex:rang.location];
        label.text =  townStr;
    }
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {//选择省
        self.cityArr = self.AllCityArr[row];
        _cityNumStr = self.cityArr[0];
        NSInteger index ;
        NSArray  *artArray = [_cityNumStr componentsSeparatedByString:@":"];
        if (artArray.count == 2) {
            index = [artArray[1] integerValue];
            self.townArr = [NSArray array];
            self.town = @"";
        }else if(artArray.count == 3){
            index = [artArray[2] integerValue];
            self.townArr = self.AllTownArr[index];
            self.town = self.townArr[0];
        }
        [self.cityPickerView reloadComponent:1];
        [self.cityPickerView selectRow:0 inComponent:1 animated:YES];
        [self.cityPickerView reloadComponent:2];
        [self.cityPickerView selectRow:0 inComponent:2 animated:YES];
        self.province   = self.provinceArr[row];
        self.city       = self.cityArr[0];
    }else if (component == 1){//选择城市
        self.city = self.cityArr[row];
        _cityNumStr = self.cityArr[row];
        NSInteger index ;
        NSArray  *artArray = [_cityNumStr componentsSeparatedByString:@":"];
        if (artArray.count == 2) {
            index = [artArray[1] integerValue];
            self.townArr = [NSArray array];
            self.town = @"";
        }else if(artArray.count == 3){
            index = [artArray[2] integerValue];
            self.townArr = self.AllTownArr[index];
            self.town = self.townArr[0];
        }
        [self.cityPickerView reloadComponent:2];
        [self.cityPickerView selectRow:0 inComponent:2 animated:YES];
        
    }else if (component == 2){
        if (self.townArr.count > 0) {
            self.town = self.townArr[row];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if ([touches.anyObject.view isKindOfClass:[self class]]) {
        [self hidePickView];
    }
}

#pragma mark - lazy

- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, bgViewHeith)];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (UIPickerView *)cityPickerView{
    if (!_cityPickerView) {
        _cityPickerView = ({
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolsViewHeith, self.frame.size.width, cityPickViewHeigh)];
            pickerView.backgroundColor = [UIColor whiteColor];
            //            [pickerView setShowsSelectionIndicator:YES];
            pickerView.delegate = self;
            pickerView.dataSource = self;
            pickerView;
        });
    }
    return _cityPickerView;
}

- (UIView *)toolsView{
    
    if (!_toolsView) {
        _toolsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, toolsViewHeith)];
        _toolsView.layer.borderWidth = 0.5;
        _toolsView.layer.borderColor = kLineColor.CGColor;
    }
    return _toolsView;
}
- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 10, kScreenWidth - 100, 20)];
        _titleLab.textColor = kSystemColor;
        _titleLab.font = kFontSize(14);
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}
- (UIButton *)canselButton{
    if (!_canselButton) {
        _canselButton = ({
            UIButton *canselButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 50, toolsViewHeith)];
            [canselButton setTitle:@"取消" forState:UIControlStateNormal];
            [canselButton setTitleColor:[UIColor blackColor]  forState:UIControlStateNormal];
            [canselButton addTarget:self action:@selector(canselButtonClick) forControlEvents:UIControlEventTouchUpInside];
            canselButton;
        });
    }
    return _canselButton;
}

- (UIButton *)sureButton{
    if (!_sureButton) {
        _sureButton = ({
            UIButton *sureButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 20 - 50, 0, 50, toolsViewHeith)];
            [sureButton setTitle:@"确定" forState:UIControlStateNormal];
            [sureButton setTitleColor:kSystemColor forState:UIControlStateNormal];
            [sureButton addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
            sureButton;
        });
    }
    return _sureButton;
}
#pragma mark ====== Setter =======

- (void)setAreaArray:(NSArray *)areaArray{
    if (areaArray.count > 0) {
        self.provinceArr = areaArray[0];
        self.AllCityArr = areaArray[1];
        self.AllTownArr = areaArray[2];
        self.cityArr = self.AllCityArr[0];
        self.townArr = self.AllTownArr[0];
        self.province = self.provinceArr[0];
        self.city = self.cityArr[0];
        self.town = self.townArr[0];
        [self.cityPickerView reloadAllComponents];
    }
}

@end
