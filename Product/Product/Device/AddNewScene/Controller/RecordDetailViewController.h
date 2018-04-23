//
//  RecordDetailiViewController.h
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

@interface RecordDetailViewController : BaseViewController
/// 场景名称
@property (nonatomic, copy) NSString *sceneNameStr;
/// 场景id
@property (nonatomic, assign) NSInteger  sceneId;
/// 场景执行标识
@property (nonatomic, copy) NSString *record_flag;

@end
