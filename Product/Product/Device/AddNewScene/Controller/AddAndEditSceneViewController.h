//
//  AddSceneViewController.h
//  Product
//
//  Created by 肖栋 on 17/6/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

typedef enum: NSInteger{
    AddSceneType,   // 添加场景
    EditSceneType,  // 编辑场景
}SceneType;

@interface AddAndEditSceneViewController : BaseViewController

/// 场景状态类型
@property (nonatomic ,assign) SceneType sceneType;
/// 场景id
@property (nonatomic, assign) NSInteger  sceneId;

@end
