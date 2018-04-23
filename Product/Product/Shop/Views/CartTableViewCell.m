//
//  CartTableViewCell.m
//  Product
//
//  Created by vision on 17/12/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "CartTableViewCell.h"
#import "QuantityTool.h"

@interface CartTableViewCell ()<QuantityToolDelegate>{
    UIButton     *selectBtn;        //选择
    UILabel      *invaildLab;       //失效
    
    UIImageView  *goodsImageView;   //商品图片
    UILabel      *goodsNameLabel;   //商品标题
    UILabel      *goodsSpecLabel;   //商品规格
    UILabel      *priceLabel;       //价格
    QuantityTool *quantityTool;     //数量选择器
    
    CartGoodsModel  *myGoodsModel;
    
}

@end


@implementation CartTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        myGoodsModel=[[CartGoodsModel alloc] init];
        
        selectBtn=[[UIButton alloc] initWithFrame:CGRectMake(15, 40, 30, 30)];
        [selectBtn setImage:[UIImage imageNamed:@"pd_ic_pick_un"] forState:UIControlStateNormal];
        [selectBtn setImage:[UIImage imageNamed:@"pd_ic_pick_on"] forState:UIControlStateSelected];
        [selectBtn addTarget:self action:@selector(cartGoodsDidSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectBtn];
        
        invaildLab=[[UILabel alloc] initWithFrame:CGRectMake(15, 40, 30, 20)];
        invaildLab.text=@"失效";
        invaildLab.textColor=[UIColor whiteColor];
        invaildLab.backgroundColor=[UIColor lightGrayColor];
        invaildLab.font=[UIFont systemFontOfSize:10];
        invaildLab.textAlignment=NSTextAlignmentCenter;
        invaildLab.layer.cornerRadius=10;
        invaildLab.clipsToBounds=YES;
        [self.contentView addSubview:invaildLab];
        invaildLab.hidden=YES;
        
        goodsImageView=[[UIImageView alloc] initWithFrame:CGRectMake(selectBtn.right+10, 10, 80, 80)];
        goodsImageView.contentMode=UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:goodsImageView];
        
        goodsNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(goodsImageView.right+10, 10, kScreenWidth-goodsImageView.right-50, 30)];
        goodsNameLabel.font=[UIFont boldSystemFontOfSize:12];
        goodsNameLabel.numberOfLines=2;
        [self.contentView addSubview:goodsNameLabel];
        
        goodsSpecLabel=[[UILabel alloc] initWithFrame:CGRectMake(goodsImageView.right+10, goodsNameLabel.bottom, goodsNameLabel.width, 16)];
        goodsSpecLabel.textColor=[UIColor lightGrayColor];
        goodsSpecLabel.font=[UIFont systemFontOfSize:10];
        [self.contentView addSubview:goodsSpecLabel];
        
        priceLabel=[[UILabel alloc] initWithFrame:CGRectMake(goodsImageView.right+10, goodsSpecLabel.bottom, 120, 20)];
        priceLabel.textColor=[UIColor redColor];
        priceLabel.font=[UIFont systemFontOfSize:12];
        [self.contentView addSubview:priceLabel];
        
        UIButton *cartEditBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-35, 20, 25, 25)];
        [cartEditBtn setImage:[UIImage imageNamed:@"pd_ic_edit"] forState:UIControlStateNormal];
        [self.contentView addSubview:cartEditBtn];
        self.cartEditBtn=cartEditBtn;
        
        
        quantityTool=[[QuantityTool alloc] initWithFrame:CGRectMake(kScreenWidth-100, goodsSpecLabel.bottom+5, 90, 30)];
        quantityTool.delegate=self;
        [self.contentView addSubview:quantityTool];
    }
    return self;
}

#pragma mark -- CustomDelegate
#pragma mark QuantityToolDelegate
-(void)quantityToolSetQuantity:(NSInteger)quantity{
    self.setQuantityBlock(quantity);
}


#pragma mark -- Event Response
#pragma mark 选择商品
-(void)cartGoodsDidSelected:(UIButton *)sender{
    sender.selected=!sender.selected;
    self.selectedGoodsBlock(sender.selected);
}

#pragma mark -- Public Methods
-(void)cartTableViewCellDisplayWithModel:(CartGoodsModel *)goodsModel isCart:(BOOL)isCart{
    myGoodsModel=goodsModel;
    
    if (isCart) {
        if (goodsModel.valid==0) {
            invaildLab.hidden=NO;
            selectBtn.hidden=quantityTool.hidden=self.cartEditBtn.hidden=YES;
            goodsImageView.frame=CGRectMake(invaildLab.right+10, 10, 80, 80);
            goodsNameLabel.frame=CGRectMake(goodsImageView.right+10, 10, kScreenWidth-goodsImageView.right-20, 30);
        }else{
            invaildLab.hidden=YES;
            selectBtn.hidden=quantityTool.hidden=NO;
            goodsImageView.frame=CGRectMake(selectBtn.right+10, 10, 80, 80);
            if (goodsModel.isEdited) {
                self.cartEditBtn.hidden=NO;
                goodsNameLabel.frame=CGRectMake(goodsImageView.right+10, 10, kScreenWidth-goodsImageView.right-50, 30);
            }else{
                self.cartEditBtn.hidden=YES;
                goodsNameLabel.frame=CGRectMake(goodsImageView.right+10, 10, kScreenWidth-goodsImageView.right-20, 30);
            }
        }
        selectBtn.selected=goodsModel.select_status==1?YES:NO;
    }else{
        selectBtn.hidden=invaildLab.hidden=self.cartEditBtn.hidden=YES;
        goodsImageView.frame=CGRectMake(15, 10, 80, 80);
        goodsNameLabel.frame=CGRectMake(goodsImageView.right+10, 10, kScreenWidth-goodsImageView.right-20, 30);
        goodsSpecLabel.frame=CGRectMake(goodsImageView.right+10, goodsNameLabel.bottom, goodsNameLabel.width, 16);
        priceLabel.frame=CGRectMake(goodsImageView.right+10, goodsSpecLabel.bottom, 120, 20);
    }

    [goodsImageView sd_setImageWithURL:[NSURL URLWithString:goodsModel.url] placeholderImage:[UIImage imageNamed:@"pd_img_lite_nor"]];
    goodsNameLabel.text=goodsModel.name;
    goodsSpecLabel.text=goodsModel.spec_info;
    double aPrice=[goodsModel.price doubleValue];

    priceLabel.text=[NSString stringWithFormat:@"¥%.2f",aPrice];
    quantityTool.quantity=[goodsModel.quantity integerValue];
    quantityTool.storeQuantity=goodsModel.store;
}

@end
