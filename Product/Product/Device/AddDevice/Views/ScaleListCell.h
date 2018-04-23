//
//  ScaleListCell.h
//  Product
//
//  Created by Xlink on 15/12/15.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScaleListCell : UITableViewCell


@property(nonatomic,strong)IBOutlet UILabel *nameLbl,*UUIDLbl,*LineLbl,*bindingStateLbl;

@property (weak, nonatomic) IBOutlet UIImageView *icon;

@end
