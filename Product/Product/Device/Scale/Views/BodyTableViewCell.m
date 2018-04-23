//
//  BodyTableViewCell.m
//  Product
//
//  Created by vision on 17/5/4.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BodyTableViewCell.h"
#import "IndexResultView.h"
#import "ScaleHelper.h"

@interface BodyTableViewCell (){
    UIImageView           *pointerImageView;
    IndexResultView       *indexView;
    UIView                *resultView;
    UILabel               *resultLabel;
}

@end

@implementation BodyTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        pointerImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 12, 20)];
        pointerImageView.image = [UIImage imageNamed:@"tzy_ic_pub_mark"];
        [self.contentView addSubview:pointerImageView];
        
        indexView=[[IndexResultView alloc] initWithFrame:CGRectMake(10, 30, kScreenWidth-20, 20)];
        [self.contentView addSubview:indexView];
        
        resultView=[[UIView alloc] initWithFrame:CGRectMake(10, indexView.bottom+5, kScreenWidth-20, 20)];
        [self.contentView addSubview:resultView];
        
        resultLabel=[[UILabel alloc] initWithFrame:CGRectMake(10,resultView.bottom+5, kScreenWidth-20, 30)];
        resultLabel.numberOfLines=0;
        resultLabel.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:resultLabel];
        
    }
    return self;
}

-(void)bodyCellDisplayWithModel:(ResultModel *)result key:(NSString *)key{
    CGRect pointFrame=pointerImageView.frame;
    pointFrame.origin.x=[[ScaleHelper sharedScaleHelper] getBodyIndexValueXWithValue:result.value width:kScreenWidth-20 key:key];
    // 水滴有可以过界，如果数值超出范围，就是设置在最后
    if (pointFrame.origin.x > kScreenWidth - 10) {
        pointFrame.origin.x = kScreenWidth - 10 - (pointFrame.size.width/2);
    }
    pointerImageView.frame=pointFrame;
    
    
    NSArray *arr=[[ScaleHelper sharedScaleHelper] getBodyIndexArrayWithKey:key];
    CGFloat labW=(kScreenWidth-20)/(arr.count+1);
    for (NSInteger i=0; i<arr.count; i++) {
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake((i+1)*labW-20, 10, 60, 20)];
        lab.font=[UIFont systemFontOfSize:12];
        if ([key isEqualToString:@"visfat"]) {
            NSInteger value=[arr[i] integerValue];
            lab.text=[NSString stringWithFormat:@"%ld",(long)value];
        }else{
            CGFloat value=[arr[i] doubleValue];
            lab.text=[NSString stringWithFormat:@"%.1f",value];
        }
        lab.textAlignment=NSTextAlignmentCenter;
        [self.contentView addSubview:lab];
    }
    
    indexView.key=key;
    
    NSArray *resultArr=[[ScaleHelper sharedScaleHelper] getBodyIndexResultArrayWithKey:key];
    NSInteger resultCount=resultArr.count;
    if (resultCount>0) {
        CGFloat lblWidth=(kScreenWidth-20)/resultCount;
        for (NSInteger i=0; i<resultArr.count; i++) {
            UILabel *resultLab=[[UILabel alloc] initWithFrame:CGRectMake(lblWidth*i, 0, lblWidth, 20)];
            resultLab.text=resultArr[i];
            resultLab.textAlignment=NSTextAlignmentCenter;
            resultLab.font=[UIFont systemFontOfSize:12];
            resultLab.textColor=[UIColor colorWithHexString:@"#626262"];
            [resultView addSubview:resultLab];
        }
    }
    
    
    resultLabel.text=result.resultText;
    CGFloat resultH=[result.resultText boundingRectWithSize:CGSizeMake(kScreenWidth-20, CGFLOAT_MAX) withTextFont:resultLabel.font].height;
    resultLabel.frame=CGRectMake(10, resultView.bottom+5, kScreenWidth-20, resultH+10);
}


+(CGFloat)bodyTableViewCellGetCellHeightWithModel:(ResultModel *)result{
     CGFloat resultH=[result.resultText boundingRectWithSize:CGSizeMake(kScreenWidth-20, CGFLOAT_MAX) withTextFont:[UIFont systemFontOfSize:14]].height;
    return resultH+100;
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
