//
//  ShopDetailViewController.m
//  Product
//
//  Created by 肖栋 on 17/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopDetailViewController.h"
#import "TCServiceClickViewGroup.h"
#import "ShopDetailToolBar.h"
#import "SDCycleScrollView.h"
#import "ShopDetailTableViewCell.h"
#import "GoodsModel.h"
#import "ShopDetailContentTableViewCell.h"
#import "GoodsParameterTool.h"
#import "GoodsPropertyTool.h"
#import "ShopCartViewController.h"
#import "OnlineServiceViewController.h"
#import "PPBadgeView.h"
#import "ConfirmOrderViewController.h"
#import "CartGoodsModel.h"

@interface ShopDetailViewController ()<UITableViewDelegate,UITableViewDataSource,ServiceViewGroupDelegate,ShopDetailToolBarDelegate,SDCycleScrollViewDelegate,UIScrollViewDelegate,GoodsPropertyToolDelegate,UIWebViewDelegate>{

    UIView        *navView;
    UIButton      *careButton;
    
    GoodsModel    *goodDtailModel;
    NSInteger       num;
    NSInteger       selectIndex;
    GoodsPropertyTool *goodsPropertyTool;
    
    NSInteger       seleteSlid;
}
@property (nonatomic ,strong)UITableView *shopDetailTab;

@property (nonatomic ,strong)TCServiceClickViewGroup *shopDetailClick;

@property (nonatomic ,strong)ShopDetailToolBar *shopToolBar;
/// banner 视图
@property (nonatomic ,strong)SDCycleScrollView  *cycleScrollView;

@property (nonatomic ,strong)UIWebView *rootWebView;
/// 消息图标
@property (nonatomic ,strong) PPBadgeLabel     *messageNumLab;

@property (nonatomic ,strong)UILabel  *porpmtLabel;
/// 返回顶部按钮
@property (nonatomic ,strong) UIButton     *backTopButton;

@property (nonatomic ,strong) UILabel   *mj_headLabel;
@end

