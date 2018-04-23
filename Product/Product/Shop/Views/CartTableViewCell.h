//
//  CartTableViewCell.h
//  Product
//
//  Created by vision on 17/12/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartGoodsModel.h"

typedef void(^CartCellDidSelectedGoodsBlock)(BOOL isSelected);
typedef void(^CartCellSetQuantityBlock)(NSInteger quantity);


@interface CartTableViewCell : UITableViewCell

@property (nonatomic,strong)UIButton *cartEditBtn;

@property (nonatomic, copy )CartCellDidSelectedGoodsBlock selectedGoodsBlock;

@property (nonatomic, copy )CartCellSetQuantityBlock  setQuantityBlock;

-(void)cartTableViewCellDisplayWithModel:(CartGoodsModel *)goodsModel isCart:(BOOL)isCart;

@end
