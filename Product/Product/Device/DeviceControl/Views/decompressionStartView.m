//
//  decompressionStartView.m
//  Product
//
//  Created by 梁家誌 on 2016/10/24.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "decompressionStartView.h"
#import "PreferenceModel.h"
#import "Product-Swift.h"
#import "Transform.h"
#import "TJYMenuListModel.h"

@interface decompressionStartView ()<UIGestureRecognizerDelegate>{
    UIView *backgroudView;
    PreferenceModel *preferenceModel;

}


@end

@implementation decompressionStartView

- (void)viewDidLoad {
    [super viewDidLoad];
    backgroudView=[[UIView alloc]initWithFrame:[ UIScreen mainScreen ].bounds];
    [backgroudView setBackgroundColor:[UIColor blackColor]];
    [backgroudView setAlpha:0.3f];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [backgroudView addGestureRecognizer:gesture];
    
    preferenceModel=[[PreferenceModel alloc]init];
    
    //新建一个model，避免发送不成功但是model已更新
    DeviceModel *d=[[DeviceModel alloc]init];
    d.time=self.model.time;
    d.authUser=self.model.authUser;
    d.deviceType=self.model.deviceType;
    d.deviceName=self.model.deviceName;
    d.deviceID=self.model.deviceID;
    d.isOnline=self.model.isOnline;
    d.State=[[NSMutableDictionary alloc]initWithDictionary:self.model.State];
    d.mac=self.model.mac;
    d.productID=self.model.productID;
    d.role = self.model.role;
    
    self.model=d;

    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnPipeData:) name:kOnRecvPipeSyncData object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kOnRecvPipeSyncData object:nil];
    
}

-(void)showInView:(UIView*)view{
    
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.view setAlpha:1.0f];
    [self.view.layer addAnimation:animation forKey:@"DDLocateView"];
    self.view.frame = CGRectMake(0, view.frame.size.height - self.view.frame.size.height,SCREEN_WIDTH, self.view.frame.size.height);
    
    [view addSubview:backgroudView];
    [view addSubview:self.view];
    
    //加载偏好
    _detailBtn.backgroundColor = [UIColor whiteColor];
    _detailBtn.userInteractionEnabled = NO;
    _loadActivity.hidden = NO;
    [_loadActivity startAnimating];

    //获取最新偏好命令
    [[ControllerHelper shareHelper] getCurrentPreference:self.model andString:self.preference];
   
}

-(void)loadPreferenceSuccess{
    if (preferenceModel.preferenceDetail.length>0&&preferenceModel.preferenceImgURL.length>0) {
        [_preferenceImageView sd_setImageWithURL:[NSURL URLWithString:preferenceModel.preferenceImgURL]
                       placeholderImage:[UIImage imageNamed:@"菜谱默认图.png"] options: SDWebImageRefreshCached];
    }
    _titleLbl.text = preferenceModel.preferenceName;
    _detailLbl.text = preferenceModel.preferenceDetail;
    _detailBtn.backgroundColor = [UIColor clearColor];
    _detailBtn.userInteractionEnabled = YES;
    [_loadActivity stopAnimating];
    _loadActivity.hidden = YES;
}

-(void)dismissView{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.view setAlpha:0.0f];
    [self.view.layer addAnimation:animation forKey:@"TSLocateView"];
    self.view.frame = CGRectMake(0,SCREEN_HEIGHT - self.view.frame.size.height, SCREEN_WIDTH, self.view.frame.size.height);
    
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3f];
    
    
}

-(void)viewRemoveFromSuperview{
    [backgroudView removeFromSuperview];
    [self.view removeFromSuperview];
}


-(IBAction)showPreferenceDetail:(id)sender{
    if (!_loadActivity.isAnimating&&!kIsEmptyString(preferenceModel.preferenceName)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(showPreferenceDetail:)]) {
            if (preferenceModel && preferenceModel.preferenceId) {
                [self.delegate showPreferenceDetail:preferenceModel.preferenceId];
            }
        }
    }
    
    
}

-(IBAction)startFunction:(id)sender{
    if (!_loadActivity.isAnimating&&!kIsEmptyString(preferenceModel.preferenceName)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(decompressionStartFunction:)]) {
            [self.delegate decompressionStartFunction:sender];
        }
    }
}

-(IBAction)orderStartFunction:(id)sender{
    if (!_loadActivity.isAnimating&&!kIsEmptyString(preferenceModel.preferenceName)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(decompressionOrderStartFunction:)]) {
            [self.delegate decompressionOrderStartFunction:sender];
        }
    }
}

- (IBAction)changePreference:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(changePreferenceFunction:)]) {
        [self.delegate changePreferenceFunction:sender];
    }
}

