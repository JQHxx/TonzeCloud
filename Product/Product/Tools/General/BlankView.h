//
//  BlankView.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlankView : UIView
-(instancetype)initWithFrame:(CGRect)frame img:(NSString *)imgName text:(NSString *)text;

-(instancetype)initWithFrame:(CGRect)frame Searchimg:(NSString *)imgName text:(NSString *)text;

- (instancetype)initWithFrame:(CGRect)frame unOrderImg:(NSString *)imgName tipText:(NSString *)tipText  chooseText:(NSString *)chooseText;

-(instancetype)initWithShopFrame:(CGRect)frame Searchimg:(NSString *)imgName title:(NSString *)title text:(NSString *)text;
@end