@implementation ShopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    self.view.backgroundColor = [UIColor bgColor_Gray];
    selectIndex = 0;
    
    [self initShopDetailView];
    [self loadShopDetailData:self.product_id type:1];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if (kIsLogined) {
        [self loadCartShopDetailNum];
    } else {
        self.messageNumLab.hidden = YES;
    }
}
#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return num;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (section==1) {
        if (goodDtailModel.spec.count>0&&goodDtailModel.params.count>0) {
            return 2;
        }else if (goodDtailModel.spec.count>0&&goodDtailModel.params.count==0){
            return 1;
        }else if (goodDtailModel.spec.count==0&&goodDtailModel.params.count>0){
            return 1;
        }else if (goodDtailModel.brief.length>0){
            return 1;
        }else{
            return 0;
        }
    }else if (section==2){
        if (goodDtailModel.brief.length>0) {
            return 1;
        }else{
            return 0;
        }
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        static NSString *identify = @"ShopDetailTableViewCell";
        ShopDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (cell==nil) {
            cell = [[ShopDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType=UITableViewCellAccessoryNone;
        [cell cellShopDetailModel:goodDtailModel];
        return cell;
    }else{
        if ((goodDtailModel.spec.count>0||goodDtailModel.params.count>0)&&indexPath.section==1) {
            static NSString *identify = @"ShopDetailTableViewCell";
            ShopDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if (cell==nil) {
                cell = [[ShopDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            [cell cellShopParameterModel:goodDtailModel row:indexPath.row];
            return cell;
            
        } else {
            static NSString *identify = @"ShopDetailContentTableViewCell";
            ShopDetailContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if (cell==nil) {
                cell = [[ShopDetailContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType=UITableViewCellAccessoryNone;
            [cell cellShopDetailContentModel:goodDtailModel];
            return cell;

        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        if (goodDtailModel.spec.count>0||goodDtailModel.params.count>0) {
            if ((goodDtailModel.spec.count>0&&goodDtailModel.params.count>0&&indexPath.row==0)||(goodDtailModel.spec.count==0&&goodDtailModel.params.count>0)) {
                GoodsParameterTool *tool=[[GoodsParameterTool alloc] initWithHeight:400 goodsParameter:goodDtailModel];
                [tool goodsParameterToolShow];
            }else{
                goodsPropertyTool=[[GoodsPropertyTool alloc] initWithHeight:420 btnNames:@[@"加入购物车",@"立即购买"] btnColors:@[UIColorHex(0x4da6fe),UIColorHex(0xf39800)]];
                goodsPropertyTool.goodsModel=goodDtailModel;
                goodsPropertyTool.delegate=self;
                goodsPropertyTool.quantity=1;
                [goodsPropertyTool goodsPropertyToolShow];
            
            }
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 94;
    }else if (indexPath.section==1){
        
        if (goodDtailModel.spec.count>0||goodDtailModel.params.count>0) {
            return 50;
        }else if (goodDtailModel.brief.length>0){
            CGSize size = [goodDtailModel.brief sizeWithLabelWidth:kScreenWidth-36 font:[UIFont systemFontOfSize:14]];
            return size.height+70;
        }else{
            return 0.01;
        }
    }else{
        CGSize size = [goodDtailModel.brief sizeWithLabelWidth:kScreenWidth-36 font:[UIFont systemFontOfSize:14]];
        return size.height+70;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    if (section==0&&(goodDtailModel.spec.count>0||goodDtailModel.params.count>0)) {
        return 10;
    }
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    footView.backgroundColor = [UIColor bgColor_Gray];
    return footView;
}
#pragma mark --UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView==self.rootWebView.scrollView) {
        if (scrollView.contentOffset.y<-44) {
            seleteSlid = 1;
            [self ServiceViewGroupActionWithIndex:0];
        }
    } else {
        if (scrollView.contentOffset.y>scrollView.contentSize.height-self.shopDetailTab.height+20) {
            seleteSlid = 1;
            [self ServiceViewGroupActionWithIndex:1];
        }
    }

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView== self.rootWebView.scrollView) {
        if (scrollView.contentOffset.y<0) {
            self.mj_headLabel.frame = CGRectMake(0, 30-scrollView.contentOffset.y, kScreenWidth, 20);
        }
        if (scrollView.contentOffset.y>self.rootWebView.height-64) {
            self.backTopButton.hidden = NO;
        }else{
            self.backTopButton.hidden = YES;
        }
    }
}
#pragma mark -- SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index{

    self.porpmtLabel.text = [NSString stringWithFormat:@"%ld/%ld",index+1,self.cycleScrollView.imageURLStringsGroup.count];
}
#pragma mark -- UIWebViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView{
    [SVProgressHUD show];
    MyLog(@"webViewDidStartLoad");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *jsMeta = [NSString stringWithFormat:@"var meta = document.createElement('meta');meta.content='width=device-width,initial-scale=1.0,minimum-scale=.5,maximum-scale=3';meta.name='viewport';document.getElementsByTagName('head')[0].appendChild(meta);"];
    
    [self.rootWebView stringByEvaluatingJavaScriptFromString:jsMeta];
    [SVProgressHUD dismiss];
    MyLog(@"webViewDidFinishLoad");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [SVProgressHUD dismiss];
    MyLog(@"didFailLoadWithError:%@",error.localizedDescription);
}


#pragma mark -- ServiceViewGroupDelegate
-(void)ServiceViewGroupActionWithIndex:(NSUInteger)index{
    selectIndex = index;
    UIButton *btn;
    for (UIView *view in self.shopDetailClick.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&(view.tag == index+100)) {
            btn = (UIButton*)view;
        }
    }
    if (index==0) {
        if (seleteSlid==1) {
            [UIView animateWithDuration:0.5 animations:^{
                self.rootWebView.frame =CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight-kTabbarHeight-kNewNavHeight);
                self.shopDetailTab.frame =CGRectMake(0, 64, kScreenWidth, kScreenHeight-kTabbarHeight-kNewNavHeight);
            }];
            seleteSlid = 0;
        }else{
            self.backTopButton.hidden = YES;
            self.rootWebView.frame =CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight-kTabbarHeight-kNewNavHeight);
            self.shopDetailTab.frame =CGRectMake(0, 64, kScreenWidth, kScreenHeight-kTabbarHeight-kNewNavHeight);
        }
    } else {
        [self requestShopDetailWebView];
        if (seleteSlid==1) {
            [UIView animateWithDuration:0.5 animations:^{
                self.rootWebView.frame =CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight-kTabbarHeight-kNewNavHeight);
                self.shopDetailTab.frame =CGRectMake(0, -kScreenHeight, kScreenWidth, kScreenHeight-kTabbarHeight-kNewNavHeight);
            }];
            seleteSlid = 0;
        }else{
            self.rootWebView.frame =CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight-kTabbarHeight-kNewNavHeight);
            self.shopDetailTab.frame =CGRectMake(0, -kScreenHeight, kScreenHeight, kScreenHeight-kTabbarHeight-kNewNavHeight);
        }
    }
    [self.shopDetailClick serviceBgChangeViewWithButton:btn];
}
#pragma mark -- GoodsPropertyToolDelegate
- (void)goodsPropertyToolDidClickButton:(NSString *)btnName withGoodsId:(NSInteger)goods_id OldProductId:(NSInteger)oldProductId newProductId:(NSInteger)newProductId Quantity:(NSInteger)quantity{
    goodDtailModel.quantity = quantity;
    if (kIsLogined) {
        if ([btnName isEqualToString:@"立即购买"]) {
            [self shopBuyNow];

        } else {
            
            [self addShopCart:quantity];
        }
    }else{
        [self pushToFastLogin];
    }
}

- (void)goodsPropertyToolDidSeleteContent:(NSInteger)product_id{

    [self loadShopDetailData:product_id type:2];
}
#pragma mark -- ShopDetailToolBarDelegate
#pragma mark -- 客服／购物车／加入购物车／立即购买
- (void)shopDetailToolBarSelete:(NSInteger)index{
    if (index==0) {
        OnlineServiceViewController *onlineServiceVC=[[OnlineServiceViewController alloc] init];
        [self.navigationController pushViewController:onlineServiceVC animated:YES];
    }else{
        if (kIsLogined) {
            if (index==1){
                ShopCartViewController *shopCartVC = [[ShopCartViewController alloc] init];
                [self.navigationController pushViewController:shopCartVC animated:YES];
            }else if (index==2){
                [self addShopCart:1];
            }else{
                [self shopBuyNow];
            }
        }else{
            [self pushToFastLogin];
        }
    }
}
#pragma mark -- Event response
#pragma mark -- 立即购买
- (void)shopBuyNow{
    NSString *user_id = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *body = [NSString stringWithFormat:@"member_id=%@&btype=is_fastbuy&goods_id=%ld&product_id=%ld&num=%ld",user_id,(long)goodDtailModel.goods_id,goodDtailModel.product_id,goodDtailModel.quantity];
    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopQuickBuy body:body success:^(id json) {
        
        CartGoodsModel *cartModel = [[CartGoodsModel alloc] init];
        if (kIsDictionary(goodDtailModel.image_default)) {
            cartModel.image_default_id = [goodDtailModel.image_default objectForKey:@"image_id"];
            cartModel.url = [goodDtailModel.image_default objectForKey:@"s_url"];
        }
        NSMutableArray *detailArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in goodDtailModel.spec) {
            NSArray *type_info = [dict objectForKey:@"type_info"];
            for (NSDictionary *type_dict in type_info) {
                if ([[type_dict objectForKey:@"product_id"] integerValue]>0) {
                }else{
                    [detailArr addObject:[type_dict objectForKey:@"spec_value"]];
                }
            }
        }
        cartModel.name = goodDtailModel.title;
        cartModel.brief = goodDtailModel.brief;
        cartModel.spec_info = [detailArr componentsJoinedByString:@"／"];
        cartModel.mktprice = goodDtailModel.mktprice;
        cartModel.quantity = [NSString stringWithFormat:@"%ld",goodDtailModel.quantity];
        cartModel.product_id = goodDtailModel.product_id;
        cartModel.goods_id = goodDtailModel.goods_id;
        cartModel.price = goodDtailModel.price;
        cartModel.store = goodDtailModel.store;
        
        
        NSMutableArray *cartGoodArr = [[NSMutableArray alloc] init];
        [cartGoodArr addObject:cartModel];
        ConfirmOrderViewController *confirmOrderVC = [[ConfirmOrderViewController alloc] init];
        confirmOrderVC.totalPrice = goodDtailModel.quantity*[goodDtailModel.price doubleValue];
        confirmOrderVC.goodsArray = cartGoodArr;
        confirmOrderVC.isFastBuy=YES;
        [self.navigationController pushViewController:confirmOrderVC animated:YES];
        
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 获取商品详情数据
- (void)loadShopDetailData:(NSInteger)product_id type:(NSInteger)type{
    NSString *user_id = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *body = [NSString stringWithFormat:@"member_id=%@&product_id=%ld",user_id,product_id];
    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopDetail body:body success:^(id json) {
        NSDictionary *result = [[json objectForKey:@"result"] objectForKey:@"page_product_basic"];
        if (kIsDictionary(result)) {
            goodDtailModel = [[GoodsModel alloc] init];
            goodDtailModel.quantity = 1;
            [goodDtailModel setValues:result];
            if (kIsArray(goodDtailModel.images)&&goodDtailModel.images.count>0) {
                NSMutableArray *imgArr = [[NSMutableArray alloc] init];
                for (NSDictionary *imgDict in goodDtailModel.images) {
                    NSString *imgUrl = [NSString stringWithFormat:@"%@",[imgDict objectForKey:@"url"]];
                    [imgArr addObject:imgUrl];
                }
                self.cycleScrollView.imageURLStringsGroup = imgArr;
                self.porpmtLabel.hidden = imgArr.count<=1;
                self.porpmtLabel.text =[NSString stringWithFormat:@"1/%ld",imgArr.count];

            }
            [careButton setImage:[UIImage imageNamed:goodDtailModel.is_favorite==0?@"ic_top_collect_un":@"ic_top_collect_on"] forState:UIControlStateNormal];
            num = 1;
            if (goodDtailModel.spec.count>0||goodDtailModel.params.count>0) {
                num = num+1;
            }
            if (goodDtailModel.brief.length>0) {
                num = num +1;
            }
        }
        if (type==2) {
            goodsPropertyTool.goodsModel = goodDtailModel;
        }
        [self.shopDetailTab reloadData];
        _shopDetailTab.tableFooterView = [self setFootView];
        _shopDetailTab.tableHeaderView = [self setHeadView];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 加入购物车
- (void)addShopCart:(NSInteger)shop_num{
    NSString *user_id = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *body = [NSString stringWithFormat:@"member_id=%@&goods_id=%ld&product_id=%ld&num=%ld",user_id,goodDtailModel.goods_id,goodDtailModel.product_id,shop_num];
    [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopAddCart body:body success:^(id json) {
        [self loadCartShopDetailNum];

        UIImageView *shopImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
        shopImgView.backgroundColor = [UIColor bgColor_Gray];
        if (kIsDictionary(goodDtailModel.image_default)) {
            [shopImgView sd_setImageWithURL:[NSURL URLWithString:[goodDtailModel.image_default objectForKey:@"s_url"]] placeholderImage:[UIImage imageNamed:@"pd_img_nor"]];
        } else {
            shopImgView.image = [UIImage imageNamed:@"pd_img_nor"];
        }
        [self.view addSubview:shopImgView];
        [UIView animateWithDuration:0.5 animations:^{
            
            shopImgView.frame = CGRectMake(kScreenWidth/10*3, kScreenHeight-45, 20, 20);

        } completion:^(BOOL finished) {
            [shopImgView removeFromSuperview];
            
            UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
            alertView.backgroundColor =  [[UIColor blackColor] colorWithAlphaComponent:0.8];
            alertView.layer.cornerRadius = 10;
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((150-30)/2, 15, 30, 30)];
            imgView.image = [UIImage imageNamed:@"pd_ic_add_finish"];
            [alertView addSubview:imgView];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom+10, 150, 20)];
            titleLabel.text = @"成功添加到购物车";
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            [alertView addSubview:titleLabel];
            
            [self.view showToast:alertView duration:1.0 position:CSToastPositionCenter];
        }];
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- 获取购物车商品数量
- (void)loadCartShopDetailNum{
    NSString *user_id = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *body=[NSString stringWithFormat:@"member_id=%@",user_id];
    
    [[NetworkTool sharedNetworkTool] getShopMethodWithURL:kShopCartGoodsList body:body isLoading:NO success:^(id json) {
        NSDictionary *cartInfo=[json objectForKey:@"result"];
        if (kIsDictionary(cartInfo)) {
            self.messageNumLab.hidden = [[cartInfo objectForKey:@"total_num"] integerValue]>0?NO:YES;
            self.messageNumLab.text =[[cartInfo objectForKey:@"total_num"] integerValue]>99?@"99+":[NSString stringWithFormat:@"%ld",[[cartInfo objectForKey:@"total_num"] integerValue]];
        }else{
            self.messageNumLab.hidden = YES;
        }
    } failure:^(NSString *errorStr) {
        
    }];
}
#pragma mark -- 收藏
- (void)rightButtonAction{
    if (kIsLogined) {
        NSString *user_id = [NSUserDefaultInfos getValueforKey:USER_ID];
        NSString *body = [NSString stringWithFormat:@"member_id=%@&goods_id=%ld",user_id,goodDtailModel.goods_id];
        [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopCollection body:body success:^(id json) {
            
            [self.view makeToast:[[json objectForKey:@"is_favorite"] integerValue]==0?@"已取消收藏":@"收藏成功" duration:1.0 position:CSToastPositionCenter];
            [careButton setImage:[UIImage imageNamed:[[json objectForKey:@"is_favorite"] integerValue]==0?@"ic_top_collect_un":@"ic_top_collect_on"] forState:UIControlStateNormal];
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    } else {
        [self pushToFastLogin];
    }
}

#pragma mark -- 返回顶部
- (void)backButton{

    [self.rootWebView.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
#pragma mark -- 加载商品详情
-(void)requestShopDetailWebView{
    
    [self.rootWebView loadHTMLString:goodDtailModel.intro baseURL:nil];
}
#pragma mark -- 左右侧滑
-(void)swipShopDetailTableView:(UISwipeGestureRecognizer *)gesture{
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft) {
        if (selectIndex==0) {
            selectIndex = selectIndex +1;
        }
    }else if (gesture.direction==UISwipeGestureRecognizerDirectionRight){
        if (selectIndex==1) {
            selectIndex = selectIndex - 1;
        }
    }
    [self ServiceViewGroupActionWithIndex:selectIndex];
}
#pragma mark -- private Methons
#pragma mark -- 初始化商品详情界面
- (void)initShopDetailView{
    [self.view addSubview:self.shopDetailTab];
    [self.view addSubview:self.rootWebView];
    [self.view addSubview:self.shopToolBar];
    [self setNavView];

    [self.view addSubview:self.backTopButton];
    
    UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipShopDetailTableView:)];
    swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipGestureLeft];
    
    UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipShopDetailTableView:)];
    swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipGestureRight];
}
#pragma mark -- 导航栏
- (void)setNavView{
    [self.view addSubview:self.mj_headLabel];
    
    navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNewNavHeight)];
    navView.backgroundColor = kSystemColor;
    [self.view addSubview:navView];
    
    UIButton *backBtn=[[UIButton alloc] initWithFrame:CGRectMake(5, 22, 40, 40)];
    [backBtn setImage:[UIImage drawImageWithName:@"back.png" size:CGSizeMake(12, 19)] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
    [backBtn addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    NSArray *titleArr = @[@"简介",@"详情"];
    self.shopDetailClick = [[TCServiceClickViewGroup alloc] initWithFrame:CGRectMake((kScreenWidth-100)/2, 20, 100, 44) titles:titleArr color:[UIColor whiteColor]];
    self.shopDetailClick.serviceDelegate = self;
    self.shopDetailClick.backgroundColor = kSystemColor;
    [self.view addSubview:self.shopDetailClick];
    
    careButton=[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH- 45, 22, 45, 40)];
    [careButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:careButton];
}
#pragma mark -- 轮播图
- (UIView *)setHeadView{
    UIView *headTabView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    headTabView.backgroundColor = kBackgroundColor;
    
    [headTabView addSubview:self.cycleScrollView];
    return headTabView;
}
- (UIView *)setFootView{

    UIView *footTabView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    footTabView.backgroundColor = [UIColor bgColor_Gray];
    
    UILabel *porpmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 20)];
    porpmtLabel.text = @"↑ 继续上拉，查看图文详情";
    porpmtLabel.textAlignment = NSTextAlignmentCenter;
    porpmtLabel.textColor = [UIColor lightGrayColor];
    porpmtLabel.font = [UIFont systemFontOfSize:15];
    [footTabView addSubview:porpmtLabel];
    
    return footTabView;
}
#pragma mark -- setter or getter
- (UITableView *)shopDetailTab{
    if (_shopDetailTab==nil) {
        _shopDetailTab = [[UITableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kScreenHeight-kTabbarHeight-kNewNavHeight) style:UITableViewStylePlain];
        _shopDetailTab.backgroundColor = [UIColor bgColor_Gray];
        _shopDetailTab.delegate = self;
        _shopDetailTab.dataSource = self;
        _shopDetailTab.tableFooterView = [[UIView alloc] init];
    }
    return _shopDetailTab;
}
- (UIWebView *)rootWebView{
    if (_rootWebView==nil) {
        _rootWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight-kTabbarHeight-kNewNavHeight)];
        _rootWebView.delegate=self;
        _rootWebView.backgroundColor=[UIColor bgColor_Gray];
        _rootWebView.scrollView.delegate = self;
        _rootWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _rootWebView.scalesPageToFit=YES;
        _rootWebView.multipleTouchEnabled=YES;
        _rootWebView.userInteractionEnabled=YES;
    }
    return _rootWebView;
}
- (UILabel *)mj_headLabel{
    if (_mj_headLabel==nil) {
        
        _mj_headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, kScreenWidth, 20)];
        _mj_headLabel.backgroundColor = [UIColor bgColor_Gray];
        _mj_headLabel.text = @"↓ 继续下拉，返回商品简介";
        _mj_headLabel.textAlignment = NSTextAlignmentCenter;
        _mj_headLabel.textColor = [UIColor lightGrayColor];
        _mj_headLabel.font = [UIFont systemFontOfSize:15];
    }
    return _mj_headLabel;
}
- (ShopDetailToolBar *)shopToolBar{
    if (_shopToolBar==nil) {
        _shopToolBar = [[ShopDetailToolBar alloc] initWithFrame:CGRectMake(0, kScreenHeight-49, kScreenWidth, 49)];
        _shopToolBar.shopToolBaDelegate = self;
        
        [_shopToolBar addSubview:self.messageNumLab];
    }
    return _shopToolBar;
}
#pragma mark -- 轮播图
-(SDCycleScrollView *)cycleScrollView{
    if (_cycleScrollView==nil) {
        _cycleScrollView=[SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth) delegate:self placeholderImage:[UIImage imageNamed:@"pd_img_nor"]];
        _cycleScrollView.autoScrollTimeInterval = 4;
        _cycleScrollView.showPageControl = NO;
        
        _porpmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(_cycleScrollView.right-65, _cycleScrollView.bottom-45, 40, 20)];
        _porpmtLabel.textColor = [UIColor whiteColor];
        _porpmtLabel.backgroundColor = [UIColor grayColor];
        _porpmtLabel.font = [UIFont systemFontOfSize:12];
        _porpmtLabel.textAlignment = NSTextAlignmentCenter;
        _porpmtLabel.layer.cornerRadius = 10;
        _porpmtLabel.clipsToBounds = YES;
        _porpmtLabel.hidden = YES;
        [_cycleScrollView addSubview:_porpmtLabel];
    }
    return _cycleScrollView;
}

#pragma mark ====== 消息图标 =======
- (UILabel *)messageNumLab{
    if (!_messageNumLab) {
        _messageNumLab = [[PPBadgeLabel alloc]initWithFrame:CGRectMake( kScreenWidth/5+kScreenWidth/10+5, 2, 16, 16)];
        _messageNumLab.backgroundColor = [UIColor redColor];
        _messageNumLab.hidden = YES;
    }
    return _messageNumLab;
}
#pragma mark -- 返回顶部
- (UIButton *)backTopButton{
    if (!_backTopButton) {
        _backTopButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-60, kScreenHeight-120, 40, 40)];
        _backTopButton.clipsToBounds =YES;
        _backTopButton.layer.cornerRadius = 20;
        [_backTopButton setImage:[UIImage imageNamed:@"pub_ic_backtotop"] forState:UIControlStateNormal];
        [_backTopButton addTarget:self action:@selector(backButton) forControlEvents:UIControlEventTouchUpInside];
        _backTopButton.hidden = YES;
    }

    return _backTopButton;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
