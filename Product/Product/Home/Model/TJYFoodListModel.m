
//
//  TJYFoodListModel.m
//  Product
//
//  Created by zhuqinlu on 2017/4/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYFoodListModel.h"

@implementation TJYFoodListModel

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    TJYFoodListModel *instance = [[TJYFoodListModel alloc] init];
    if (instance) {
        instance.id = self.id;
        instance.name = [self.name copyWithZone:zone];
        instance.energykcal = self.energykcal;
        instance.image_url = [self.image_url copyWithZone:zone];
        instance.target_id = self.target_id;
        instance.carbohydrate = self.carbohydrate;
        instance.vitaminC = self.vitaminC;
        instance.vitaminE = self.vitaminE;
        instance.protein = self.protein;
        instance.fat = self.fat;
        instance.insolublefiber = self.insolublefiber;
        instance.totalvitamin = self.totalvitamin;
        instance.cholesterol = self.cholesterol;
        instance.weight = self.weight;
        instance.totalkcal = self.totalkcal;
        
    }
    return instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    TJYFoodListModel *instance = [[TJYFoodListModel alloc] init];
    if (instance) {
        instance.id = self.id;
        instance.name = [self.name copyWithZone:zone];
        instance.energykcal = self.energykcal;
        instance.image_url = [self.image_url copyWithZone:zone];
        instance.target_id = self.target_id;
        instance.carbohydrate = self.carbohydrate;
        instance.vitaminC = self.vitaminC;
        instance.vitaminE = self.vitaminE;
        instance.protein = self.protein;
        instance.fat = self.fat;
        instance.insolublefiber = self.insolublefiber;
        instance.totalvitamin = self.totalvitamin;
        instance.cholesterol = self.cholesterol;
        instance.weight = self.weight;
        instance.totalkcal = self.totalkcal;
        
    }
    
    return instance;
}

@end
