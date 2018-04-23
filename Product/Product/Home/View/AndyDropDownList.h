//
//  AndyDropDownList.h
//  Product
//
//  Created by zhuqinlu on 2017/4/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownListMenuDelegate <NSObject>

/**
 *  代理
 */
-(void)dropDownListParame:(NSString *)aStr;

-(void)listIndex:(NSInteger)index;

@end

@interface AndyDropDownList : UIView

/**
 *  下拉列表
 *  @param array       数据源
 *  @param listFrame   尺寸
 *  @param rowHeight   行高
 *  @param v           控制器>>>可根据需求修改
 */
-(id)initWithFrame:(CGRect)listFrame
    ListDataSource:(NSArray *)array
         rowHeight:(CGFloat)rowHeight
              view:(UIView *)v;




/**
 *  设置代理
 */
@property(nonatomic,assign)id<DownListMenuDelegate>delegate;

/**
 *   显示下拉列表
 */
-(void)showList;
/**
 *   隐藏
 */
-(void)hiddenList;


@end
