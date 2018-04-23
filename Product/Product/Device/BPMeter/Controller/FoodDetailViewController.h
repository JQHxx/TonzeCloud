//
//  FoodDetailViewController.h
//  Product
//
//  Created by Feng on 16/5/21.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

@interface FoodDetailViewController : BaseViewController{

    IBOutlet UIImageView *foodIV;
    
    IBOutlet UILabel *foodLbl;
    
    IBOutlet UITextView *detailTV;
    
    
}


@property(nonatomic,strong)NSDictionary *foodDic;


@end
