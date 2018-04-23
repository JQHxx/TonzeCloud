//
//  DeviceGuideViewController.m
//  Product
//
//  Created by vision on 17/5/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DeviceGuideViewController.h"
#import "WiFiTipsViewController.h"
#import "ScaleViewController.h"
#import "MainDeviceInfo.h"
#import "ScaleListViewController.h"
#import "ShopDetailViewController.h"

@interface DeviceGuideViewController ()

@property (nonatomic,strong)UIScrollView *rootScrollView;
@property (nonatomic,strong)UIImageView  *contentImageView;
@property (nonatomic,strong)UILabel      *contentLabel;
@property (nonatomic,strong)UIButton     *connectBtn;
@property (nonatomic,strong)UIButton     *buyBtn;

@end

@implementation DeviceGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=self.deviceDict[@"name"];
    
    [self initDeviceGuideView];
    
    
}

#pragma mark -- Event Response
-(void)startConnectDeviceAction{
    if(kIsLogined){
        NSString *product_id=self.deviceDict[@"productID"];
        if ([product_id isEqualToString:SCALE_PRODUCT_ID]) {
            ScaleViewController *scaleVC=[[ScaleViewController alloc] init];
            [self.navigationController pushViewController:scaleVC animated:YES];
        }else if ([product_id isEqualToString:CLINK_BPM_PRODUCT_ID]||[product_id isEqualToString:THERMOMETER_PRODUCT_ID]){
            ScaleListViewController *scaleVC = [[ScaleListViewController alloc] init];
            scaleVC.deviceType = [product_id isEqualToString:CLINK_BPM_PRODUCT_ID]?DeviceTypeBPMeter:DeviceTypeThermometer;
            [self.navigationController pushViewController:scaleVC animated:YES];
        }else{
            MainDeviceInfo *device=[[MainDeviceInfo alloc] init];
            device.productID=self.deviceDict[@"productID"];
            device.deviceName=self.deviceDict[@"name"];
            [TJYHelper sharedTJYHelper].selectDevice=device;
            WiFiTipsViewController *wifiTipsVC=[[WiFiTipsViewController alloc] init];
            [self.navigationController pushViewController:wifiTipsVC animated:YES];
        }
    }else{
        [self pushToFastLogin];
    }
}

#pragma mark 购买设备
-(void)toBuyDeviceForProductId{
    ShopDetailViewController *shopDetailsVC=[[ShopDetailViewController alloc] init];
    shopDetailsVC.product_id=[self.deviceDict[@"product_id"] integerValue];
    [self.navigationController pushViewController:shopDetailsVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 初始化设备引导页
-(void)initDeviceGuideView{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.contentImageView];
    [self.rootScrollView addSubview:self.contentLabel];
    [self.rootScrollView addSubview:self.connectBtn];
    [self.rootScrollView addSubview:self.buyBtn];
    
    self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.buyBtn.bottom+20);
}

#pragma mark -- Setters and Getters
#pragma mark 根滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavigationHeight+kStatusBarHeight, kScreenWidth, kRootViewHeight)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
    }
    return _rootScrollView;
}

#pragma mark  设备图片介绍
-(UIImageView *)contentImageView{
    if (!_contentImageView) {
        _contentImageView=[[UIImageView alloc] initWithFrame:CGRectMake(30, 20, kScreenWidth-60, kScreenWidth-60)];
        _contentImageView.image=[UIImage imageNamed:self.deviceDict[@"mainImage"]];
    }
    return _contentImageView;
}

#pragma mark 设备文字介绍
-(UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines=0;
        _contentLabel.font=[UIFont systemFontOfSize:14];
        _contentLabel.textColor=[UIColor blackColor];
        _contentLabel.text=self.deviceDict[@"summary"];
        CGFloat height=[_contentLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-40, CGFLOAT_MAX) withTextFont:_contentLabel.font].height;
        _contentLabel.frame=CGRectMake(20, self.contentImageView.bottom+10, kScreenWidth-40, height+10);
    }
    return _contentLabel;
}

#pragma mark 设备连接
-(UIButton *)connectBtn{
    if (!_connectBtn) {
        _connectBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, self.contentLabel.bottom+20, kScreenWidth-80, 40)];
        [_connectBtn setTitle:@"立即添加" forState:UIControlStateNormal];
        [_connectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _connectBtn.backgroundColor=kSystemColor;
        _connectBtn.layer.cornerRadius=5;
        _connectBtn.clipsToBounds=YES;
        [_connectBtn addTarget:self action:@selector(startConnectDeviceAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _connectBtn;
}

#pragma mark 购买设备
-(UIButton *)buyBtn{
    if (!_buyBtn) {
        _buyBtn=[[UIButton alloc] initWithFrame:CGRectMake(80, self.connectBtn.bottom+10, kScreenWidth-160, 40)];
        [_buyBtn setTitle:@"购买" forState:UIControlStateNormal];
        [_buyBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_buyBtn addTarget:self action:@selector(toBuyDeviceForProductId) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buyBtn;
}


@end
