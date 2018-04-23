//
//  ConfirmOrderViewController.m
//  Product
//
//  Created by vision on 17/12/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ConfirmOrderViewController.h"
#import "CartGoodsModel.h"
#import "CartTableViewCell.h"
#import "AddressTableViewCell.h"
#import "SelectAdressViewController.h"
#import "PayOrderViewController.h"
#import "ShippingAddressModel.h"
#import "OrderAddressTableViewCell.h"

@interface ConfirmOrderViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate>{
    UITextField   *remarkTextField;
    UILabel       *payPriceLabel;
    
    NSMutableArray       *addressArray;
    ShippingAddressModel *myConsignee;
    NSInteger     memberId;
    
}

@property (nonatomic,strong)UITableView *listTableView;
@property (nonatomic,strong)UIView      *bottomView;



@end

@implementation ConfirmOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"确认订单";
    
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    addressArray=[[NSMutableArray alloc] init];
    myConsignee=[[ShippingAddressModel alloc] init];
    memberId=[[NSUserDefaultInfos getValueforKey:USER_ID] integerValue];
 
    [self.view insertSubview:self.listTableView atIndex:0];
    [self.view addSubview:self.bottomView];
    
    [self requestDefaultConsigneeAddressInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([TJYHelper sharedTJYHelper].isOrderAddressReload) {
        [self requestDefaultConsigneeAddressInfo];
        [TJYHelper sharedTJYHelper].isOrderAddressReload=NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remarkKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remarkKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark --UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==1){
        return self.goodsArray.count;
    } else if (section==3){
        return 2;
    }else{
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (myConsignee&&!kIsEmptyString(myConsignee.ship_id)) {
            OrderAddressTableViewCell *cell=[[OrderAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            [cell orderAddressTableViewCellDisplayWithAddress:myConsignee];
            return cell;
        }else{
            UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
            UIButton *textInBtn=[[UIButton alloc] initWithFrame:CGRectMake(20, 30, 150, 40)];
            [textInBtn setImage:[UIImage imageNamed:@"pd_ic_edit"] forState:UIControlStateNormal];
            [textInBtn setTitle:@"请填写收货人信息" forState:UIControlStateNormal];
            [textInBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
            textInBtn.titleLabel.font=[UIFont systemFontOfSize:15];
            textInBtn.imageEdgeInsets=UIEdgeInsetsMake(0, -10, 0, 0);
            [textInBtn addTarget:self action:@selector(textInConsigneeInfo) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:textInBtn];
            return cell;
        }
    }else if (indexPath.section==1) {
        static NSString *cellIdentifier=@"OrderGoodsCell";
        CartTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[CartTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        CartGoodsModel *model=self.goodsArray[indexPath.row];
        [cell cartTableViewCellDisplayWithModel:model isCart:NO];
        kSelfWeak;
        cell.setQuantityBlock=^(NSInteger quantity){
            if (weakSelf.isFastBuy) {
                NSString *user_id = [NSUserDefaultInfos getValueforKey:USER_ID];
                CartGoodsModel *model=self.goodsArray[indexPath.row];
                NSString *body = [NSString stringWithFormat:@"member_id=%@&btype=is_fastbuy&goods_id=%ld&product_id=%ld&num=%ld",user_id,(long)model.goods_id,model.product_id,quantity];
                [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopQuickBuy body:body success:^(id json) {
                    for (CartGoodsModel *goods in weakSelf.goodsArray) {
                        if (goods.goods_id==model.goods_id&&goods.product_id==model.product_id) {
                            goods.quantity=[NSString stringWithFormat:@"%ld",quantity];
                            break;
                        }
                    }
                    [weakSelf.listTableView reloadData];
                    [weakSelf calculateGoodsTotalPrice];
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            }else{
                NSString *body=[NSString stringWithFormat:@"member_id=%ld&goods_id=%ld&product_id=%ld&num=%ld&type=goods",(long)memberId,(long)model.goods_id,(long)model.product_id,(long)quantity];
                kSelfWeak;
                [[NetworkTool sharedNetworkTool] postShopMethodWithURL:kShopCartChangeNum body:body success:^(id json) {
                    for (CartGoodsModel *goods in weakSelf.goodsArray) {
                        if (goods.goods_id==model.goods_id&&goods.product_id==model.product_id) {
                            goods.quantity=[NSString stringWithFormat:@"%ld",quantity];
                            break;
                        }
                    }
                    [weakSelf.listTableView reloadData];
                    [TJYHelper sharedTJYHelper].isCartListReload=YES;
                    [weakSelf calculateGoodsTotalPrice];
                } failure:^(NSString *errorStr) {
                    [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                }];
            }
        };
        return cell;
    }else  if (indexPath.section==4) {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
       
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(15, 10, 75, 22)];
        lab.textColor=[UIColor blackColor];
        lab.font=[UIFont systemFontOfSize:14];
        lab.text=@"留言备注：";
        [cell.contentView  addSubview:lab];
        
        remarkTextField=[[UITextField alloc] initWithFrame:CGRectMake(lab.right, 7, kScreenWidth-100, 30)];
        remarkTextField.textColor=[UIColor blackColor];
        remarkTextField.placeholder=@"选填，填写备注信息（50个字内）";
        remarkTextField.font=[UIFont systemFontOfSize:14];
        remarkTextField.clearButtonMode = UITextFieldViewModeWhileEditing;  //编辑时出现叉号
        remarkTextField.returnKeyType =UIReturnKeyDone;   //return键变成完成键
        remarkTextField.delegate=self;
        [cell.contentView addSubview:remarkTextField];
        
        return cell;
    }else{
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.textLabel.font=[UIFont systemFontOfSize:14];
        cell.detailTextLabel.font=[UIFont systemFontOfSize:14];
        if (indexPath.section==2) {
            cell.textLabel.text=@"支付方式";
            cell.detailTextLabel.text=@"在线支付";
        }else{
            if (indexPath.row==0) {
                cell.textLabel.text=@"商品合计";
                cell.detailTextLabel.text=[NSString stringWithFormat:@"¥%.2f",self.totalPrice];
            }else{
                cell.textLabel.text=@"运费";
                cell.detailTextLabel.text=@"包邮";
            }
        }
        return cell;
    }
}


#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1||indexPath.section==0) {
        return 100;
    }else{
        return 44;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==1) {
        return 40;
    }else{
        return 0.1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==1) {
        UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        headerView.backgroundColor=[UIColor whiteColor];
        
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(15, 10, 120, 20)];
        titleLab.text=@"商品信息";
        titleLab.font=[UIFont systemFontOfSize:14];
        titleLab.textColor=[UIColor lightGrayColor];
        [headerView addSubview:titleLab];
        
        return headerView;
    }else{
        return nil;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        [self textInConsigneeInfo];
    }
}

#pragma mark 返回
-(void)leftButtonAction{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定要放弃该订单吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"我再想想"style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
        
    }];
    [sureAction setValue:[UIColor darkGrayColor] forKey:@"_titleTextColor"];
    [alert addAction:sureAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"去意已决"style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [cancelAction setValue:kSystemColor forKey:@"_titleTextColor"];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark -- NSNotification
#pragma mark 键盘弹出
-(void)remarkKeyboardWillShow:(NSNotification *)notifi{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notifi.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    kSelfWeak;
    void (^animation)(void) = ^void(void) {
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:4];
        [weakSelf.listTableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark  隐藏键盘
-(void)remarkKeyboardWillHide:(NSNotification *)notifi{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notifi.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    kSelfWeak;
    void (^animation)(void) = ^void(void) {
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [weakSelf.listTableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark -- Custom Delegate
#pragma mark -- UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    // 当点击键盘的返回键（右下角）时，执行该方法。
    [remarkTextField resignFirstResponder];
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
    if (remarkTextField == textField)
    {
        if ([toBeString length] > 50)
        {   //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:50];
            [self.view makeToast:@"不能超过50个字" duration:1.0 position:CSToastPositionCenter];
            return NO;
        }
    }
    return YES;
}

#pragma mark -- Event Response
#pragma mark  提交订单
-(void)submitOrderAction{
    BOOL hasEmoji = [[TJYHelper sharedTJYHelper] strIsContainEmojiWithStr:remarkTextField.text];
    if (kIsEmptyString(myConsignee.ship_id)) {
        [self.view makeToast:@"请先填写收货人信息" duration:1.0 position:CSToastPositionCenter];
    }else if (hasEmoji) {
        [self.view makeToast:@"备注中不能包含特殊符号" duration:1.0 position:CSToastPositionCenter];
    } else {
        kSelfWeak;
        NSString *body=[NSString stringWithFormat:@"member_id=%ld&addr_id=%@&memo=%@&isfastbuy=%ld",memberId,myConsignee.ship_id,remarkTextField.text,self.isFastBuy?(long)1:(long)0];
        [[NetworkTool sharedNetworkTool] postShopMethodWithURL:kShopOrderCreate body:body success:^(id json) {
            NSDictionary *result=[json objectForKey:@"result"];
            if (kIsDictionary(result)&&result.count>0) {
                PayOrderViewController *payOrderVC=[[PayOrderViewController alloc] init];
                payOrderVC.payAmount=self.totalPrice;
                payOrderVC.order_id=[result valueForKey:@"order_id"];
                payOrderVC.isFastBuy=self.isFastBuy;
                payOrderVC.createTimeStr=[result valueForKey:@"createtime"];
                [self.navigationController pushViewController:payOrderVC animated:YES];
            }
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}

#pragma mark 填写收货信息
-(void)textInConsigneeInfo{
    SelectAdressViewController *selAddressVC=[[SelectAdressViewController alloc] init];
    selAddressVC.selectedConsigneeId=myConsignee.ship_id;
    kSelfWeak;
    selAddressVC.selectAddressBlock=^(ShippingAddressModel *selConsignee){
        myConsignee=selConsignee;
        [weakSelf.listTableView reloadData];
    };
    [self.navigationController pushViewController:selAddressVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 获取默认收货信息
-(void)requestDefaultConsigneeAddressInfo{
    NSString *body = [NSString stringWithFormat:@"member_id=%ld&version=%@",(long)memberId,APP_VERSION];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postShopMethodWithURL:kShippingAddress body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count>0) {
            NSArray *addressList = [result valueForKey:@"addrList"];
            if (kIsArray(addressList) && addressList.count > 0) {
                NSMutableArray *tempArr=[[NSMutableArray alloc] init];
                NSMutableArray *tempDefaultArr=[[NSMutableArray alloc] init];
                for (NSDictionary *dic in addressList) {
                    ShippingAddressModel *addressModel = [[ShippingAddressModel alloc] init];
                    [addressModel setValues:dic];
                    if ([addressModel.is_default isEqualToString:@"true"]) {
                        [tempDefaultArr addObject:addressModel];
                    }
                    [tempArr addObject:addressModel];
                }
                addressArray=tempArr;
                
                if (tempArr.count>0) {
                    myConsignee=tempDefaultArr.count>0?tempDefaultArr[0]:addressArray[0];
                }
            }
            [weakSelf.listTableView reloadData];
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 计算商品总金额
-(void)calculateGoodsTotalPrice{
    CGFloat  goodsPrice=0.0;
    for (CartGoodsModel *model in self.goodsArray) {
        goodsPrice+=[model.quantity integerValue]*[model.price doubleValue];

    }
    self.totalPrice=goodsPrice;
    [self.listTableView reloadData];
    
    NSString *priceStr=[NSString stringWithFormat:@"应付金额：¥%.2f",self.totalPrice];
    NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:priceStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5, priceStr.length-5)];
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(5, priceStr.length-8)];
    payPriceLabel.attributedText=attributeStr;
    
}

#pragma mark -- Setters and Getters
#pragma mark 确认订单信息视图
-(UITableView *)listTableView{
    if (!_listTableView) {
        _listTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kBodyHeight-50) style:UITableViewStyleGrouped];
        _listTableView.dataSource=self;
        _listTableView.delegate=self;
        _listTableView.backgroundColor=[UIColor bgColor_Gray];
    }
    return _listTableView;
}

#pragma mark 底部视图
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _bottomView.backgroundColor=[UIColor whiteColor];
        
        payPriceLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, 15, kScreenWidth-120, 20)];
        payPriceLabel.textColor=[UIColor lightGrayColor];
        payPriceLabel.font=[UIFont systemFontOfSize:18];
        NSString *priceStr=[NSString stringWithFormat:@"应付金额：¥%.2f",self.totalPrice];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:priceStr];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5, priceStr.length-5)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(5, 1)];
        payPriceLabel.attributedText=attributeStr;
        [_bottomView addSubview:payPriceLabel];
        
        UIButton *submitBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 0, 100, 50)];
        submitBtn.backgroundColor=kSystemColor;
        [submitBtn setTitle:@"提交订单" forState:UIControlStateNormal];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        submitBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        [submitBtn addTarget:self action:@selector(submitOrderAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:submitBtn];
    }
    return _bottomView;
}



@end
