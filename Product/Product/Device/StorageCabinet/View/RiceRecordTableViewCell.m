//
//  RiceRecordTableViewCell.m
//  Product
//
//  Created by vision on 17/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RiceRecordTableViewCell.h"

@interface RiceRecordTableViewCell (){
    UILabel       *riceValueLbl;
    UILabel       *timeLbl;
}

@end


@implementation RiceRecordTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(16, 8, 50, 50)];
        imgView.image=[UIImage imageNamed:@"cwg_ic_yongmi"];
        [self.contentView addSubview:imgView];
        
        riceValueLbl=[[UILabel alloc] initWithFrame:CGRectMake(imgView.right+12, 12,150, 42)];
        riceValueLbl.font=[UIFont systemFontOfSize:16];
        riceValueLbl.textColor=[UIColor colorWithHexString:@"#313131"];
        [self.contentView addSubview:riceValueLbl];
        
        timeLbl=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-80, 12,60, 40)];
        timeLbl.textAlignment=NSTextAlignmentRight;
        timeLbl.font=[UIFont systemFontOfSize:14];
        timeLbl.textColor=[UIColor colorWithHexString:@"#959595"];
        [self.contentView addSubview:timeLbl];
    }
    return self;
}


-(void)riceRecordCellDisplayWithModel:(RiceRecordModel *)model{
    NSInteger weight=model.outRiceVlue*150;
    NSString *valueStr=[NSString stringWithFormat:@"%ld杯≈%ld克",(long)model.outRiceVlue,(long)weight];
    NSMutableAttributedString *attributedStr=[[NSMutableAttributedString alloc] initWithString:valueStr];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#959595"] range:NSMakeRange(2, valueStr.length-2)];
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(2, valueStr.length-2)];
    riceValueLbl.attributedText=attributedStr;
    
    timeLbl.text=model.time;
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
