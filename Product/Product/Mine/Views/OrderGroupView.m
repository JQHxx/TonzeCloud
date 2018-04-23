//
//  OrderGroupView.m
//  Weekens
//
//  Created by fei on 15/4/16.
//  Copyright (c) 2015年 ___YKSKJ.COM___. All rights reserved.
//

#import "OrderGroupView.h"
#import "OrderButton.h"

@interface OrderGroupView (){
    NSMutableArray  *labArray;
}

@end


@implementation OrderGroupView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        
        labArray=[[NSMutableArray alloc] init];
        
        [self loadOrderButtonGroup];
        
    }
    return self;
}

-(void)loadOrderButtonGroup{
    NSArray *titles=[[NSArray alloc] initWithObjects:@"待付款",@"待发货",@"待收货",@"已完成", nil];
    NSArray *images=[[NSArray alloc] initWithObjects:@"men_ic_01_pay",@"men_ic_02_send",@"men_ic_03_take",@"men_ic_04_over", nil];
    
    for (int i=0; i<4; i++) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kOrderButtonWidth*i, 0, kOrderButtonWidth, 70);
        btn.tag=i+10;
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:UIColorHex(0x626262) forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [btn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:6];
        [btn addTarget:self action:@selector(orderButtonActionWithSender:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        CGFloat cartBadgeOffset;
        if (kScreenWidth>320&&kScreenWidth<=375 ){
            cartBadgeOffset = 53;
        }else if(kScreenWidth==320){
            cartBadgeOffset = 45;
        }else if(kScreenWidth>375){
            cartBadgeOffset = 57;
        }
        
        UILabel *cartBadge=[[UILabel alloc] initWithFrame:CGRectMake(kOrderButtonWidth*i+kOrderLineW*i+cartBadgeOffset, self.origin.y+8, 20, 20)];
        cartBadge.layer.cornerRadius=10;
        cartBadge.backgroundColor= UIColorHex(0xff3b30);
        cartBadge.textColor=[UIColor whiteColor];
        cartBadge.layer.masksToBounds=YES;
        cartBadge.textAlignment=NSTextAlignmentCenter;
        cartBadge.font=[UIFont systemFontOfSize:10];
        cartBadge.tag=i;
        [labArray addObject:cartBadge];
        [self addSubview:cartBadge];
    
        cartBadge.hidden=YES;
    }
    
    UILabel *linLabel = [[UILabel alloc]initWithFrame:CGRectMake(22, 0, kScreenWidth - 22, 0.5)];
    linLabel.backgroundColor = kRGBColor(230, 230, 230);
//    [self addSubview:linLabel];
}

-(void)orderButtonActionWithSender:(OrderButton *)sender{
    NSInteger index=sender.tag-10;
    if ([_delegate respondsToSelector:@selector(orderGroupViewBtnActionWithIndex:)]) {
        [_delegate orderGroupViewBtnActionWithIndex:index];
    }
}

- (void)setOrderNumArr:(NSArray *)orderNumArr{
    _orderNumArr=orderNumArr;
    if (orderNumArr.count > 0) {
        for (int i=0; i<orderNumArr.count; i++) {
            UILabel *lab=labArray[i];
            NSInteger badge=[orderNumArr[i] integerValue];
            
            if (badge==0) {
                lab.hidden=YES;
                lab.text=nil;
            }else{
                lab.hidden=NO;
                if(badge>99){
                   lab.text=@"99+";
                }else{
                   lab.text=[NSString stringWithFormat:@"%li",(long)badge];
                }
            }
        }
    }else{
        for (int i=0; i<labArray.count; i++) {
            UILabel *lab=labArray[i];
            lab.text=nil;
            lab.hidden=YES;
        }
    }
}

@end
