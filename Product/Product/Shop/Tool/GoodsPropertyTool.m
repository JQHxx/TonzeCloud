//
//  GoodsPropertyTool.m
//  Product
//
//  Created by vision on 17/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "GoodsPropertyTool.h"
#import "QuantityTool.h"


#define kNewAddWidth   20  //给按钮额外增加的宽度
#define kMarginWidth   10  //按钮之间的间距
#define kSpacingWidth  15  //距离边缘的距离

@interface GoodsPropertyTool ()<QuantityToolDelegate,UITextFieldDelegate>{
    CGFloat       myHeight;
    UIImageView   *imgView;
    UILabel       *nameLabel;
    UILabel       *priceLabel;
    UIScrollView  *rootScrollView;
    UIView        *quantityView;
    UILabel       *numLab;
    QuantityTool  *quantityTool;
    
    UITextField   *quantityTextField;
    
    NSInteger      myQuantity;
    NSInteger      myProductId;
    
    NSMutableArray *specBtnArray;
}

@property (nonatomic,strong)UIView  *backgroundView;
@property (nonatomic,strong)UIView  *quantityBgView;
@property (nonatomic,strong)UIView  *contentView;

@end

@implementation GoodsPropertyTool

-(instancetype)initWithHeight:(CGFloat)viewHeight btnNames:(NSArray *)btnNames btnColors:(NSArray *)btnColors{
    self=[super init];
    if (self) {
        
        myHeight=viewHeight;
        myQuantity=1;
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *closeBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-48, -15, 30, 30)];
        [closeBtn setImage:[UIImage imageNamed:@"pd_shop_close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closePropertyTool) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
        
        imgView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 60, 60)];
        [self addSubview:imgView];
        
        nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(imgView.right+10, 10, kScreenWidth-imgView.right-30, 38)];
        nameLabel.font=[UIFont systemFontOfSize:15];
        nameLabel.textColor=[UIColor blackColor];
        nameLabel.numberOfLines=0;
        [self addSubview:nameLabel];
        
        priceLabel=[[UILabel alloc] initWithFrame:CGRectMake(imgView.right+10, nameLabel.bottom, kScreenWidth-imgView.right-30, 24)];
        priceLabel.textColor=[UIColor redColor];
        priceLabel.font=[UIFont systemFontOfSize:13];
        [self addSubview:priceLabel];
        
        UILabel *line=[[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom+10, kScreenWidth, 0.5)];
        line.backgroundColor=kLineColor;
        [self addSubview:line];
        
        rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, imgView.bottom+11, kScreenWidth, 0)];
        rootScrollView.backgroundColor=[UIColor whiteColor];
        [self addSubview:rootScrollView];
        
        quantityView=[[UIView alloc] initWithFrame:CGRectMake(0, rootScrollView.bottom, kScreenWidth, 50)];
        quantityView.backgroundColor=[UIColor whiteColor];
        [self addSubview:quantityView];
        
        numLab=[[UILabel alloc] initWithFrame:CGRectMake(15,10, 100, 30)];
        numLab.text=@"购买数量";
        numLab.textColor=[UIColor lightGrayColor];
        numLab.font=[UIFont systemFontOfSize:13];
        [quantityView addSubview:numLab];
        
        quantityTool=[[QuantityTool alloc] initWithFrame:CGRectMake(kScreenWidth-100, 10, 90, 30)];
        quantityTool.delegate=self;
        [quantityView addSubview:quantityTool];
        
        if (btnNames.count>0) {
            NSInteger btnCount=btnNames.count;
            CGFloat btnW=kScreenWidth/btnCount;
            for (NSInteger i=0; i<btnCount; i++) {
                UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(btnW*i, 370, btnW, 50)];
                [btn setTitle:btnNames[i] forState:UIControlStateNormal];
                btn.backgroundColor=btnColors[i];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(propertyToolDidClickButton:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btn];
            }
        }
    }
    return self;
}

