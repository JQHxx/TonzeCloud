//
//  SportRecordTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportRecordModel.h"

@interface SportRecordTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *sportImage;
@property (weak, nonatomic) IBOutlet UILabel *sportName;
@property (weak, nonatomic) IBOutlet UILabel *sportTimeLength;
@property (weak, nonatomic) IBOutlet UILabel *SportCalory;
@property (weak, nonatomic) IBOutlet UILabel *SportTime;

-(void)cellDisplayWithModel:(SportRecordModel *)sport;

@end
