//
//  SceneTimeIntervalPickerView.h
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddTimePickerViewDelegate

-(void)didSelectedPickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component RowText:(NSString *)text;

@end

@interface SceneTimeIntervalPickerView : UIPickerView<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, weak) id fzdelegate;

@property (nonatomic, strong) NSArray *proTitleList;

-(void)remove;
-(void)show:(UIView *)view;


@end
