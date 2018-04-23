//
//  ShopCartViewController.m
//  Product
//
//  Created by vision on 17/12/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopCartViewController.h"
#import "ConfirmOrderViewController.h"
#import "CartTableViewCell.h"
#import "CartGoodsModel.h"
#import "GoodsPropertyTool.h"
#import "OrderViewController.h"
#import "ShopDetailViewController.h"

@interface ShopCartViewController ()<UITableViewDelegate,UITableViewDataSource,GoodsPropertyToolDelegate>{
    UIButton        *allSelectBtn;      //全选
    UILabel         *totalPriceLabel;   //合计金额
    UIButton        *balanceBtn;        //结算
    UIButton        *addCollectionBtn;  //移入收藏夹
    UIButton        *deleteBtn;         //删除
    
    BOOL            isEditing;
    NSInteger       selectTotalNum;      //所选商品总数
    double          selectedGoodsPrice;  //所选商品总金额
    NSInteger       selectedGoodsNum;    //已选商品个数
    
    GoodsPropertyTool *propertyTool;
    NSInteger      memberId;
}

@property (nonatomic,strong)UIView           *cartBlankView;
@property (nonatomic,strong)UITableView      *cartTableView;
@property (nonatomic,strong)UIView           *bottomView;
@property (nonatomic,strong)NSMutableArray   *cartDataArray;
@property (nonatomic,strong)NSMutableArray   *invaidGoodsArray;  //失效商品

@end

