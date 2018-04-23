//
//  TJYHealthContentModel.h
//  Product
//
//  Created by 肖栋 on 17/5/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//
/*
 "question": [
 {
 "assess_id": 94,
 "name": "1测试第一个问题题目",
 "answer": [
 {
 "assess_id": 95,
 "name": "第一个问题第一个选项",
 "score": 11
 },
 {
 "assess_id": 96,
 "name": "第一个问题第二个选项",
 "score": 12
 }
 ]
 */
#import <Foundation/Foundation.h>
@class titleContentModel;

@interface TJYHealthContentModel : NSObject

@property(nonatomic ,strong)NSString *name;

@property(nonatomic ,assign)NSInteger assess_id;

@property (nonatomic, strong) NSArray<titleContentModel *> *answer;

@end
@interface titleContentModel : NSObject

@property(nonatomic ,strong)NSString *name;

@property(nonatomic ,assign)NSInteger score;

@end
