//
//  MineViewController.m
//  Product
//
//  Created by vision on 16/12/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "MineViewController.h"
#import "Product-Swift.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>
#import "TJYUserInfoViewController.h"
#import "ActionSheetView.h"
#import "OrderGroupView.h"
#import "OrderViewController.h"
#import "BaseNavigationController.h"
#import "TCFastLoginViewController.h"
#import "OrderCountMode.h"

#define kImageViewHeight 160

@interface MineViewController()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIGestureRecognizerDelegate,OrderGroupViewDelegate>{
    
    UIImageView           *_headImageView;
    UILabel               *_nickNameLabel;
    UILabel               *_IDLabel;
    
    NSArray               *_titleArray;
    NSArray               *_imagesArray;
    NSArray               *_classNames;
}

@property (nonatomic,strong)UITableView        *menuTableView;
@property (nonatomic,strong)UIImageView        *zoomImageView;
@property (nonatomic,strong)UIView             *userInfoView;
@property (nonatomic,strong)UIView             *loginView;
@property (nonatomic,strong)OrderGroupView     *groupView;
/// 订单数据
@property (nonatomic ,strong) NSMutableArray *orderNumArr;
@end


@implementation MineViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle=@"我的";
    
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    _titleArray=@[@[@"我的订单",@"全部"],@[@"收货地址管理"],@[@"我的收藏",@"消息中心"],@[@"分享好友",@"设置"]];
    _imagesArray=@[@[@"ic_m_order",@"ic_m_collect"],@[@"ic_m_address"],@[@"ic_m_collect",@"ic_m_msg"],@[@"ic_m_share",@"ic_m_setting"]];
    _classNames=@[@[@"AddressManager"],@[@"MyCollection",@"MessageClassification"],@[@"",@"Set"]];

    [self initMineView];
    
    [self getUserInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([TJYHelper sharedTJYHelper].isReloadUserInfo) {
        [self getUserInfo];
        [TJYHelper sharedTJYHelper].isReloadUserInfo=NO;
    }
    if (kIsLogined) {
        [self requestOrderCount];
    }else{
        NSArray *orderNumArr= @[@"0",@"0",@"0",@"0"];
        self.groupView.orderNumArr = orderNumArr;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003" type:2];
#endif
}

#pragma mark --response
-(void)gettoUserInfoVC{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-02"];
#endif
    
    TJYUserInfoViewController *controller=[[TJYUserInfoViewController alloc] init];
    controller.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)tologinAction{
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-01"];
#endif
    [self pushToFastLogin];
}

#pragma mark --UITableViewDelegate and UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _titleArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_titleArray[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"mineCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.imageView.image=[UIImage imageNamed:_imagesArray[indexPath.section][indexPath.row]];
            cell.textLabel.text=@"我的订单";
            cell.detailTextLabel.text=@"查看全部订单";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.separatorInset = UIEdgeInsetsMake(0, 22, 0, 0);
        }else{
            cell.accessoryType=UITableViewCellAccessoryNone;
            [cell.contentView addSubview:self.groupView];
        }
    }else{
        cell.imageView.image=[UIImage imageNamed:_imagesArray[indexPath.section][indexPath.row]];
        cell.textLabel.text=_titleArray[indexPath.section][indexPath.row];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.separatorInset = UIEdgeInsetsMake(0, 22, 0,0);
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (kIsLogined) {
            OrderViewController *orderVC=[[OrderViewController alloc] init];
            orderVC.indexStatu = 0;
            orderVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:orderVC animated:YES];
        }else{
            [self pushToFastLogin];
        }
    }else if (indexPath.section==1){
        if (kIsLogined) {
            NSString *className=[_classNames[0][indexPath.row] stringByAppendingString:@"ViewController"];
            Class aClass=NSClassFromString(className);
            BaseViewController *controller=(BaseViewController *)[[aClass alloc] init];
            controller.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            [self pushToFastLogin];
        }
    }else if (indexPath.section == 2){
        if (kIsLogined) {
            NSString *className=[_classNames[1][indexPath.row] stringByAppendingString:@"ViewController"];
            Class aClass=NSClassFromString(className);
            BaseViewController *controller=(BaseViewController *)[[aClass alloc] init];
            controller.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:controller animated:YES];
            
            if (indexPath.row==1) {
#if !DEBUG
                [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-03"];
#endif
            }
        }else{
            [self pushToFastLogin];
        }
    }else{
        if (indexPath.row==0) {
            [self sharefriend];
        }else{
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-05"];
#endif
            NSString *className=[_classNames[2][indexPath.row] stringByAppendingString:@"ViewController"];
            Class aClass=NSClassFromString(className);
            BaseViewController *controller=(BaseViewController *)[[aClass alloc] init];
            controller.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            return 44;
        }else{
            return 65;
        }
    }
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headSectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    headSectionView.backgroundColor = [UIColor bgColor_Gray];
    return headSectionView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerSectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    footerSectionView.backgroundColor = [UIColor bgColor_Gray];
    return footerSectionView;
}

