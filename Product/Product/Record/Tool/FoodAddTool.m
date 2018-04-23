//
//  FoodAddTool.m
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "FoodAddTool.h"

@implementation FoodAddTool
singleton_implementation(FoodAddTool)

-(void)setSelectFoodArray:(NSMutableArray *)selectFoodArray{
    _selectFoodArray=selectFoodArray;
}

-(void)insertFood:(FoodAddModel *)food{
    if (_selectFoodArray==nil) {
        _selectFoodArray=[[NSMutableArray alloc] init];
    }
    [self.selectFoodArray addObject:food];
}

-(void)updateFood:(FoodAddModel *)food{
    for (NSInteger i=0; i<self.selectFoodArray.count; i++) {
        FoodAddModel *model=self.selectFoodArray[i];
        if (model.id==food.id) {
            [self.selectFoodArray replaceObjectAtIndex:i withObject:food];
        }
    }
}

-(void)deleteFood:(FoodAddModel *)food{
    [self.selectFoodArray removeObject:food];
}

-(void)removeAllFood{
    [self.selectFoodArray removeAllObjects];
}

@end
