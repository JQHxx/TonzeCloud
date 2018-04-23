//
//  ScanQRViewController.m
//  Product
//
//  Created by Xlink on 15/12/8.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "ScanQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MainDeviceInfo.h"
#import "WiFiTipsViewController.h"
#import "AppDelegate.h"
#import "QRcodeTimeOutViewController.h"
#import "ConnectSuccessViewController.h"
#import "ShareModel.h"
#import "DeviceHelper.h"

@interface ScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate>{
  __weak  IBOutlet    UIView * _scanView;

  AVCaptureDevice            * _device;
  AVCaptureDeviceInput       * _input;
  AVCaptureMetadataOutput    * _output;
  AVCaptureSession           * _session;
  AVCaptureVideoPreviewLayer * _preview;

  BOOL                       needAnimating;
  AppDelegate                * appDelegate;
}

@property (nonatomic,strong)MainDeviceInfo * main;
@property (strong, nonatomic) NSNumber     * deviceID;
@property (strong, nonatomic) NSString     * QRcode;
@property (nonatomic, strong) AVCaptureDevice *device;
/// 是否开启手电筒
@property (nonatomic,assign) BOOL isLightOn;
@end

@implementation ScanQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"扫描二维码";
    appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    [self startScan];
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [ _session startRunning];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    needAnimating=NO;
    [ _session stopRunning];
}

#pragma mark -- Private Methods
#pragma mark 开始扫描
- (void)startScan{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        [_scanView layoutIfNeeded];
        needAnimating=YES;
        [self moveLineLblDown];
        [self setScanView];
    }else if(status == AVAuthorizationStatusNotDetermined){
        __weak typeof(self) weakSelf=self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [_scanView layoutIfNeeded];
                    needAnimating=YES;
                    [weakSelf moveLineLblDown];
                    [weakSelf setScanView];
                    [ _session startRunning];
                });
            }else {
                [weakSelf showAlertWithTitle:@"提示" Message:@"请到设置处打开app的相机权限"];
            }
        }];
    }else{
        [self showAlertWithTitle:@"提示" Message:@"请到设置处打开app的相机权限"];
    }
}

#pragma mark 初始化扫描视图
-(void)setScanView{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput :_input]){
        [_session addInput:_input];
    }
    if ([_session canAddOutput :_output ]){
        [_session addOutput:_output];
    }
    
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill ;
    _preview.frame = _scanView.layer.bounds;
    [_scanView.layer insertSublayer:_preview atIndex:0];
    
    float width = _scanView.frame.size.width * 0.6;
    _output.rectOfInterest = CGRectMake(100 / _scanView.frame.size.height, 0.2f, width / _scanView.frame.size.height, 0.6f);
}

#pragma mark 扫描线向下动画效果
-(void)moveLineLblDown{
    lineLbl.frame=CGRectMake(lineLbl.frame.origin.x, upView.frame.origin.y+upView.frame.size.height+10, lineLbl.frame.size.width, lineLbl.frame.size.height);
    //简单的动画效果
    [UIView animateWithDuration:2.0 animations:^{
          lineLbl.frame=CGRectMake(lineLbl.frame.origin.x, downView.frame.origin.y-10, lineLbl.frame.size.width, lineLbl.frame.size.height);
    } completion:^(BOOL finished) {
        if (needAnimating) {
            [self moveLineLblUp];
        }
    }];
}

#pragma mark 扫描线向上动画效果
-(void)moveLineLblUp{
      lineLbl.frame=CGRectMake(lineLbl.frame.origin.x, downView.frame.origin.y-10, lineLbl.frame.size.width, lineLbl.frame.size.height);
    //简单的动画效果
    [UIView animateWithDuration:2.0 animations:^{
        lineLbl.frame=CGRectMake(lineLbl.frame.origin.x, upView.frame.origin.y+upView.frame.size.height+10, lineLbl.frame.size.width, lineLbl.frame.size.height);
    } completion:^(BOOL finished) {
        if (needAnimating) {
            [self moveLineLblDown];
        }
    }];
}