#pragma mark -- UITextFieldDelegate
#pragma mark -- UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    // 当点击键盘的返回键（右下角）时，执行该方法。
    [quantityTextField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    if (![string isEqualToString:tem]) {
        return NO;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    //判断是否时我们想要限定的那个输入框
    if (quantityTextField == textField)
    {
        if ([toBeString length] >3)
        {
            return NO;
        }
    }
    return YES;
}

#pragma mark -- Custom Methods
#pragma mark  QuantityToolDelegate
-(void)quantityToolSetQuantity:(NSInteger)quantity{
    myQuantity=quantity;
}

#pragma mark 输入数量
-(void)quantityToolTextInQuantity{
    [kKeyWindow addSubview:self.quantityBgView];
    [kKeyWindow addSubview:self.contentView];
    quantityTextField.placeholder=[NSString stringWithFormat:@"%ld",(long)myQuantity];
    [quantityTextField becomeFirstResponder];
    self.contentView.layer.position = CGPointMake(kKeyWindow.center.x, kKeyWindow.center.y-40);
    self.contentView.transform = CGAffineTransformMakeScale(0.90, 0.90);
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.quantityBgView.alpha = 0.6;
        self.contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark -- Event Response
-(void)closePropertyTool{
    [self backViewHide];
}

#pragma mark 数量输入背景视图隐藏
-(void)quantityBackViewHide{
    [quantityTextField resignFirstResponder];
    [UIView animateWithDuration: 0.25 animations:^{
        self.contentView.layer.position=CGPointMake(kKeyWindow.center.x, kScreenHeight);
        self.quantityBgView.alpha=0;
    } completion:^(BOOL finished) {
        [self.contentView removeFromSuperview];
        [self.quantityBgView removeFromSuperview];
    }];
}

#pragma mark  数量输入后确认
-(void)quantityTextInConfirm{
    NSInteger count=kIsEmptyString(quantityTextField.text)?[quantityTextField.placeholder integerValue]:[quantityTextField.text integerValue];
    if (count>0) {
        if (count>self.goodsModel.store) {
            [kKeyWindow makeToast:@"商品库存不足" duration:1 position:CSToastPositionCenter];
        }else{
            [quantityTextField resignFirstResponder];
            myQuantity=count;
            [self quantityBackViewHide];
            quantityTextField.text=@"";
            self.quantity=myQuantity;
        }
    }else{
        [kKeyWindow makeToast:@"商品数量不能为0" duration:1 position:CSToastPositionCenter];
    }
}

#pragma mark 视图隐藏
-(void)backViewHide{
    [UIView animateWithDuration: 0.25 animations:^{
        self.frame=CGRectMake(0, kScreenHeight, kScreenWidth, myHeight);
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.backgroundView removeFromSuperview];
    }];
}

#pragma mark  商品规格选择
-(void)propertyValueDidSelected:(UIButton *)sender{
    NSInteger row=sender.tag/100;
    NSInteger cols=sender.tag%100;
    
    //所选规格按钮颜色处理
    NSArray *tempSpecArr=[specBtnArray objectAtIndex:row];
    for (NSInteger i=0; i<tempSpecArr.count; i++) {
        UIButton *btn=[tempSpecArr objectAtIndex:i];
        if (i==cols) {
            [btn setTitleColor:[UIColor colorWithHexString:@"0xf6ad46"] forState:UIControlStateNormal];
            btn.layer.borderColor=[UIColor colorWithHexString:@"0xf6ad46"].CGColor;
        }else{
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            btn.layer.borderColor=[UIColor lightGrayColor].CGColor;
        }
    }
    NSDictionary *spec = self.goodsModel.spec[row];
    NSArray *type_info = [spec objectForKey:@"type_info"];
    myProductId = [[type_info[cols] objectForKey:@"product_id"] integerValue];
    if ([self.delegate respondsToSelector:@selector(goodsPropertyToolDidSeleteContent:)]) {
        [self.delegate goodsPropertyToolDidSeleteContent:myProductId];
    }
}

#pragma mark 底部按钮点击事件
-(void)propertyToolDidClickButton:(UIButton *)sender{
    [self backViewHide];
    if ([self.delegate respondsToSelector:@selector(goodsPropertyToolDidClickButton:withGoodsId:OldProductId:newProductId:Quantity:)]) {
        [self.delegate goodsPropertyToolDidClickButton:sender.currentTitle withGoodsId:self.goodsModel.goods_id OldProductId:self.goodsModel.product_id newProductId:myProductId Quantity:myQuantity];
    }
}

#pragma mark -- Public Methods
#pragma mark 显示
-(void)goodsPropertyToolShow{
    [kKeyWindow addSubview:self.backgroundView];
    [kKeyWindow addSubview:self];
    self.frame=CGRectMake(0, kScreenHeight, kScreenWidth, myHeight);
    [UIView animateWithDuration: 0.25 animations:^{
        self.backgroundView.alpha = 0.6;
        self.frame=CGRectMake(0, kScreenHeight-myHeight, kScreenWidth, myHeight);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -- Setters and Getters
#pragma mark 获取商品信息
-(void)setGoodsModel:(GoodsModel *)goodsModel{
    _goodsModel=goodsModel;
    [self loadGoodsPropertyToolWithModel:goodsModel];
}

#pragma mark 设置商品数量
-(void)setQuantity:(NSInteger )quantity{
    _quantity=quantity;
    myQuantity=quantity;
    quantityTool.quantity=myQuantity;
}

#pragma mark 解析商品数据
-(void)loadGoodsPropertyToolWithModel:(GoodsModel *)goodsModel{
    
    myProductId=goodsModel.product_id;
    
    NSString *imgUrl = nil;
    if(kIsDictionary(goodsModel.image_default)){
        imgUrl = [goodsModel.image_default objectForKey:@"s_url"];
    }
    [imgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"pd_img_lite_nor"]];
    nameLabel.text=goodsModel.title;
    priceLabel.text=[NSString stringWithFormat:@"¥%.2f",[goodsModel.price doubleValue]];
    
    CGFloat specH=0.0;
    NSArray *goodsSpecArr=goodsModel.spec;
    if (goodsSpecArr.count>0) {
        for (UIView *view in rootScrollView.subviews) {
            if (([view isKindOfClass:[UILabel class]]&&view.tag>1000)||[view isKindOfClass:[UIButton class]]) {
                [view removeFromSuperview];
            }
        }
        
        specBtnArray=[[NSMutableArray alloc] init]; // 规格按钮数组
        CGFloat tempHeight=0.0;
        for (NSInteger i=0; i<goodsSpecArr.count; i++) {
            NSDictionary *dict=goodsSpecArr[i];
            UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(15, 10+tempHeight, kScreenWidth-20, 20)];
            titleLab.text=dict[@"type_name"];
            titleLab.font=[UIFont systemFontOfSize:13];
            titleLab.textColor=[UIColor lightGrayColor];
            titleLab.tag=1001+i;
            [rootScrollView addSubview:titleLab];
            
            NSArray *values=dict[@"type_info"];
            NSMutableArray *tempBtnArr=[[NSMutableArray alloc] init];

            UIButton *lastBtn = nil;
            for (NSInteger j=0; j<values.count; j++) {
                NSString *valueStr=[values[j] objectForKey:@"spec_value"];
                
                NSInteger isSelected=[[values[j] objectForKey:@"is_select"] integerValue];
                if (isSelected<2) {
                    UIButton *valueBtn=[[UIButton alloc] initWithFrame:CGRectZero];
                    [valueBtn setTitle:valueStr forState:UIControlStateNormal];
                    [valueBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                    valueBtn.titleLabel.font=[UIFont systemFontOfSize:13];
                    valueBtn.layer.cornerRadius=3;
                    valueBtn.layer.borderWidth=1;
                    valueBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
                    valueBtn.tag=i*100+j;
                    [valueBtn addTarget:self action:@selector(propertyValueDidSelected:) forControlEvents:UIControlEventTouchUpInside];
                    [rootScrollView addSubview:valueBtn];
                    
                    CGFloat valueBtnW=[valueStr boundingRectWithSize:CGSizeMake(kScreenWidth-30, 30) withTextFont:valueBtn.titleLabel.font].width+10;
                    if (valueBtnW<40) {
                        valueBtnW=40;
                    }
                    
                    //设置文字的宽度
                    CGFloat tempWidth=[valueStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}  context:nil].size.width;
                    valueBtn.width =tempWidth +kNewAddWidth;
                    valueBtn.height = 30;
                    if (j == 0) {  //第一个的时候放心大胆的布局，并记录下上一个button的位置
                        if(valueBtn.width >kScreenWidth - 2*kSpacingWidth){//单行文字超过一行处理
                            valueBtn.width = kScreenWidth -2*kSpacingWidth;
                        }
                        valueBtn.x = kSpacingWidth;
                        valueBtn.y = titleLab.bottom+5;
                        lastBtn =valueBtn;
                    }else{//依据上一个button来布局
                        if (lastBtn.right+valueBtn.width+kMarginWidth>kScreenWidth) {  //不足以再摆一行了
                            valueBtn.y = lastBtn.bottom+kMarginWidth;
                            valueBtn.x = kSpacingWidth;
                            if(valueBtn.width >kScreenWidth - 2*kSpacingWidth){//单行文字超过一行处理
                                valueBtn.width = kScreenWidth -2*kSpacingWidth;
                            }
                        }else{
                            valueBtn.y = lastBtn.y;
                            valueBtn.x=lastBtn.right+kMarginWidth;
                        }
                        //    保存上一次的Button
                        lastBtn = valueBtn;
                    }
                    
                    [tempBtnArr addObject:valueBtn];
                    
                    if (isSelected==1) {  //默认选择
                        [valueBtn setTitleColor:[UIColor colorWithHexString:@"0xf6ad46"] forState:UIControlStateNormal];
                        valueBtn.layer.borderColor=[UIColor colorWithHexString:@"0xf6ad46"].CGColor;
                    }
                }
            }
            [specBtnArray addObject:tempBtnArr];
            
            tempHeight=lastBtn.bottom;
        }
        specH=tempHeight;
    }
    
    if (specH>240) {
        rootScrollView.frame=CGRectMake(0, imgView.bottom+11, kScreenWidth, 240);
    }else{
        rootScrollView.frame=CGRectMake(0, imgView.bottom+11, kScreenWidth, specH);
    }
    rootScrollView.contentSize=CGSizeMake(kScreenWidth, specH+20);
    
    quantityView.frame=CGRectMake(0, rootScrollView.bottom,kScreenWidth,50);
    quantityTool.storeQuantity=goodsModel.store;
    
    
}

#pragma mark 背景视图
-(UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(backViewHide)];
        [_backgroundView addGestureRecognizer: tap];
    }
    return _backgroundView;
}

