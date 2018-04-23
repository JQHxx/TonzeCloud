//
//  ScaleHistoryCell.m
//  Product
//
//  Created by vision on 17/5/8.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ScaleHistoryCell.h"
#import "ScaleHelper.h"

@interface ScaleHistoryCell (){
    UILabel       *weekLabel;
    UILabel       *timeLabel;
    UILabel       *bmiLabel;
    UILabel       *bmiStandardLabel;
    UILabel       *weightLabel;
    UILabel       *weightStandardLabel;
}

@end

@implementation ScaleHistoryCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        weekLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 60, 20)];
        weekLabel.font=[UIFont systemFontOfSize:14];
        weekLabel.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:weekLabel];
        
        timeLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, weekLabel.bottom, 60, 20)];
        timeLabel.font=[UIFont systemFontOfSize:12];
        timeLabel.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:timeLabel];
        
        bmiLabel=[[UILabel alloc] initWithFrame:CGRectMake(weekLabel.right+10, 5, 120, 25)];
        bmiLabel.textColor=[UIColor blackColor];
        bmiLabel.font=[UIFont systemFontOfSize:16];
        [self.contentView addSubview:bmiLabel];
        
        bmiStandardLabel=[[UILabel alloc] initWithFrame:CGRectMake(bmiLabel.right, 5 ,50, 25)];
        bmiStandardLabel.textColor=[UIColor blackColor];
        bmiStandardLabel.font=[UIFont systemFontOfSize:12];
        [self.contentView addSubview:bmiStandardLabel];
        
        weightLabel=[[UILabel alloc] initWithFrame:CGRectMake(weekLabel.right+10,bmiLabel.bottom, 120, 25)];
        weightLabel.textColor=[UIColor blackColor];
        weightLabel.font=[UIFont systemFontOfSize:16];
        [self.contentView addSubview:weightLabel];
        
        weightStandardLabel=[[UILabel alloc] initWithFrame:CGRectMake(weightLabel.right, bmiLabel.bottom, 50, 25)];
        weightStandardLabel.textColor=[UIColor blackColor];
        weightStandardLabel.font=[UIFont systemFontOfSize:12];
        [self.contentView addSubview:weightStandardLabel];
        
        
    }
    return self;
}


-(void)scaleCellDisplayWithModel:(ScaleModel *)scale{
    NSString *todayStr=[[TJYHelper sharedTJYHelper] getCurrentDate];
    if ([todayStr isEqualToString:scale.measure_date]) {
        weekLabel.text=@"今天";
    }else{
        weekLabel.text=[scale.measure_date substringWithRange:NSMakeRange(5, 5)];
    }
    
    timeLabel.text=[scale.measure_time substringWithRange:NSMakeRange(11, 5)];
    
    NSMutableAttributedString *bmiAttributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"BMI：%.1f",scale.bmi]];
    [bmiAttributeStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, 3)];
    bmiLabel.attributedText=bmiAttributeStr;
    
    bmiStandardLabel.text=[[ScaleHelper sharedScaleHelper] getBMIStandardWithBmi:scale.bmi];
    bmiStandardLabel.textColor=[[ScaleHelper sharedScaleHelper] getResultColorWithResult:bmiStandardLabel.text key:@"bmi"];
    
    NSMutableAttributedString *weightAttributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"体重：%.2fkg",scale.weight]];
    [weightAttributeStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, 3)];
    weightLabel.attributedText=weightAttributeStr;
    
    weightStandardLabel.text=[[ScaleHelper sharedScaleHelper] getWeightStandardWithWeight:scale.weight];
    weightStandardLabel.textColor=[[ScaleHelper sharedScaleHelper] getResultColorWithResult:weightStandardLabel.text key:@"weight"];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
