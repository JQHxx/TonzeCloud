//
//  NotiCenterCell.m
//  Product
//
//  Created by Xlink on 15/12/7.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "NotiCenterCell.h"

@interface NotiCenterCell (){
    UILabel *titleLbl;
    UILabel *stateLbl;
    UILabel *detailLbl;
    UILabel *notiStateLbl;
}

@end


@implementation NotiCenterCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        titleLbl.textColor=[UIColor blackColor];
        titleLbl.font=[UIFont systemFontOfSize:14];
        titleLbl.numberOfLines=0;
        [self.contentView addSubview:titleLbl];
        
        stateLbl=[[UILabel alloc] initWithFrame:CGRectZero];
        stateLbl.textColor=[UIColor lightGrayColor];
        stateLbl.font=[UIFont systemFontOfSize:12];
        [self.contentView addSubview:stateLbl];
        
        
        detailLbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 35, 150, 20)];
        detailLbl.textColor=[UIColor lightGrayColor];
        detailLbl.font=[UIFont systemFontOfSize:12];
        [self.contentView addSubview:detailLbl];
        
        notiStateLbl=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100, 15, 90, 30)];
        notiStateLbl.textColor=[UIColor lightGrayColor];
        notiStateLbl.font=[UIFont systemFontOfSize:14];
        notiStateLbl.textAlignment=NSTextAlignmentRight;
        [self.contentView addSubview:notiStateLbl];
        
    }
    return self;
}

-(void)updateUI:(NotiModel *)model{
    MyLog(@"title:%@,type:%@",model.deviceName,model.deviceType);
    
    titleLbl.text=model.deviceName;
    stateLbl.text=model.deviceType;
    detailLbl.text=model.time;
    
    CGFloat titleW=[model.deviceName boundingRectWithSize:CGSizeMake(kScreenWidth-100, 20) withTextFont:titleLbl.font].width;
    titleLbl.frame=CGRectMake(10, 10, titleW, 20);
    stateLbl.frame=CGRectMake(titleLbl.right+5, 10, kScreenWidth-100-titleW, 20);
    notiStateLbl.text=model.notiState;
    
    if ([model.notiType integerValue]==0||[model.notiType integerValue]==3) {
        
    }
    
    if ([notiStateLbl.text isEqualToString:@"等待处理 >>"]) {
        //改变label颜色
        notiStateLbl.textColor=UIColorFromRGB(0xff8314);
    }else{
        notiStateLbl.textColor=UIColorFromRGB(0xAEAEAE);
    }
}

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
