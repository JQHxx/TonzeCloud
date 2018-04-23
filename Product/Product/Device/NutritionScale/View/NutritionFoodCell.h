//
//  NutritionFoodCell.h
//  Product
//
//  Created by mk-imac2 on 2017/9/2.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYFoodListModel.h"

typedef void (^NutritionFoodBlock)(TJYFoodListModel * food);


@interface NutritionFoodCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgFood;
@property (weak, nonatomic) IBOutlet UILabel *lblFood;
@property (weak, nonatomic) IBOutlet UILabel *lblWeight;
@property (weak, nonatomic) IBOutlet UILabel *lblHeat;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

-(void)renderNutritionFoodCell:(id)data foodBlock:(NutritionFoodBlock)block;

@end
