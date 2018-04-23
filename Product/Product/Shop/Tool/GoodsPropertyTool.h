//
//  GoodsPropertyTool.h
//  Product
//
//  Created by vision on 17/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsModel.h"

@protocol GoodsPropertyToolDelegate <NSObject>

/**
 *  底部按钮事件
 *
 *  @param btnName      底部按钮名称
 *  @param goods_id     商品ID
 *  @param oldProductId 旧产品ID
 *  @param newProductId 新产品ID
 *  @param quantity     数量
 */
-(void)goodsPropertyToolDidClickButton:(NSString *)btnName withGoodsId:(NSInteger)goods_id OldProductId:(NSInteger)oldProductId newProductId:(NSInteger)newProductId Quantity:(NSInteger)quantity;

@optional
-(void)goodsPropertyToolDidSeleteContent:(NSInteger)product_id;

@end

@interface GoodsPropertyTool : UIView

@property (nonatomic,strong)GoodsModel  *goodsModel;
@property (nonatomic,assign)NSInteger   quantity;
@property (nonatomic,assign)id<GoodsPropertyToolDelegate>delegate;


/**
 *  初始化属性工具
 *  @param viewHeight 工具视图高度
 *  @param btnNames   底部按钮名称数组
 *  @param btnNames   底部按钮背景颜色
 */
-(instancetype)initWithHeight:(CGFloat)viewHeight btnNames:(NSArray *)btnNames btnColors:(NSArray *)btnNames;

/**
 *  工具视图弹出显示
 *
 */

-(void)goodsPropertyToolShow;

@end
