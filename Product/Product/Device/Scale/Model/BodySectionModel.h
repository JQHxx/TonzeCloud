//
//  BodySectionModel.h
//  Product
//
//  Created by vision on 17/5/4.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ResultModel;

@interface BodySectionModel : NSObject

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, copy) NSString *sectionTitle;

@property (nonatomic, copy) NSString *value;

@property (nonatomic, copy) NSString *standard;

@property (nonatomic, assign) BOOL isExpanded;

@property (nonatomic, strong)ResultModel *resultModel;

@property (nonatomic, copy )NSString  *keyStr;


@end


@interface ResultModel : NSObject

@property (nonatomic, copy) NSString *value;

@property (nonatomic, copy) NSString *resultText;

@end
