//
//  RecordButton.h
//  Product
//
//  Created by 肖栋 on 17/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordButton : UIButton{

    UIImageView  *image;
    UILabel      *contentLabel;
    UILabel      *titleLabel;
    UILabel      *dateLabel;
}
@property(nonatomic ,strong)NSDictionary  *recordDict;
-(instancetype)initWithFrame:(CGRect)frame;
@end
