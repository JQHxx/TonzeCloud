//
//  UnitSelectViewController.h
//  Product
//
//  Created by mk-imac2 on 2017/9/7.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UnitSelectBlock)(NSString * strUnit);

@interface UnitSelectViewController : BaseViewController

@property (nonatomic,strong) NSString * strUnit;

@property (nonatomic,copy) UnitSelectBlock unitSelcetBlock;


@end
