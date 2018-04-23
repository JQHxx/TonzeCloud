//
//  AddSceneCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/16.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SceneDetailDeviceTaskModel.h"

typedef void(^CellButtonClick)(UIButton *sender);

@interface AddSceneCell : UITableViewCell

/// cell点击回调
@property (nonatomic, copy) CellButtonClick buttonClick;
/// 图标
@property (nonatomic ,strong) UIImageView *iconImg;
/// 设备名称|| 时间间隔
@property (nonatomic ,strong) UILabel *deviceNameLab;
/// 操作名称(云菜谱：+ 菜谱名称)
@property (nonatomic ,strong) UILabel *operationNameLab;
/// 删除按钮
@property (nonatomic ,strong) UIButton *deleteBtn;

- (void)setAddSceneCellWithModel:(SceneDetailDeviceTaskModel *)model;

@end