#pragma mark -- Custom Delegate
#pragma mark OrderGroupViewDelegate
-(void)orderGroupViewBtnActionWithIndex:(NSInteger)index{
    if (kIsLogined) {
        OrderViewController *orderVC=[[OrderViewController alloc] init];
        orderVC.indexStatu = index+1;
        orderVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:orderVC animated:YES];
    }else{
        [self pushToFastLogin];
    }
}
#pragma mark -- 分享好友
- (void)sharefriend{
    NSArray *titlearr = @[@"微信好友",@"微信朋友圈",@"QQ",@"QQ空间",@"新浪微博",@""];
    NSArray *imageArr = @[@"ic_pub_share_wx",@"ic_pub_share_pyq",@"ic_pub_share_qq",@"ic_pub_share_qzone",@"ic_pub_share_wb",@""];
    
    ActionSheetView *actionsheet = [[ActionSheetView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andProTitle:@"测试" and:ShowTypeIsShareStyle];
    [actionsheet setBtnClick:^(NSInteger btnTag) {
       
#if !DEBUG
        NSArray *wayArr = @[@"2",@"3",@"5",@"1",@"4"];
        [[NetworkTool sharedNetworkTool] shareEventWithTargetID:0 way:[wayArr[btnTag] integerValue] type:0 name:@"下载天际云健康"];
#endif
        if (btnTag==0||btnTag==1||btnTag==2||btnTag==3) {
            //分享代码
            [self shareWeixin:btnTag];
            
        }else if (btnTag==4){
            [self shareSina];
        }else{
            
        }
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:actionsheet];

}

#pragma mark -- 分享微信／qq
- (void)shareWeixin:(NSInteger)index{
    
    NSString *shareUrl=@"http://www.360tj.com/downloads/360tj-app.html";
    NSArray* imageArray = @[[UIImage imageNamed:@"ic_logo_share"]];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if (imageArray) {
        [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"健康饮食，一起享受智能化生活"]
                                         images:imageArray
                                            url:[NSURL URLWithString:shareUrl]
                                          title:@"下载天际云健康"
                                           type:SSDKContentTypeAuto];
    }
    [shareParams SSDKEnableUseClientShare];
    if (index==0) {
        [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            [self shareSuccessorError:state];
        }];
        
    }else if (index==1){
        [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            [self shareSuccessorError:state];
        }];
        
    }else if (index==2){
        [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            [self shareSuccessorError:state];
        }];
        
    }else{
        [ShareSDK share:SSDKPlatformSubTypeQZone parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            [self shareSuccessorError:state];
        }];
        
    }
}
#pragma mark -- 分享新浪
- (void)shareSina{
    NSString *shareUrl=@"http://app.360tj.com/tangshi";
    NSArray* imageArray = @[[UIImage imageNamed:@"ic_logo_share"]];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    if (imageArray) {
        [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"健康饮食，一起享受智能化生活%@",[NSURL URLWithString:shareUrl]]
                                         images:imageArray
                                            url:[NSURL URLWithString:shareUrl]
                                          title:@"下载天际云健康"
                                           type:SSDKContentTypeAuto];
    }
    
    [shareParams SSDKEnableUseClientShare];
    [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        [self shareSuccessorError:state];
    }];
}
#pragma mark -- 分享成功／失败／取消
- (void)shareSuccessorError:(NSInteger)index{
    if (index==1) {
        [self.view makeToast:@"分享成功" duration:1.0 position:CSToastPositionCenter];
        
    }else if (index==2){
        [self.view makeToast:@"分享失败" duration:1.0 position:CSToastPositionCenter];
        
    }else{
        [self.view makeToast:@"分享取消" duration:1.0 position:CSToastPositionCenter];
        
    }
    
}
#pragma mark-- Custom Methods
#pragma mark -- 初始化界面
-(void)initMineView{
    [self.view addSubview:self.menuTableView];
    [self.menuTableView addSubview:self.zoomImageView];
    [self.zoomImageView addSubview:self.userInfoView];
    [self.zoomImageView addSubview:self.loginView];
    self.loginView.hidden=YES;
    
}

