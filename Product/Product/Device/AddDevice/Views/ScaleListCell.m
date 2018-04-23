//
//  ScaleListCell.m
//  Product
//
//  Created by Xlink on 15/12/15.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "ScaleListCell.h"
#import "NSUserDefaultInfos.h"
@implementation ScaleListCell

- (void)awakeFromNib {
    // Initialization code
    
    self.bindingStateLbl.layer.cornerRadius=5.0f;
    self.bindingStateLbl.layer.masksToBounds=YES;
    
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
