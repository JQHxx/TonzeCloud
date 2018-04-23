//
//  ScaleScoreView.m
//  Product
//
//  Created by vision on 17/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ScaleScoreView.h"
#import "TJYUserModel.h"

@interface ScaleScoreView (){
    UILabel      *scoreLabel;
    UILabel      *timeLabel;
    UILabel      *commentLabel;
}

@end

@implementation ScaleScoreView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 70, 70)];
        imageView.layer.cornerRadius=30;
        imageView.clipsToBounds=YES;
        [self addSubview:imageView];
        
        UILabel *nameLbl=InsertLabel(self,CGRectMake(10,imageView.bottom+5,90, 30),NSTextAlignmentCenter,@"",[UIFont systemFontOfSize:12],[UIColor blackColor],NO);
        
        TJYUserModel *userModel=[TonzeHelpTool sharedTonzeHelpTool].user;
        if (userModel) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:userModel.photo] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
            nameLbl.text=userModel.nick_name;
        }
        
        
       scoreLabel=InsertLabel(self,CGRectMake(imageView.right+15,10, 100, 30),NSTextAlignmentLeft,@"100分",[UIFont boldSystemFontOfSize:24],[UIColor colorWithHexString:@"#ff9d38"],NO);
       timeLabel=InsertLabel(self,CGRectMake(imageView.right+15,scoreLabel.bottom, 150, 20),NSTextAlignmentLeft,[[TJYHelper sharedTJYHelper] getCurrentDateTime],[UIFont systemFontOfSize:12],[UIColor colorWithHexString:@"#c9c9c9"],NO);
        
        commentLabel=[[UILabel alloc] initWithFrame:CGRectMake(imageView.right+15, timeLabel.bottom+5, kScreenWidth-imageView.right-20, 20)];
        commentLabel.textColor = [UIColor colorWithHexString:@"#626262"];
        commentLabel.font = [UIFont systemFontOfSize:16];
        commentLabel.numberOfLines=0;
        [self addSubview:commentLabel];
        
        
        UIButton *shareBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-45, 15, 30, 30)];
        [shareBtn setImage:[UIImage imageNamed:@"ic_tzy_share"] forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shareBtn];
        
    }
    return self;
}
#pragma mark -- 分享
- (void)shareBtn{
    if ([_ScaleScoreDelegate respondsToSelector:@selector(ScaleScoreView:)]) {
        [_ScaleScoreDelegate ScaleScoreView:self];
    }
}
-(void)setBodyScore:(NSInteger)bodyScore{
    _bodyScore=bodyScore;
    bodyScore=bodyScore>100?100:bodyScore;
    NSMutableAttributedString *scoreAttributeStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld分",(long)bodyScore]];
    [scoreAttributeStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(scoreAttributeStr.length-1, 1)];
    scoreLabel.attributedText=scoreAttributeStr;
    
    timeLabel.text=[[TJYHelper sharedTJYHelper] getCurrentDateTime];
    
    NSString *contentStr=nil;
    if (bodyScore<60) {
        contentStr=@"您的健康评分不及格哟，请及时调整饮食结构，开始每天30分钟以上的运动吧。";
    }else if (bodyScore>80){
        contentStr=@"您的健康评分非常优秀哦，请继续坚持良好的生活习惯。";
    }else{
        contentStr=@"您的健康评分良好，请继续保持，坚持每天运动";
    }
    
    commentLabel.text=contentStr;
    CGFloat heigh=[contentStr boundingRectWithSize:CGSizeMake(commentLabel.width, CGFLOAT_MAX) withTextFont:commentLabel.font].height;
    commentLabel.frame=CGRectMake(commentLabel.x, commentLabel.y, commentLabel.width, heigh);
}




@end