#pragma mark 添加设备
- (void)addDevice:(NSDictionary *)dic{
    [HttpRequest getShareListWithAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        if (!err) {
            NSArray *tem = (NSArray *)result;
            for (NSDictionary *newsDict in tem) {
                ShareModel *model = [[ShareModel alloc] init];
                [model setValuesForKeysWithDictionary:newsDict];
                model.to_id = newsDict[@"user_id"];
                if ([model.invite_code isEqualToString:_QRcode]) {
                    _deviceID = model.device_id;
                    for (NSDictionary *deviceDic in dic[@"list"]) {
                        if ([@([deviceDic[@"id"] intValue]) isEqualToNumber:_deviceID]) {
                            DeviceEntity *newDevice = [[DeviceEntity alloc] initWithMac:deviceDic[@"mac"] andProductID:deviceDic[@"product_id"]];
                            newDevice.deviceID = [deviceDic[@"id"] intValue];
                            newDevice.accessKey = deviceDic[@"access_key"];
                            [self performSelectorOnMainThread:@selector(pushToSuccess:) withObject:newDevice waitUntilDone:YES];
                        }
                    }
                    break;
                }
            }
        }else{
            if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }
            [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
        }
    }];
}


- (void)pushToSuccess:(DeviceEntity *)device{
    ConnectSuccessViewController *connectSuccessVC=[[ConnectSuccessViewController alloc] init];
    connectSuccessVC.device=device;
    connectSuccessVC.isScanQR=YES;
    connectSuccessVC.productID=device.productID;
    [self.navigationController pushViewController:connectSuccessVC animated:YES];
}


