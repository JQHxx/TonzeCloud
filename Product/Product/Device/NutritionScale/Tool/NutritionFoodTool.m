//
//  NutritionFoodTool.h
//  Product
//
//  Created by Wzy on 1/9/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "NutritionFoodTool.h"

@implementation NutritionFoodTool
singleton_implementation(NutritionFoodTool)

-(void)setSelectFoodArray:(NSMutableArray *)selectFoodArray{
    _selectFoodArray=selectFoodArray;
}

-(void)insertFood:(TJYFoodListModel *)food{
    if (_selectFoodArray==nil) {
        _selectFoodArray=[[NSMutableArray alloc] init];
    }
    [self.selectFoodArray addObject:food];
}

-(void)updateFood:(TJYFoodListModel *)food{
    for (NSInteger i=0; i<self.selectFoodArray.count; i++) {
        TJYFoodListModel *model=self.selectFoodArray[i];
        if (model.id==food.id) {
            [self.selectFoodArray replaceObjectAtIndex:i withObject:food];
        }
    }
}

-(void)deleteFood:(TJYFoodListModel *)food{
    [self.selectFoodArray removeObject:food];
}

-(void)removeAllFood{
    [self.selectFoodArray removeAllObjects];
}

@end
