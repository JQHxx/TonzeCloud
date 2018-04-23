//
//  RankHeadView.m
//  Product
//
//  Created by vision on 17/5/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RankHeadView.h"

@interface RankHeadView (){
    UILabel           *rankLabel;
    UIImageView       *headImageView;
    UILabel           *nameLabel;
    UILabel           *stepLabel;
}

@end

@implementation RankHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*150/375)];
        headImg.image = [UIImage imageNamed:@"walk_img"];
        [self addSubview:headImg];
        
        headImageView=[[UIImageView alloc] initWithFrame:CGRectMake(15, headImg.bottom+10, 38, 38)];
        headImageView.layer.cornerRadius = 19;
        headImageView.layer.masksToBounds = YES;
        [self addSubview:headImageView];
        
        nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+15, headImg.bottom+10, 120, 20)];
        nameLabel.font=[UIFont systemFontOfSize:16];
        nameLabel.textColor=[UIColor colorWithHexString:@"0x313131"];
        [self addSubview:nameLabel];
        
        rankLabel=[[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+15,nameLabel.bottom,120, 20)];
        rankLabel.font=[UIFont systemFontOfSize:14];
        rankLabel.textColor=[UIColor lightGrayColor];
        [self addSubview:rankLabel];
        
        stepLabel=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-90, headImg.bottom+14, 80, 30)];
        stepLabel.font=[UIFont systemFontOfSize:14];
        stepLabel.textAlignment=NSTextAlignmentRight;
        stepLabel.textColor=[UIColor colorWithHexString:@"0xff9d38"];
        [self addSubview:stepLabel];

    }
    return self;
}

-(void)setMyRank:(StepRankModel *)myRank{
    _myRank=myRank;
    
    rankLabel.text=[NSString stringWithFormat:@"第%ld名",(long)myRank.ranking];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:myRank.photo] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
    nameLabel.text=myRank.nick_name;
    stepLabel.text=[NSString stringWithFormat:@"%ld步",myRank.step_num];

}


@end
