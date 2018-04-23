//
//  CityPickerView.h
//  Product
//
//  Created by zhuqinlu on 2017/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^sureButtonClick) (NSString *province ,NSString *city ,NSString *town);

@interface CityPickerView : UIView

@property (nonatomic, strong) NSString *province;           /** 省 */
@property (nonatomic, strong) NSString *city;               /** 市 */
@property (nonatomic, strong) NSString *town;               /** 县 */
/// 标题
@property (nonatomic ,copy)  NSString *titleStr;

@property (nonatomic, copy) sureButtonClick config;

@property (nonatomic, strong) UIPickerView *cityPickerView;/** 城市选择器 */

@property (nonatomic, strong) NSArray *provinceArr;        /** 省 数组 */
@property (nonatomic, strong) NSArray *cityArr;            /** 市 数组 */
@property (nonatomic, strong) NSArray *townArr;            /** 县城 数组 */
@property (nonatomic ,strong) NSArray *AllCityArr;
@property (nonatomic, strong) NSArray *AllTownArr ;
/// 地区数据
@property (nonatomic ,strong) NSArray *areaArray;

//省  市 县 变量
@property (nonatomic, strong) NSArray *allCityInfo;   /** 所有省市县信息 */
@property (strong, nonatomic, readwrite) NSArray <NSDictionary *> *allProvinceArray;

@end