#pragma mark Device Delegate
-(void)OnPipeData:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    DeviceEntity *device=[dict objectForKey:@"device"];
    NSData *recvData=[dict objectForKey:@"payload"];
    
    MyLog(@"隔水炖16A偏好,decompressionStartView--%@",[recvData hexString]);
    
    uint32_t cmd_len = (uint32_t)[recvData length];
    uint8_t cmd_data[cmd_len];
    memset(cmd_data, 0, cmd_len);
    [recvData getBytes:(void *)cmd_data length:cmd_len];
    
    
    if ([[device getMacAddressSimple]isEqualToString:self.model.mac]) {
        
        if ((cmd_data[0]==0x11&&cmd_data[3]==0x05)||(cmd_data[0]==0x11&&cmd_data[3]==0x06)||(cmd_data[0]==0x11&&cmd_data[3]==0x10)) {
            //获取偏好信息的返回
            [self performSelectorOnMainThread:@selector(getPreferenceInfo:) withObject:recvData waitUntilDone:YES];
            
        }
    }
}

-(void)getPreferenceInfo:(NSData *)data{
    
    uint32_t cmd_len = (uint32_t)[data length];
    uint8_t cmd_data[cmd_len];
    memset(cmd_data, 0, cmd_len);
    [data getBytes:(void *)cmd_data length:cmd_len];
    
    //获取偏好状态命令返回
    [[ControllerHelper shareHelper] dismissProgressView];
    
    NSString *PreferenceInfo=@"";
    
    //云菜谱
    //获取云菜谱名称方法1
    int index = 27;
    int endCount = 0;//@"|"出现的次数，倒数第三次为名称结束符
    for (; index>0; index--) {
        if ([[NSString stringWithFormat:@"%C",(unichar)cmd_data[index]] isEqualToString:@"|"]) {
            endCount ++;
            if (endCount == 3) {
                break;
            }
        }
    }
    for (int i=6;i<index;i++) {
        int acciiCode=cmd_data[i]*256+cmd_data[i+1];
        i++;
        PreferenceInfo=[PreferenceInfo stringByAppendingString:[NSString stringWithFormat:@"%C",(unichar)acciiCode]];
    }
    
    if (index <= 0) {
        //获取云菜谱名称方法2
        for (int i=4;i<23;i++) {
            
            if ([[NSString stringWithFormat:@"%C",(unichar)cmd_data[i]] isEqualToString:@"\0"]) {
                break;
            }
            
            int acciiCode=cmd_data[i]*pow(16, 2)+cmd_data[i+1];
            i++;
            PreferenceInfo=[PreferenceInfo stringByAppendingString:[NSString stringWithFormat:@"%C",(unichar)acciiCode]];
        }
    }
    
    preferenceModel.preferenceType=TYPE_CLOUD_MENU;
    preferenceModel.preferenceName=PreferenceInfo;
    [self getCloudMenuDetail:preferenceModel.preferenceName];

}

#pragma mark 获取云菜谱的图片和介绍
-(void)getCloudMenuDetail:(NSString *)name{
    MyLog(@"菜谱名称：%@",name);
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSInteger tag=[self.preference isEqualToString:@"降压粥"]?3:4;
    NSString *urlStr = [NSString stringWithFormat:@"type=1&page_num=1&page_size=100&equipment=6&tag=%ld",(long)tag];
    __weak typeof(self) weakSelf = self;

    [[NetworkTool sharedNetworkTool]postMethodWithURL:kMenuList body:urlStr success:^(id json) {
        NSMutableArray *resultArr = [json objectForKey:@"result"];
        for (int i=0; i<resultArr.count; i++) {
            TJYMenuListModel *menuListModel = [TJYMenuListModel new];
            [menuListModel setValues:resultArr[i]];
            [dataArray addObject:menuListModel];
        }
        if (dataArray.count>0) {
            for (int i=0; i<dataArray.count; i++) {
                TJYMenuListModel *menuListModel = dataArray[i];
                MyLog(@"menuName:%@",menuListModel.name);
                if ([menuListModel.name isEqualToString:name]) {
                    preferenceModel.preferenceImgURL=menuListModel.image_id_cover;
                    preferenceModel.preferenceId = [NSString stringWithFormat:@"%ld",(long)menuListModel.cook_id];
                    preferenceModel.preferenceDetail=menuListModel.abstract;
                }
            }
            
            if (kIsEmptyString(preferenceModel.preferenceName)) {
                TJYMenuListModel *menuListModel=dataArray[0];
                preferenceModel.preferenceName=menuListModel.name;
                preferenceModel.preferenceImgURL=menuListModel.image_id_cover;
                preferenceModel.preferenceId = [NSString stringWithFormat:@"%ld",(long)menuListModel.cook_id];
                preferenceModel.preferenceDetail=menuListModel.abstract;
            }
            
        }
        [weakSelf loadPreferenceSuccess];
    } failure:^(NSString *errorStr) {
      
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