#pragma mark  保存设备缓存到本地
-(void)saveDeviceToLocal:(DeviceEntity *)device{
    NSMutableDictionary *deviceDic = [[NSMutableDictionary alloc] initWithDictionary:[DeviceHelper getDeviceDictionary:[device getDictionaryFormat]]];
    NSMutableArray *deviceArr = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"devices"]];
    BOOL hadOldDevice=NO;
    for (NSDictionary *dic in deviceArr) {
        if ([[dic objectForKey:@"macAddress"] isEqualToString:[deviceDic objectForKey:@"macAddress"]]) {
            hadOldDevice=YES;
        }
    }
    if (!hadOldDevice) {
        [deviceArr addObject:deviceDic];
    }else{
        for (int i=0;i<deviceArr.count;i++) {
            NSDictionary *dic=[deviceArr objectAtIndex:i];
            if ([[dic objectForKey:@"macAddress"] isEqual:[deviceDic objectForKey:@"macAddress"]]) {
                [deviceArr replaceObjectAtIndex:i withObject:deviceDic];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:deviceArr forKey:@"devices"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


#pragma mark -- Delegate
#pragma mark AVCaptureMetadataOutputObjects Delegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    needAnimating=NO;
    if ([metadataObjects count] > 0 ){
        for (AVMetadataObject *metadataObject in metadataObjects) {
            if (![metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
                continue;
            }
            AVMetadataMachineReadableCodeObject *machineReadableCode = (AVMetadataMachineReadableCodeObject *)metadataObject;
            
            if ([machineReadableCode.stringValue isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]||[machineReadableCode.stringValue isEqualToString:CLOUD_COOKER_PRODUCT_ID]||[machineReadableCode.stringValue isEqualToString:WATER_COOKER_PRODUCT_ID]||[machineReadableCode.stringValue isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]||[machineReadableCode.stringValue isEqualToString:CLOUD_KETTLE_PRODUCT_ID]||[machineReadableCode.stringValue isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]||[machineReadableCode.stringValue isEqualToString:CABINETS_PRODUCT_ID]) {
                [_session stopRunning];
                MainDeviceInfo *main = [[MainDeviceInfo alloc]init];
                main.macAddr = @"";
                main.productID = machineReadableCode.stringValue;
                NSString *deviceType=nil;
                if ([main.productID isEqualToString:CLOUD_KETTLE_PRODUCT_ID]) {
                    deviceType=@"云智能私享壶";
                    main.deviceType=DeviceTypeCloudKettle;
                }else if([main.productID isEqualToString:CLOUD_COOKER_PRODUCT_ID]) {
                    deviceType=@"云智能电炖锅";
                    main.deviceType=DeviceTypeCloudCooker;
                }else if([main.productID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]) {
                    deviceType=@"云智能健康大厨";
                    main.deviceType=DeviceCookFood;
                }else if([main.productID isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]) {
                    deviceType=@"云智能IH电饭煲";
                    main.deviceType=DeviceTypeElectricCooker;
                }else if([main.productID isEqualToString:WATER_COOKER_PRODUCT_ID]) {
                    deviceType=@"云智能隔水电炖锅";
                    main.deviceType=DeviceTypeWaterCooker;
                }else if([main.productID isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]) {
                    deviceType=@"云智能隔水电炖锅16AIG";
                    main.deviceType=DeviceTypeWaterCooker16AIG;
                }else if([main.productID isEqualToString:THERMOMETER_PRODUCT_ID]) {
                    deviceType=@"蓝牙智能体温贴";
                    main.deviceType=DeviceTypeThermometer;
                }else if([main.productID isEqualToString:CLINK_BPM_PRODUCT_ID]) {
                    deviceType=@"蓝牙智能血压计";
                    main.deviceType=DeviceTypeBPMeter;
                }else if ([main.productID isEqualToString:CABINETS_PRODUCT_ID]) {
                    deviceType=@"智能厨物柜";
                    main.deviceType=DeviceTypeBPMeter;
                }
                
                if (deviceType!=nil) {
                    main.mainInfo = machineReadableCode.stringValue;
                    self.main=main;
                    [TJYHelper sharedTJYHelper].selectDevice=main;
                    WiFiTipsViewController *tipsVC=[[WiFiTipsViewController alloc] init];
                    [self.navigationController pushViewController:tipsVC animated:YES];
                }
            }else{
                //2.扫描二维码接受分享
                AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
                NSString *stringValue = metadataObject.stringValue ;
                if ([[stringValue substringToIndex:7] isEqualToString:@"tianji-"]) {
                    [_session stopRunning];
                    MyLog(@"分享码：%@",stringValue);
                    _QRcode = [stringValue substringFromIndex:7];
                    //接受分享
                    [HttpRequest acceptShareWithInviteCode:[stringValue substringFromIndex:7] withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                        if (!err) {
                            __weak typeof(self) weakSelf = self;
                            [HttpRequest getDeviceListWithUserID:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"user_id"] withAccessToken:[[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"] withVersion:@(0) didLoadData:^(id result, NSError *err) {
                                if (!err) {
                                    NSDictionary *dic = (NSDictionary *)result;
                                    [weakSelf addDevice:dic];
                                } else {
                                    if (err.code==4031003) {
                                        [appDelegate updateAccessToken];
                                    }
                                    [ _session startRunning];
                                    [self showAlertWithTitle:nil Message:[HttpRequest getErrorInfoWithErrorCode:err.code]];
                                }
                            }];
                        }else{
                            QRcodeTimeOutViewController *view = [[QRcodeTimeOutViewController alloc] init];
                            [self.navigationController pushViewController:view animated:YES];
                        }
                    }];
                }
                
            }
        }
   }
}

#pragma mark --Response Methods
#pragma mark 跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    WiFiTipsViewController *tipsVC=[[WiFiTipsViewController alloc] init];
    [TJYHelper sharedTJYHelper].selectDevice=self.main;
    [self.navigationController pushViewController:tipsVC animated:YES];
    
}
#pragma mark ====== 手电筒开关 =======
- (IBAction)flashlightAction:(id)sender {
#if !DEBUG
    [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"006-03-03"];
#endif
    _isLightOn = !_isLightOn;
    //根据ligthOn状态判断打开还是关闭
    if (_isLightOn) {
        //开启手电筒
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOn];
        [_device unlockForConfiguration];
        [_flashlightButton setImage:[UIImage imageNamed:@"ic_sao_light_on"] forState:UIControlStateNormal];
    }else{
        //关闭手电筒
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOff];
        [_device unlockForConfiguration];
        [_flashlightButton setImage:[UIImage imageNamed:@"ic_sao_light_un"] forState:UIControlStateNormal];
    }
}
@end
