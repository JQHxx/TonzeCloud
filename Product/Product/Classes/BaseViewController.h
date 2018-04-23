//
//  BaseViewController.h
//  Product
//
//  Created by 梁家誌 on 16/7/29.
//  Copyright © 2016年 TianJi. All rights reserved.
//

//不会处理设备被重置的弹框的基类

#import <UIKit/UIKit.h>
#import "StoryboardInstantiateable.h"

@interface BaseViewController : UIViewController

@property (nonatomic ,assign)BOOL isHiddenBackBtn;     //隐藏返回按钮
@property (nonatomic ,assign)BOOL  isHiddenNavBar;     //隐藏导航栏
@property (nonatomic, assign) BOOL  isHiddenRightBtn;   // 隐藏右按钮
@property (nonatomic ,copy)NSString *baseTitle;        //标题
@property (nonatomic ,copy)NSString *leftImageName;
@property (nonatomic ,copy)NSString *rightImageName;
@property (nonatomic ,copy)NSString *rigthTitleName;

+ (instancetype)instantiateOfStoryboard;

-(void)leftButtonAction;
-(void)rightButtonAction;

/**
 *  弹出框
 *
 *  @param title   标题
 *  @param message 信息
 */
- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message;
/**
 *  跳转视图
 *
 *  @param viewController 跳转的控制器
 */
- (void)push:(UIViewController *)viewController;

/**
 *  跳转到快速登录
 *
 */
- (void)pushToFastLogin;

 
 

@end