#pragma mark --获取用户信息
-(void)getUserInfo{
    BOOL isLogining=kIsLogined;
    self.loginView.hidden=isLogining;
    self.userInfoView.hidden=!isLogining;
    if (isLogining) {
        [[NetworkTool sharedNetworkTool] postMethodWithURL:kSetUserInfo body:@"doSubmit=0" success:^(id json) {
            NSDictionary *result = [json objectForKey:@"result"];
            if (kIsDictionary(result)&&result.count>0) {
                TJYUserModel *userModel=[[TJYUserModel alloc] init];
                [userModel setValues:result];
                [TonzeHelpTool sharedTonzeHelpTool].user=userModel;
                
                [_headImageView sd_setImageWithURL:[NSURL URLWithString:userModel.photo] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
                _nickNameLabel.text =userModel.nick_name;
                NSString *userID=[[NSUserDefaultInfos getDicValueforKey:USER_DIC] valueForKey:@"user_id"];
                if (kIsEmptyString(userID)) {
                    _IDLabel.hidden=YES;
                }else{
                    _IDLabel.hidden=NO;
                    _IDLabel.text=[NSString stringWithFormat:@"ID：%@",[[NSUserDefaultInfos getDicValueforKey:USER_DIC] valueForKey:@"user_id"]];
                }
            }
        } failure:^(NSString *errorStr) {
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
#pragma mark ====== 请求订单数量 =======

- (void)requestOrderCount{
    [self.orderNumArr removeAllObjects];
    NSString *memberId = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *body = [NSString stringWithFormat:@"member_id=%@",memberId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postShopMethodWithoutLoadingURL:KOrderCount body:body success:^(id json) {
        NSDictionary *dic = [json objectForKey:@"result"];
        if (kIsDictionary(dic)) {
            OrderCountMode *orderModer = [OrderCountMode new];
            [orderModer setValues:dic];
            [weakSelf.orderNumArr addObject:orderModer.nopayed_count];
            [weakSelf.orderNumArr addObject:orderModer.nodelivery_count];
            [weakSelf.orderNumArr addObject:orderModer.noreceived_count];
            [weakSelf.orderNumArr addObject:@"0"];
            weakSelf.groupView.orderNumArr = weakSelf.orderNumArr;
        }
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat y=scrollView.contentOffset.y;
    if (y<-kImageViewHeight) {
        CGRect frame=_zoomImageView.frame;
        frame.origin.y=y;
        frame.size.height=-y;
        _zoomImageView.frame=frame;
    }
}

#pragma mark -- Setters and Getters
#pragma mark  用户信息
-(UITableView *)menuTableView{
    if (!_menuTableView) {
        _menuTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-49) style:UITableViewStyleGrouped];
        _menuTableView.delegate=self;
        _menuTableView.dataSource=self;
        _menuTableView.showsVerticalScrollIndicator=NO;
        _menuTableView.contentInset=UIEdgeInsetsMake(kImageViewHeight, 0, 0, 0);
        _menuTableView.tableFooterView=[[UIView alloc] init];
    }
    return _menuTableView;
}

#pragma mark  背景图片
-(UIImageView *)zoomImageView{
    if (!_zoomImageView) {
        //背景图片
        _zoomImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, -kImageViewHeight, SCREEN_WIDTH, kImageViewHeight)];
        _zoomImageView.image=[UIImage imageNamed:@"mine_bg"];
        _zoomImageView.userInteractionEnabled=YES;
        _zoomImageView.autoresizesSubviews=YES;   //设置autoresizesSubviews让子类自动布局
    }
    return _zoomImageView;
}

#pragma mark 头像和昵称
-(UIView *)userInfoView{
    if (!_userInfoView) {
        _userInfoView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kImageViewHeight)];
        _userInfoView.userInteractionEnabled=YES;
        _userInfoView.backgroundColor=[UIColor clearColor];
        
        
        _headImageView=[[UIImageView alloc] initWithFrame:CGRectMake(20, 60, 70, 70)];
        _headImageView.layer.cornerRadius=35;
        _headImageView.clipsToBounds=YES;
        _headImageView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin ;  //自动布局，自使用顶部
        [_userInfoView addSubview:_headImageView];
        
        _nickNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+10,70, SCREEN_WIDTH-_headImageView.right-30, 20)];
        _nickNameLabel.textColor=[UIColor whiteColor];
        _nickNameLabel.font=[UIFont systemFontOfSize:16];
        _nickNameLabel.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        [_userInfoView addSubview:_nickNameLabel];
        
        _IDLabel=[[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+10,_nickNameLabel.bottom+5, SCREEN_WIDTH-_headImageView.right-30, 20)];
        _IDLabel.textColor=kRGBColor(255, 195, 146);
        _IDLabel.font=[UIFont systemFontOfSize:13];
        _IDLabel.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        [_userInfoView addSubview:_IDLabel];
        
        UIImageView *iconImage=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 90, 15, 15)];
        iconImage.image=[UIImage imageNamed:@"箭头_个人信息部分"];
        iconImage.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        [_userInfoView addSubview:iconImage];
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gettoUserInfoVC)];
        [_userInfoView addGestureRecognizer:tap];
        
    }
    return _userInfoView;
}

