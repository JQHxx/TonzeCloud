//
//  FoodDetailViewController.m
//  Product
//
//  Created by Feng on 16/5/21.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "FoodDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface FoodDetailViewController ()

@end

@implementation FoodDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"食材详情";
    
    foodLbl.text=[self.foodDic objectForKey:@"name"];
    detailTV.text=[self.foodDic objectForKey:@"instructions"];
    
    NSString *imgURL=[[self.foodDic objectForKey:@"images"] objectAtIndex:0]
    ;
    
    [foodIV sd_setImageWithURL:[NSURL URLWithString:imgURL]
                   placeholderImage:[UIImage imageNamed:@"菜谱默认图.png"] options:0];
}


@end
