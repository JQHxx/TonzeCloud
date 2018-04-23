//
//  RankTableViewCell.m
//  Product
//
//  Created by vision on 17/5/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RankTableViewCell.h"

@interface RankTableViewCell (){
    UILabel           *rankLabel;
    UIImageView       *headImageView;
    UILabel           *nameLabel;
    UILabel           *stepLabel;
}

@end


@implementation RankTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake( 10, 11, 37, 37)];
        [self addSubview:_imgView];
        
        rankLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 14, 20, 30)];
        rankLabel.font=[UIFont systemFontOfSize:14];
        rankLabel.textColor=[UIColor colorWithHexString:@"0x313131"];
        [self.contentView addSubview:rankLabel];
        
        headImageView=[[UIImageView alloc] initWithFrame:CGRectMake(rankLabel.right+15, 10, 38, 38)];
        headImageView.layer.cornerRadius = 19;
        headImageView.layer.masksToBounds =YES;
        [self.contentView addSubview:headImageView];
        
        nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+15, 19, 120, 20)];
        nameLabel.font=[UIFont systemFontOfSize:14];
        nameLabel.textColor=[UIColor colorWithHexString:@"0x313131"];
        [self.contentView addSubview:nameLabel];
        
        stepLabel=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-90, 19, 80, 20)];
        stepLabel.font=[UIFont systemFontOfSize:14];
        stepLabel.textAlignment=NSTextAlignmentRight;
        stepLabel.textColor=[UIColor colorWithHexString:@"0xff9d38"];
        [self.contentView addSubview:stepLabel];
        
    }
    return self;
}

-(void)rankCellDisplayWithModel:(StepRankModel *)model{
    rankLabel.text = [NSString stringWithFormat:@"%ld",model.ranking];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:kIsEmptyString(model.photo)?@"":model.photo] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    nameLabel.text = model.nick_name;
    stepLabel.text = [NSString stringWithFormat:@"%ld步",model.step_num];
    
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
