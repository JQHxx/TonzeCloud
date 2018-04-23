//
//  BodyTableViewCell.h
//  Product
//
//  Created by vision on 17/5/4.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BodySectionModel.h"

@interface BodyTableViewCell : UITableViewCell

-(void)bodyCellDisplayWithModel:(ResultModel *)result key:(NSString *)key;


+(CGFloat)bodyTableViewCellGetCellHeightWithModel:(ResultModel *)result;


@end
