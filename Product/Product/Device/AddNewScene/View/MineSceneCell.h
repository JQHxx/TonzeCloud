//
//  MineSceneCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineSceneModel.h"

@interface MineSceneCell : UITableViewCell
/// 场景名称
@property (nonatomic ,strong) UILabel *sceneNameLab;
/// 设备数量
@property (nonatomic ,strong) UILabel *deviceNumberLab;
/// 设备id
@property (nonatomic ,strong) NSArray *deviceProductIdArray;

- (void)cellWithMineSceneMode:(MineSceneModel *)model;

@end