@implementation ShopCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"购物车";
    self.view.backgroundColor=[UIColor bgColor_Gray];
    self.rigthTitleName=@"编辑";
    
    selectedGoodsNum=0;
    memberId=[[NSUserDefaultInfos getValueforKey:USER_ID] integerValue];
    
    [self.view addSubview:self.cartTableView];
    [self.cartTableView addSubview:self.cartBlankView];
    self.cartBlankView.hidden=YES;
    [self.view addSubview:self.bottomView];
    
    [self requestShopCartData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([TJYHelper sharedTJYHelper].isCartListReload) {
        [self requestShopCartData];
        [TJYHelper sharedTJYHelper].isCartListReload=NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payOrderBackNotify:) name:@"kPayOrderBackAction" object:nil];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section==0?self.cartDataArray.count:self.invaidGoodsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"CartTableViewCell";
    CartTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[CartTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    CartGoodsModel *model=indexPath.section==0?self.cartDataArray[indexPath.row]:self.invaidGoodsArray[indexPath.row];
    [cell cartTableViewCellDisplayWithModel:model isCart:YES];
    
    if (indexPath.section==0) {
        cell.cartEditBtn.tag=indexPath.row;
        [cell.cartEditBtn addTarget:self action:@selector(editCartGoodsAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    kSelfWeak;
    cell.selectedGoodsBlock=^(BOOL isSelected){  //选择商品
        [weakSelf requestForSelectGoodsOrNotWithType:@"one" objIdent:model.obj_ident isSelected:isSelected];
    };
    cell.setQuantityBlock=^(NSInteger quantity){ //修改商品数量
        [weakSelf requestForChangeGoodsNumWithGoodsId:model.goods_id productId:model.product_id quantity:quantity];
    };
    
    return cell;
}

#pragma mark -- UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        CartGoodsModel *model=self.cartDataArray[indexPath.row];
        ShopDetailViewController *shopDetailVC=[[ShopDetailViewController alloc] init];
        shopDetailVC.product_id=model.product_id;
        [self.navigationController pushViewController:shopDetailVC animated:YES];
    }else{
        [self.view makeToast:@"该商品已经失效" duration:1.0 position:CSToastPositionCenter];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==1&&self.invaidGoodsArray.count>0) {
        return 40;
    }else{
        return 0.1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section==0?10:0.1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==1&&self.invaidGoodsArray.count>0) {
        UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        headerView.backgroundColor=[UIColor whiteColor];
        
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(15, 10, 120, 20)];
        titleLab.textColor=[UIColor blackColor];
        titleLab.font=[UIFont systemFontOfSize:14];
        titleLab.text=[NSString stringWithFormat:@"失效商品%ld件",self.invaidGoodsArray.count];
        [headerView addSubview:titleLab];
        
        UIButton *clearBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 5, 90, 30)];
        clearBtn.titleLabel.textAlignment=NSTextAlignmentRight;
        clearBtn.titleLabel.font=[UIFont systemFontOfSize:13];
        [clearBtn setTitle:@"清空失效商品" forState:UIControlStateNormal];
        [clearBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
        [clearBtn addTarget:self action:@selector(clearUpAllValidGoods) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:clearBtn];
        
        return headerView;
    }else{
        return nil;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

#pragma mark -- CustomDelegate
#pragma mark GoodsPropertyToolDelegate
#pragma mark 选择商品规格
-(void)goodsPropertyToolDidSeleteContent:(NSInteger)product_id{
    [self requestCartGoodsDetailDataWithProductID:product_id];
}

#pragma mark 选择规格和数量 点击确认按钮
-(void)goodsPropertyToolDidClickButton:(NSString *)btnName withGoodsId:(NSInteger)goods_id OldProductId:(NSInteger)oldProductId newProductId:(NSInteger)newProductId Quantity:(NSInteger)quantity{
    NSString *body=[NSString stringWithFormat:@"old_goods_id=%ld&old_product_id=%ld&num=%ld&type=goods&member_id=%ld&new_goods_id=%ld&new_product_id=%ld",(long)goods_id,(long)oldProductId,(long)quantity,(long)memberId,(long)goods_id,(long)newProductId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:kShopCartUpdate body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        for (CartGoodsModel *model in weakSelf.cartDataArray) {
            if (model.goods_id==goods_id&&model.product_id==oldProductId) {
                model.product_id=newProductId;
                model.quantity=[NSString stringWithFormat:@"%ld",quantity];
                model.spec_info=[result valueForKey:@"spec_info"];
                break;
            }
        }
        [weakSelf.cartTableView reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- NSNotification
-(void)payOrderBackNotify:(NSNotification *)notifi{
    MyLog(@"payOrderBackNotify");
    
    [self requestShopCartData];
}

#pragma mark --Event Response
#pragma mark 编辑
-(void)rightButtonAction{
    if (self.cartDataArray.count==0) {
        return;
    }
    
    isEditing=!isEditing;
    self.rigthTitleName=isEditing?@"完成":@"编辑";
    for (CartGoodsModel *model in self.cartDataArray) {
        model.isEdited=isEditing;
    }
    [self.cartTableView reloadData];
    
    if (isEditing) {
        totalPriceLabel.hidden=balanceBtn.hidden=YES;
        addCollectionBtn.hidden=deleteBtn.hidden=NO;
    }else{
        totalPriceLabel.hidden=balanceBtn.hidden=NO;
        addCollectionBtn.hidden=deleteBtn.hidden=YES;
    }
}

#pragma mark 编辑商品
-(void)editCartGoodsAction:(UIButton *)sender{
    CartGoodsModel *goods=self.cartDataArray[sender.tag];
    
    propertyTool=[[GoodsPropertyTool alloc] initWithHeight:420 btnNames:@[@"确定"] btnColors:@[kSystemColor]];
    propertyTool.quantity=[goods.quantity integerValue];
    propertyTool.delegate=self;
    [propertyTool goodsPropertyToolShow];
    
    [self requestCartGoodsDetailDataWithProductID:goods.product_id];
}

#pragma mark 全选
-(void)selectCartAllGoodsForSender:(UIButton *)sender{
    if (self.cartDataArray.count==0) {
        return;
    }
    
    sender.selected=!sender.selected;
    [self requestForSelectGoodsOrNotWithType:@"all" objIdent:@"" isSelected:sender.selected];
}

#pragma mark 结算
-(void)balanceAccountsForSender:(UIButton *)sender{
    if (selectTotalNum<1) {
        [self.view makeToast:@"请选择商品" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    NSMutableArray *selGoodsArr=[[NSMutableArray alloc] init];
    for (CartGoodsModel *model in self.cartDataArray) {
        if (model.select_status==1) {
            [selGoodsArr addObject:model];
        }
    }
    
    ConfirmOrderViewController *confirmOrderVC=[[ConfirmOrderViewController alloc] init];
    confirmOrderVC.goodsArray=selGoodsArr;
    confirmOrderVC.totalPrice=selectedGoodsPrice;
    confirmOrderVC.isFastBuy=NO;
    [self.navigationController pushViewController:confirmOrderVC animated:YES];
    
}

#pragma mark 移入收藏夹
-(void)addToCollectionForGoods:(UIButton *)sender{
    NSMutableArray *selGoodsArr=[[NSMutableArray alloc] init];
    for (CartGoodsModel *model in self.cartDataArray) {
        if (model.select_status==1) {
            NSDictionary *goodsDict=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:model.goods_id],@"goods_id",[NSNumber numberWithInteger:model.product_id],@"product_id", nil];
            [selGoodsArr addObject:goodsDict];
        }
    }
    
    if (selGoodsArr.count>0) {
        NSString *params=[[NetworkTool sharedNetworkTool] getValueWithParams:selGoodsArr];
        NSString *body=[NSString stringWithFormat:@"member_id=%ld&goodsProduct_id=%@",(long)memberId,params];
        kSelfWeak;
        [[NetworkTool sharedNetworkTool] postShopMethodWithURL:kShopAddToFavorites body:body success:^(id json) {
            NSMutableArray *tempSelGoodsArr=[[NSMutableArray alloc] init];
            for (CartGoodsModel *model in weakSelf.cartDataArray) {
                if (model.select_status==1) {
                    [tempSelGoodsArr addObject:model];
                }
            }
            [weakSelf.cartDataArray removeObjectsInArray:tempSelGoodsArr];
            [weakSelf calculateCartGoodsNumAndPrice];
            [weakSelf.cartTableView reloadData];
            [weakSelf.view makeToast:@"移入收藏夹成功" duration:1.0 position:CSToastPositionCenter];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }else{
        [self.view makeToast:@"请先选择商品" duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark 删除商品
-(void)deleteFromCartForGoods:(UIButton *)sender{
    NSMutableArray *selGoodsArr=[[NSMutableArray alloc] init];
    for (CartGoodsModel *model in self.cartDataArray) {
        if (model.select_status==1) {
            NSString *obj_ident=[NSString stringWithFormat:@"goods_%ld_%ld",(long)model.goods_id,(long)model.product_id];
            [selGoodsArr addObject:obj_ident];
        }
    }
    if (selGoodsArr.count>0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定要删除所选商品吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定"style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
            NSString *params=[[NetworkTool sharedNetworkTool] getValueWithParams:selGoodsArr];
            NSString *body=[NSString stringWithFormat:@"member_id=%ld&obj_ident=%@",(long)memberId,params];
            kSelfWeak;
            [[NetworkTool sharedNetworkTool] postShopMethodWithURL:kShopDeleteGoods body:body success:^(id json) {
                NSMutableArray *tempSelGoodsArr=[[NSMutableArray alloc] init];
                for (CartGoodsModel *model in weakSelf.cartDataArray) {
                    if (model.select_status==1) {
                        [tempSelGoodsArr addObject:model];
                    }
                }
                [weakSelf.cartDataArray removeObjectsInArray:tempSelGoodsArr];
                
                [weakSelf calculateCartGoodsNumAndPrice];
                [weakSelf.cartTableView reloadData];
                [weakSelf.view makeToast:@"所选商品已删除" duration:1.0 position:CSToastPositionCenter];
            } failure:^(NSString *errorStr) {
                [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
        }];
        [sureAction setValue:[UIColor darkGrayColor] forKey:@"_titleTextColor"];
        [alert addAction:sureAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            
        }];
        [cancelAction setValue:kSystemColor forKey:@"_titleTextColor"];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:true completion:nil];
    }else{
        [self.view makeToast:@"请先选择商品" duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark 清除购物车失效商品
-(void)clearUpAllValidGoods{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定要清空失效商品吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定"style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
        NSMutableArray *tempValidArr=[[NSMutableArray alloc] init];
        for (CartGoodsModel *model in self.invaidGoodsArray) {
            NSString *obj_ident=[NSString stringWithFormat:@"goods_%ld_%ld",(long)model.goods_id,(long)model.product_id];
            [tempValidArr addObject:obj_ident];
        }
        NSString *params=[[NetworkTool sharedNetworkTool] getValueWithParams:tempValidArr];
        NSString *body=[NSString stringWithFormat:@"member_id=%ld&obj_ident=%@",(long)memberId,params];
        kSelfWeak;
        [[NetworkTool sharedNetworkTool] postShopMethodWithURL:kShopDeleteGoods body:body success:^(id json) {
            [weakSelf.invaidGoodsArray removeAllObjects];
            [weakSelf.cartTableView reloadData];
            [weakSelf.view makeToast:@"失效商品已清除" duration:1.0 position:CSToastPositionCenter];
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }];
    [sureAction setValue:[UIColor darkGrayColor] forKey:@"_titleTextColor"];
    [alert addAction:sureAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        
    }];
    [cancelAction setValue:kSystemColor forKey:@"_titleTextColor"];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark -- Private Methods
#pragma mark 获取购物车数据
- (void)requestShopCartData{
    NSString *body=[NSString stringWithFormat:@"member_id=%ld",(long)memberId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] getShopMethodWithURL:kShopCartGoodsList body:body isLoading:YES success:^(id json) {
        NSDictionary *cartInfo=[json objectForKey:@"result"];
        if (kIsDictionary(cartInfo)&&cartInfo.count>0) {
            //商品数组
            NSArray *goodsArray=[cartInfo valueForKey:@"goods"];
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            NSMutableArray *tempInvaidArr=[[NSMutableArray alloc] init];
            for (NSDictionary *goodsDict in goodsArray) {
                CartGoodsModel *model=[[CartGoodsModel alloc] init];
                [model setValues:goodsDict];
                if (model.valid==1) {
                    [tempArr addObject:model];
                }else{
                    [tempInvaidArr addObject:model];
                }
            }
            weakSelf.cartDataArray=tempArr;
            weakSelf.invaidGoodsArray=tempInvaidArr;
        }else{
            weakSelf.cartDataArray=[[NSMutableArray alloc] init];
        }
        [weakSelf.cartTableView reloadData];
        [weakSelf calculateCartGoodsNumAndPrice];
        [weakSelf.cartTableView.mj_header endRefreshing];
        
        if ([TJYHelper sharedTJYHelper].isPayOrderBack) {
            [TJYHelper sharedTJYHelper].isPayOrderBack=NO;
            OrderViewController *orderVC=[[OrderViewController alloc] init];
            [self.navigationController pushViewController:orderVC animated:YES];
        }
    } failure:^(NSString *errorStr) {
        weakSelf.cartBlankView.hidden=NO;
        [weakSelf.cartTableView.mj_header endRefreshing];
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 选择商品或取消选择
-(void)requestForSelectGoodsOrNotWithType:(NSString *)selType objIdent:(NSString *)obj_ident isSelected:(BOOL)isSelected{
    NSString *body=[NSString stringWithFormat:@"member_id=%ld&select=%@&obj_ident=%@&type=%ld",(long)memberId,selType,obj_ident,isSelected?(long)1:(long)0];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:kShopCartSelected body:body success:^(id json) {
        if ([selType isEqualToString:@"all"]) {
            for (CartGoodsModel *model in self.cartDataArray) {
                model.select_status=isSelected?1:0;
            }
            if (isSelected) {
                selectedGoodsNum=self.cartDataArray.count;
            }else{
                selectedGoodsNum=0;
            }
        }else{
            for (CartGoodsModel *model in self.cartDataArray) {
                if ([model.obj_ident isEqualToString:obj_ident]) {
                    model.select_status=isSelected?1:0;
                    break;
                }
            }
        }
        [weakSelf.cartTableView reloadData];
        [weakSelf calculateCartGoodsNumAndPrice];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 修改商品数量
-(void)requestForChangeGoodsNumWithGoodsId:(NSInteger)goods_id productId:(NSInteger)product_id quantity:(NSInteger)quantity{
    NSString *body=[NSString stringWithFormat:@"member_id=%ld&goods_id=%ld&product_id=%ld&num=%ld&type=goods",(long)memberId,(long)goods_id,(long)product_id,(long)quantity];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:kShopCartChangeNum body:body success:^(id json) {
        for (CartGoodsModel *model in self.cartDataArray) {
            if (model.goods_id==goods_id&&model.product_id==product_id) {
                model.quantity=[NSString stringWithFormat:@"%ld",(long)quantity];
                break;
            }
        }
        [weakSelf.cartTableView reloadData];
        [weakSelf calculateCartGoodsNumAndPrice];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark 获取商品详情
-(void)requestCartGoodsDetailDataWithProductID:(NSInteger)product_id{
    NSString *body = [NSString stringWithFormat:@"product_id=%ld",(long)product_id];
    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopDetail body:body success:^(id json) {
        NSDictionary *result = [[json objectForKey:@"result"] objectForKey:@"page_product_basic"];
        GoodsModel *model=[[GoodsModel alloc] init];
        [model setValues:result];
        propertyTool.goodsModel=model;
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark 计算数量和金额
- (void)calculateCartGoodsNumAndPrice{
    if (self.cartDataArray.count==0) {
        self.rigthTitleName=@"";

        self.bottomView.hidden=YES;
        if (self.invaidGoodsArray.count==0) {
            self.cartBlankView.hidden=NO;
        }
    }else{
        self.rigthTitleName=isEditing?@"完成":@"编辑";
        self.bottomView.hidden=NO;
        self.cartBlankView.hidden=YES;
        
        selectTotalNum=0;
        selectedGoodsPrice=0.0;
        NSMutableArray *selectedGoodsArr=[[NSMutableArray alloc] init];
        for (CartGoodsModel *model in self.cartDataArray) {
            if (model.select_status==1) {
                selectTotalNum+=[model.quantity integerValue];
                selectedGoodsPrice+=[model.price doubleValue]*[model.quantity integerValue];
                [selectedGoodsArr addObject:model];
            }
        }
        allSelectBtn.selected=selectedGoodsArr.count==self.cartDataArray.count&&self.cartDataArray.count>0;
        
        //总金额
        NSString *tempTotalPriceStr=[NSString stringWithFormat:@"合计：¥%.2f",selectedGoodsPrice];
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:tempTotalPriceStr];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3, attributeStr.length-3)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(3, attributeStr.length-3)];
        totalPriceLabel.attributedText=attributeStr;
        CGFloat labW=[tempTotalPriceStr boundingRectWithSize:CGSizeMake(kScreenWidth-200, 30) withTextFont:totalPriceLabel.font].width;
        totalPriceLabel.frame=CGRectMake(kScreenWidth-100-labW-20, 10, labW+10, 30);
        
        //总数量
        [balanceBtn setTitle:[NSString stringWithFormat:@"结算(%ld)",selectTotalNum] forState:UIControlStateNormal];
    }
}

#pragma mark -- Getters and Setters
#pragma mark 空白页
-(UIView *)cartBlankView{
    if (!_cartBlankView) {
        _cartBlankView=[[UIView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, 300)];
        
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-118)/2, 64, 118, 62)];
        imgView.image=[UIImage imageNamed:@"pd_ic_car_none"];
        [_cartBlankView addSubview:imgView];
        
        UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(30, imgView.bottom+32, kScreenWidth-60, 30)];
        titleLab.textAlignment=NSTextAlignmentCenter;
        titleLab.text=@"您的购物车是空的哦";
        titleLab.textColor=[UIColor colorWithHexString:@"#999999"];
        titleLab.font=[UIFont systemFontOfSize:13];
        [_cartBlankView addSubview:titleLab];
        
        UILabel  *detailLab=[[UILabel alloc] initWithFrame:CGRectMake(30, titleLab.bottom, kScreenWidth-60, 20)];
        detailLab.textAlignment=NSTextAlignmentCenter;
        detailLab.font=[UIFont systemFontOfSize:13];
        detailLab.textColor=[UIColor colorWithHexString:@"#999999"];
        detailLab.text=@"去挑选几件喜欢的商品吧";
        [_cartBlankView addSubview:detailLab];
        
    }
    return _cartBlankView;
}

#pragma mark 购物车列表视图
-(UITableView *)cartTableView{
    if (!_cartTableView) {
        _cartTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kBodyHeight-50) style:UITableViewStyleGrouped];
        _cartTableView.backgroundColor=[UIColor bgColor_Gray];
        _cartTableView.dataSource=self;
        _cartTableView.delegate=self;
        _cartTableView.tableFooterView=[[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestShopCartData)];
        header.automaticallyChangeAlpha=YES;     // 设置自动切换透明度(在导航栏下面自动隐藏)
        _cartTableView.mj_header=header;
        
    }
    return _cartTableView;
}

#pragma mark 底部视图
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _bottomView.backgroundColor=[UIColor whiteColor];
        
        allSelectBtn=[[UIButton alloc] initWithFrame:CGRectMake(10, 10, 80, 30)];
        [allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
        [allSelectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [allSelectBtn setImage:[UIImage imageNamed:@"pd_ic_pick_un"] forState:UIControlStateNormal];
        [allSelectBtn setImage:[UIImage imageNamed:@"pd_ic_pick_on"] forState:UIControlStateSelected];
        allSelectBtn.imageEdgeInsets=UIEdgeInsetsMake(0, -10, 0, 0);
        [allSelectBtn addTarget:self action:@selector(selectCartAllGoodsForSender:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:allSelectBtn];
        
        totalPriceLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        totalPriceLabel.font=[UIFont systemFontOfSize:12];
        totalPriceLabel.textColor=[UIColor lightGrayColor];
        NSString *tempStr=@"合计：¥0.00";
        NSMutableAttributedString *attributeStr=[[NSMutableAttributedString alloc] initWithString:tempStr];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3, attributeStr.length-3)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(3, attributeStr.length-3)];
        totalPriceLabel.attributedText=attributeStr;
        CGFloat labW=[tempStr boundingRectWithSize:CGSizeMake(kScreenWidth-200, 30) withTextFont:totalPriceLabel.font].width;
        totalPriceLabel.frame=CGRectMake(kScreenWidth-100-labW-20, 10, labW+10, 30);
        [_bottomView addSubview:totalPriceLabel];
        
        balanceBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 0, 100, 50)];
        balanceBtn.backgroundColor=kSystemColor;
        [balanceBtn setTitle:@"结算(0)" forState:UIControlStateNormal];
        [balanceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [balanceBtn addTarget:self action:@selector(balanceAccountsForSender:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:balanceBtn];
        
        addCollectionBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-180, 10, 100, 30)];
        [addCollectionBtn setTitle:@"移入收藏夹" forState:UIControlStateNormal];
        [addCollectionBtn setTitleColor:[UIColor colorWithHexString:@"#626262"] forState:UIControlStateNormal];
        addCollectionBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        addCollectionBtn.layer.borderWidth=1;
        addCollectionBtn.layer.cornerRadius=3;
        addCollectionBtn.layer.borderColor=[UIColor colorWithHexString:@"#626262"].CGColor;
        addCollectionBtn.clipsToBounds=YES;
        [addCollectionBtn addTarget:self action:@selector(addToCollectionForGoods:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:addCollectionBtn];
        addCollectionBtn.hidden=YES;
        
        deleteBtn=[[UIButton alloc] initWithFrame:CGRectMake(addCollectionBtn.right+10, 10, 60, 30)];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        deleteBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        deleteBtn.layer.borderWidth=1;
        deleteBtn.layer.cornerRadius=3;
        deleteBtn.layer.borderColor=[UIColor redColor].CGColor;
        deleteBtn.clipsToBounds=YES;
        [deleteBtn addTarget:self action:@selector(deleteFromCartForGoods:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:deleteBtn];
        deleteBtn.hidden=YES;
        
    }
    return _bottomView;
}

#pragma mark 商品列表数据
-(NSMutableArray *)cartDataArray{
    if (!_cartDataArray) {
        _cartDataArray=[[NSMutableArray alloc] init];
    }
    return _cartDataArray;
}

#pragma mark 失效商品数组
-(NSMutableArray *)invaidGoodsArray{
    if (!_invaidGoodsArray) {
        _invaidGoodsArray=[[NSMutableArray alloc] init];
    }
    return _invaidGoodsArray;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kPayOrderBackAction" object:nil];
}

@end
