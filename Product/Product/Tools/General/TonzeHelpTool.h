//
//  TonzeHelpTool.h
//  Product
//
//  Created by vision on 17/1/3.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJYUserModel.h"
#import "TJYSearchFoodVC.h"

typedef enum : NSUInteger {
    WebViewTypeArticle,
    WebViewTypeUserAgreenment,
    WebViewTypeOther,
} WebViewType;

@interface TonzeHelpTool : NSObject

singleton_interface(TonzeHelpTool);

@property (nonatomic,strong)TJYUserModel *user;

@property (nonatomic,copy)NSString *teaType; //(花草茶、水果茶)
@property (nonatomic,copy)NSString *prefrenceType; //(降压粥、降压汤）

@property (nonatomic,assign)SearchType  searchType;
@property (nonatomic,assign)WebViewType viewType;   //是否用户协议
@property (nonatomic,assign)NSInteger   article_id;
@property (nonatomic,assign)BOOL        isAddSport;
@property (nonatomic, copy )NSString    *messageTargetId;

/**
 *  计算缓存大小
 *
 *  @return 缓存大小
 */
-(double)getCachFileSize;

/**
 *  计算每日摄入能量值
 *
 *  @param height         身高
 *  @param weight         体重
 *  @param laborIntensity 劳动强度
 */
-(void)calculateDailyEnergyWithHeight:(NSInteger)height weight:(double)weight labor:(NSString *)laborIntensity;


/**
 *  根据出生日期计算年龄
 *
 *  @param birth 出生日期
 *
 *  @return 年龄
 */
- (NSInteger)getPersonAgeWithBirthdayString:(NSString *)birth;


@end
