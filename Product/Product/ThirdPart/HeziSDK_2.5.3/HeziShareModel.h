//
//  HeziShareModel.h
//  ActivityBox
//
//  Created by ljcoder on 16/10/8.
//  Copyright © 2016年 sunnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeziShareModel : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *imgUrl;
@property (strong, nonatomic) NSString *linkUrl;
@property (strong, nonatomic) NSString *callBackUrl;
@property (strong,nonatomic)UIView *pageView;

@end
