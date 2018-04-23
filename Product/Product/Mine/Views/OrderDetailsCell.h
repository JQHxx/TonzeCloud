//
//  OrderDetailsCell.h
//  Product
//
//  Created by zhuqinlu on 2017/12/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OrderDetailCellDelegate <NSObject>

- (void)didSelectDuplicateOrder;

@end

@interface OrderDetailsCell : UITableViewCell

///
@property (nonatomic ,strong)  UILabel *titleLab;
///
@property (nonatomic ,strong)  UILabel *contentLab;
///
@property (nonatomic ,strong)  UIButton *pasteBtn;
///
@property (nonatomic, weak)   id<OrderDetailCellDelegate> delegate;

@end
