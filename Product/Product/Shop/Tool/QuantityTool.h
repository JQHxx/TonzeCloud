//
//  QuantityTool.h
//  Product
//
//  Created by vision on 17/12/21.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QuantityToolDelegate <NSObject>
//设置数量（填写）
-(void)quantityToolSetQuantity:(NSInteger)quantity;

//设置数量（输入）
@optional
-(void)quantityToolTextInQuantity;

@end


@interface QuantityTool : UIView

@property (nonatomic,assign)id<QuantityToolDelegate>delegate;
@property (nonatomic,assign)NSInteger quantity;  //数量
@property (nonatomic,assign)NSInteger storeQuantity; //库存


@end
