//
//  BasewebViewController.h
//  Product
//
//  Created by zhuqinlu on 2017/4/18.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : NSUInteger {
    
    BaseWebViewTypeADiary          =1,    //日记
    

} BaseWebViewType;


@interface BasewebViewController : BaseViewController
/// url模式
@property (nonatomic, assign) BOOL  isWebUrl;
/// 是否收藏
@property (nonatomic, assign) BOOL  isCollect;

@property (nonatomic, copy )NSString *titleText;

@property (nonatomic, copy )NSString *urlStr;
/// 文章id
@property (nonatomic, assign) NSInteger articleId  ;
/// 文章名称
@property (nonatomic, copy)NSString *titleName;

@property (nonatomic, copy)NSString *imageUrl;

@property (nonatomic,assign)BaseWebViewType   type;
@end