#pragma mark 登录
-(UIView *)loginView{
    if (!_loginView) {
        _loginView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kImageViewHeight)];
        _loginView.backgroundColor=[UIColor clearColor];
        
        UIButton *loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2-65,50, 130, 40)];
        [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        loginBtn.backgroundColor = UIColorHex_Alpha(0xffffff, 0.5);
        loginBtn.layer.cornerRadius = 5;
        loginBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginBtn addTarget:self action:@selector(tologinAction) forControlEvents:UIControlEventTouchUpInside];
        [_loginView addSubview:loginBtn];
        
        UILabel *pormptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, loginBtn.bottom+20, kScreenWidth, 20)];
        pormptLabel.text = @"立即登录，享受贴心服务。";
        pormptLabel.font = [UIFont systemFontOfSize:12];
        pormptLabel.textColor = [UIColor whiteColor];
        pormptLabel.textAlignment = NSTextAlignmentCenter;
        [_loginView addSubview:pormptLabel];
        
    }
    return _loginView;
}

#pragma mark 我的订单
-(OrderGroupView *)groupView{
    if (!_groupView) {
        _groupView=[[OrderGroupView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, 75)];
        _groupView.delegate=self;
    }
    return _groupView;
}
- (NSMutableArray *)orderNumArr{
    if (!_orderNumArr) {
        _orderNumArr = [NSMutableArray array];
    }
    return _orderNumArr;
}

@end
