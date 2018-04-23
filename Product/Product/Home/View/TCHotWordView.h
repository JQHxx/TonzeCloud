//
//  TCHotWordView.h
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCHotWordView : UIView

@property (nonatomic, strong) NSArray *hotWordsArray;
@property (nonatomic, strong) void (^viewHeightRecalc) (CGFloat height);  //视图高度
@property (nonatomic, strong) void (^hotSearchClick)   (NSString *title); //点击关键词

@end