#pragma mark 数量输入框背景视图
-(UIView *)quantityBgView{
    if (!_quantityBgView) {
        _quantityBgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _quantityBgView.backgroundColor = [UIColor blackColor];
        _quantityBgView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(quantityBackViewHide)];
        [_quantityBgView addGestureRecognizer: tap];
    }
    return _quantityBgView;
}

#pragma mark 自定义输入弹出框
-(UIView *)contentView{
    if (!_contentView) {
        _contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-60, 150)];
        _contentView.backgroundColor=[UIColor whiteColor];
        _contentView.layer.cornerRadius=3;
        _contentView.clipsToBounds=YES;
        
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth-80, 30)];
        titleLab.text=@"输入商品数量";
        titleLab.textColor=[UIColor blackColor];
        titleLab.font=[UIFont systemFontOfSize:16];
        titleLab.textAlignment=NSTextAlignmentCenter;
        [_contentView addSubview:titleLab];
        
        quantityTextField=[[UITextField alloc] initWithFrame:CGRectMake(100, titleLab.bottom+10, kScreenWidth-260, 30)];
        quantityTextField.layer.borderWidth=1;
        quantityTextField.layer.borderColor=[UIColor colorWithHexString:@"#dcdcdc"].CGColor;
        quantityTextField.delegate=self;
        quantityTextField.returnKeyType=UIReturnKeyDone;
        quantityTextField.textAlignment=NSTextAlignmentCenter;
        quantityTextField.keyboardType=UIKeyboardTypeNumberPad;
        [_contentView addSubview:quantityTextField];
        
        UIButton *confirmBtn=[[UIButton alloc] initWithFrame:CGRectMake(60, quantityTextField.bottom+20,kScreenWidth-180, 35)];
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        confirmBtn.backgroundColor=kSystemColor;
        [confirmBtn addTarget:self action:@selector(quantityTextInConfirm) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:confirmBtn];
        
    }
    return _contentView;
}



@end
