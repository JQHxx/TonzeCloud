//
//  CheckLogisticsViewController.m
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "CheckLogisticsViewController.h"
#import "LogisticsInfoCell.h"
#import "LogisticsStatusCell.h"
#import "LogisticsDetailsCell.h"
#import "DeliveryModel.h"
#import "GoodsInfoModel.h"
#import "TrajectoryModel.h"

@interface CheckLogisticsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *checkLogisticsTab;
///
@property (nonatomic ,strong)  GoodsInfoModel *goodsInfoModel;
///
@property (nonatomic ,strong)  DeliveryModel *deliveryModel;
///
@property (nonatomic ,strong) NSMutableArray *trajectoryArray;
@end

@implementation CheckLogisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"查看物流";
    
    [self initCheckLogisticsVC];
    [self requestCheckLogisticsData];
}
#pragma mark ====== Build UI =======

- (void)initCheckLogisticsVC{
    [self.view addSubview:self.checkLogisticsTab];
}
#pragma mark ====== Request Data =======
- (void)requestCheckLogisticsData{
    
    NSString *body = [NSString stringWithFormat:@"order_id=%@",_orderId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KLogisticsInfo body:body success:^(id json) {
        NSDictionary *orderDataDic = [json objectForKey:@"result"];
        NSDictionary *goodsDic = [orderDataDic objectForKey:@"goods"];
        if (kIsDictionary(goodsDic)) {
            GoodsInfoModel *goodsModel = [GoodsInfoModel new];
            [goodsModel setValues:goodsDic];
            weakSelf.goodsInfoModel = goodsModel;
        }
        
        NSDictionary *deliveryDic = [orderDataDic objectForKey:@"delivery"];
        if (kIsDictionary(deliveryDic)) {
            DeliveryModel *deliveryModel = [DeliveryModel new];
            [deliveryModel setValues:deliveryDic];
            weakSelf.deliveryModel = deliveryModel;
            
            NSArray *tracesArr = deliveryModel.Traces;
            if (tracesArr.count > 0 && kIsArray(tracesArr)) {
                for (NSDictionary *dic in tracesArr) {
                    TrajectoryModel *trajectoryModel = [TrajectoryModel new];
                    [trajectoryModel setValues:dic];
                    [weakSelf.trajectoryArray addObject:trajectoryModel];
                }
            }
        }
        [weakSelf.checkLogisticsTab reloadData];
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== UITableViewDataSource =======

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
        {
            return 2;
        }
            break;
        case 1:
        {
            return self.trajectoryArray.count;
        }break;
        default:
            break;
    }
    return 0;
}
#pragma mark ====== UITableViewDelegate =======

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                return  120;
            }else{
                return 90;
            }
        }
            break;
        case 1:
        {
            TrajectoryModel *trajectoryModel  = self.trajectoryArray[indexPath.row];
            return [LogisticsDetailsCell cellHeightForRowAtIndexPath:trajectoryModel.AcceptStation];
        }
            break;
        default:
            break;
    }
    return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
        {
            return 0.01f;
        }
            break;
        case 1:
        {
            NSString *str = [NSString stringWithFormat:@"[收货地址] %@",self.deliveryModel.ConsigneeAddr];
            CGSize size = [str boundingRectWithSize:CGSizeMake(kScreenWidth  - 66, 100) withTextFont:kFontSize(13) ];
            CGFloat addressHight = size.height > 18 ?  55 + size.height  :  70;
            return 38.0f + addressHight;
        }
            break;
        default:
            break;
    }
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1:
        {
            NSString *str = [NSString stringWithFormat:@"[收货地址] %@",self.deliveryModel.ConsigneeAddr];
            CGSize size = [str boundingRectWithSize:CGSizeMake(kScreenWidth  - 66, 100) withTextFont:kFontSize(13) ];
            
            UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, size.height > 18 ?  35 + size.height  :  70)];
            sectionHeaderView.backgroundColor = [UIColor whiteColor];
            
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
            line.backgroundColor = [UIColor bgColor_Gray];
            [sectionHeaderView addSubview:line];
            
            UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(18,line.bottom , 200, 38)];
            tipLab.text = @"物流详情";
            tipLab.font = kFontSize(12);
            tipLab.textColor = UIColorHex(0x999999);
            [sectionHeaderView addSubview:tipLab];
            
            UILabel *lens = [[UILabel alloc]initWithFrame:CGRectMake(0, 38 + 10, kScreenWidth, 0.5)];
            lens.backgroundColor = UIColorHex(0xe5e5e5);
            [sectionHeaderView addSubview:lens];
            
            UIImageView *addressIcon =[[UIImageView alloc]initWithFrame:CGRectMake(30, lens.bottom + 20, 16, 16)];
            addressIcon.image = [UIImage imageNamed:@"pd_ic_address"];
            [sectionHeaderView addSubview:addressIcon];
            
            UILabel *addressInfoLab = [[UILabel alloc]initWithFrame:CGRectMake(addressIcon.right + 10, addressIcon.top, kScreenWidth - addressIcon.right - 18, size.height)];
            addressInfoLab.font = kFontSize(13);
            addressInfoLab.numberOfLines = 0;
            addressInfoLab.textColor = UIColorHex(0xf39800);
            [sectionHeaderView addSubview:addressInfoLab];
            if (!kIsEmptyString(self.deliveryModel.ConsigneeAddr)) {
                addressInfoLab.text =[NSString stringWithFormat:@"[收货地址] %@",self.deliveryModel.ConsigneeAddr];
            }
            return sectionHeaderView;
        }
            break;
        default:
            break;
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *logisticsInfoCellIdentifier = @"logisticsInfoCellIdentifier";
    static NSString *logisticsStatusCellIdentifier =@"logisticsStatusCellIdentifier";
    static NSString *logisticsDetailsCellIdentifier = @"logisticsDetailsCellIdentifier";
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                LogisticsInfoCell *logisticsInfoCell = [tableView dequeueReusableCellWithIdentifier:logisticsInfoCellIdentifier];
                if (!logisticsInfoCell) {
                    logisticsInfoCell = [[LogisticsInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:logisticsInfoCellIdentifier];
                }
                if (!kIsEmptyString(_goodsInfoModel.goods_id)) {
                    [logisticsInfoCell cellWithGoodsInfoModel:self.goodsInfoModel deliveryModel:self.deliveryModel];
                }
                
                return logisticsInfoCell;
            }else{
                LogisticsStatusCell *logisticsInfoCell = [tableView dequeueReusableCellWithIdentifier:logisticsStatusCellIdentifier];
                if (!logisticsInfoCell) {
                    logisticsInfoCell = [[LogisticsStatusCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:logisticsStatusCellIdentifier];
                }
                // 发货状态
                if (!kIsEmptyString(_goodsInfoModel.goods_id)) {
                    [logisticsInfoCell cellWithGoodsInfoModel:_goodsInfoModel];
                    if ([_deliveryModel.State isEqualToString:@"3"]) {
                        logisticsInfoCell.type = 2;
                    }else if (_deliveryModel.DeliveryState == 1 && ![_deliveryModel.State isEqualToString:@"3"]){
                        logisticsInfoCell.type = 1;
                    }else if ([_orderStatus isEqualToString:@"nodelivery"]){
                         logisticsInfoCell.type = 0;
                    }
                }
                return logisticsInfoCell;
            }
        }
            break;
        case 1:
        {
            LogisticsDetailsCell *logisticsDetailsCell = [tableView dequeueReusableCellWithIdentifier:logisticsDetailsCellIdentifier];
            if (!logisticsDetailsCell) {
                logisticsDetailsCell = [[LogisticsDetailsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:logisticsDetailsCellIdentifier];
            }
            if (indexPath.row == 0) {
                logisticsDetailsCell.statusImg.hidden = NO;
                logisticsDetailsCell.orderInfoLab.textColor = UIColorHex(0xf39800);
                logisticsDetailsCell.timeLab.textColor = UIColorHex(0xf39800);
            }else if (indexPath.row == _trajectoryArray.count-1){
                logisticsDetailsCell.statusImg.hidden = YES;
                logisticsDetailsCell.lens.hidden = YES;
                logisticsDetailsCell.orderInfoLab.textColor = UIColorHex(0x999999);
                logisticsDetailsCell.timeLab.textColor = UIColorHex(0x999999);
            }else{
                logisticsDetailsCell.orderInfoLab.textColor = UIColorHex(0x999999);
                logisticsDetailsCell.timeLab.textColor = UIColorHex(0x999999);
                logisticsDetailsCell.lens.hidden = NO;
                logisticsDetailsCell.statusImg.hidden = YES;
            }
            
            TrajectoryModel *trajectoryModel  = self.trajectoryArray[indexPath.row];
            [logisticsDetailsCell cellWithTrajectoryModel:trajectoryModel];
            
            return logisticsDetailsCell;
        }
            break;
        default:
            break;
    }
    return  nil;
}

#pragma mark ====== Setter =======

- (UITableView *)checkLogisticsTab{
    if (!_checkLogisticsTab) {
        _checkLogisticsTab = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kBodyHeight) style:UITableViewStyleGrouped];
        _checkLogisticsTab.dataSource = self;
        _checkLogisticsTab.delegate = self;
        _checkLogisticsTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        _checkLogisticsTab.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];;
    }
    return _checkLogisticsTab;
}

- (NSMutableArray *)trajectoryArray{
    if (!_trajectoryArray) {
        _trajectoryArray = [NSMutableArray array];
    }
    return _trajectoryArray;
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
