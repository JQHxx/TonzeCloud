//
//  QuantityTool.m
//  Product
//
//  Created by vision on 17/12/21.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "QuantityTool.h"

@interface QuantityTool (){
    UIButton  *subtractBtn;
    UILabel   *quantityLab;
    UIButton  *addBtn;
}

@end

@implementation QuantityTool

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        CGFloat labWidth=frame.size.width/3.0;
        CGFloat labHeight=frame.size.height;
        //减
         subtractBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, labWidth, labHeight)];
        [subtractBtn setImage:[UIImage imageNamed:@"pd_ic_num_minus"] forState:UIControlStateNormal];
        [subtractBtn addTarget:self action:@selector(handleQuantityAction:) forControlEvents:UIControlEventTouchUpInside];
        subtractBtn.tag=100;
        [self addSubview:subtractBtn];
        
        quantityLab = [[UILabel alloc] initWithFrame:CGRectMake(subtractBtn.right - 1, 0, labWidth,labHeight)];
        quantityLab.textAlignment = NSTextAlignmentCenter;
        quantityLab.text=@"1";
        quantityLab.userInteractionEnabled=YES;
        quantityLab.font=[UIFont systemFontOfSize:14];
        [self addSubview:quantityLab];
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quantityTapAction)];
        [self addGestureRecognizer:tapGesture];
        
        //加
        addBtn = [[UIButton alloc] initWithFrame:CGRectMake(quantityLab.right, 0, labWidth, labHeight)];
        [addBtn setImage:[UIImage imageNamed:@"pd_ic_num_add"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(handleQuantityAction:) forControlEvents:UIControlEventTouchUpInside];
        addBtn.tag=101;
        [self addSubview:addBtn];
    }
    return self;
}

#pragma mark -- Event response
#pragma mark 数量加减
-(void)handleQuantityAction:(UIButton *)sender{
    if (sender.tag==100) {
        self.quantity--;
        if (self.quantity<1) {
            self.quantity=1;
        }
        addBtn.enabled=YES;
    }else{
        addBtn.enabled=YES;
        self.quantity++;
        if (self.quantity>self.storeQuantity) {
            self.quantity=self.storeQuantity>0?self.storeQuantity:1;
            [kKeyWindow makeToast:@"商品库存不足" duration:1.0 position:CSToastPositionCenter];
            addBtn.enabled=NO;
        }
    }
    subtractBtn.enabled=self.quantity>1;
    
    if (addBtn.enabled) {
        if ([self.delegate respondsToSelector:@selector(quantityToolSetQuantity:)]) {
            [self.delegate quantityToolSetQuantity:self.quantity];
        }
    }
    quantityLab.text=[NSString stringWithFormat:@"%ld",(long)self.quantity];
    
}

#pragma mark 点击数量
-(void)quantityTapAction{
    if ([self.delegate respondsToSelector:@selector(quantityToolTextInQuantity)]) {
        [self.delegate quantityToolTextInQuantity];
    }
}


#pragma mark -- Setters
-(void)setQuantity:(NSInteger)quantity{
    _quantity=quantity;
    subtractBtn.enabled=quantity>1;
    quantityLab.text=[NSString stringWithFormat:@"%ld",(long)quantity];
}

@end
