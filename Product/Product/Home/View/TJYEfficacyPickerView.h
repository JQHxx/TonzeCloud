//
//  TJYEfficacyPickerView.h
//  Product
//
//  Created by zhuqinlu on 2018/3/22.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJYEfficacyPickerView;

//回调  pickerView 回传类本身 用来做调用 销毁动作
//     choiceString  回传选择器 选择的单个条目字符串
typedef void(^TJYEfficacyPickerViewBlock)(TJYEfficacyPickerView *pickerView,NSString *choiceString,NSInteger targetId);

@interface TJYEfficacyPickerView : UIView

@property (nonatomic,copy)TJYEfficacyPickerViewBlock callBack;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
/// 选中功效
@property (nonatomic, copy) NSString *selectTextStr;
/// 功效描述
@property (nonatomic ,strong) NSArray *effectDescriptionArray;
/// 功效ID
@property (nonatomic ,strong) NSArray *effectIdArray;

@property (weak, nonatomic) UIPickerView *pickerView;
//------单条选择器
+(instancetype)efficacyPickerViewBlockWithTitle:(NSArray *)title andHeadTitle:(NSString *)headTitle Andcall:(TJYEfficacyPickerViewBlock)callBack;
//显示
-(void)show;
//销毁类
-(void)dismissPicker;

@end
