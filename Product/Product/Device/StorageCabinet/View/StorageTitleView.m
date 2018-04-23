//
//  StorageTitleView.m
//  Product
//
//  Created by vision on 17/6/12.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StorageTitleView.h"

@interface StorageTitleView (){
    UILabel     *titleLabel;
    UILabel     *workTypeLabel;
}

@end

@implementation StorageTitleView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(10, 10, 5, 20)];
        aView.backgroundColor=[UIColor colorWithHexString:@"#ff9d38"];
        [self addSubview:aView];
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(aView.right+5, 5, 50, 30)];
        titleLabel.font=[UIFont systemFontOfSize:14];
        titleLabel.textColor=[UIColor colorWithHexString:@"#626262"];
        [self addSubview:titleLabel];
        
        workTypeLabel=[[UILabel alloc] initWithFrame:CGRectMake(titleLabel.right, 10, 60, 20)];
        workTypeLabel.layer.cornerRadius=10;
        workTypeLabel.clipsToBounds=YES;
        workTypeLabel.font=[UIFont systemFontOfSize:12];
        workTypeLabel.textColor=[UIColor whiteColor];
        workTypeLabel.textAlignment=NSTextAlignmentCenter;
        [self addSubview:workTypeLabel];
        
        UIButton *setWorkBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-45, 5, 30, 30)];
        [setWorkBtn setImage:[UIImage imageNamed:@"cwg_ic_setting"] forState:UIControlStateNormal];
        [setWorkBtn addTarget:self action:@selector(setWorkTypeAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:setWorkBtn];
        
    }
    return self;
}

-(void)setWorkTypeAction{
    if ([_delegate respondsToSelector:@selector(storageTitleViewdidSetAction:)]) {
        [_delegate storageTitleViewdidSetAction:self];
    }
}


#pragma mark -- setters
-(void)setTitleStr:(NSString *)titleStr{
    _titleStr=titleStr;
    titleLabel.text=titleStr;
}

-(void)setWorkType:(NSInteger)workType{
    _workType=workType;
    if (workType==1) {
        workTypeLabel.text=@"工作中";
        workTypeLabel.backgroundColor=[UIColor colorWithHexString:@"#00b7ee"];
    }else if (workType==2){
        workTypeLabel.text=@"理想状态";
        workTypeLabel.backgroundColor=[UIColor colorWithHexString:@"#63d162"];
    }else if (workType==3){
        workTypeLabel.text=@"异常";
        workTypeLabel.backgroundColor=[UIColor colorWithHexString:@"#ff4a5e"];
    }else if (workType==4){
        workTypeLabel.text=@"杀菌中";
        workTypeLabel.backgroundColor=[UIColor colorWithHexString:@"#cd64bd"];
    }
    CGFloat typeW=[workTypeLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-100, 20) withTextFont:workTypeLabel.font].width;
    workTypeLabel.frame=CGRectMake(titleLabel.right, 10, typeW+10, 20);
}



@end
