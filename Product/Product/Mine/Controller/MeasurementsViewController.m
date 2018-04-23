//
//  MeasurementsViewController.m
//  Product
//
//  Created by 梁家誌 on 16/8/23.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "MeasurementsViewController.h"
#import "TempMeasurementsCell.h"
#import "BPMeterMeasurementsCell.h"
#import "MeasurementsModel.h"
#import "MeasurementsManager.h"

@interface MeasurementsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *_bpArray;
    NSMutableArray *_tempArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *noDataImageView;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;


@end

@implementation MeasurementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor bgColor_Gray];
    self.baseTitle=@"测量结果";
    
    [_tableView registerNib:[UINib nibWithNibName:@"TempMeasurementsCell" bundle:nil] forCellReuseIdentifier:@"TempMeasurementsCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"BPMeterMeasurementsCell" bundle:nil] forCellReuseIdentifier:@"BPMeterMeasurementsCell"];
    _bpArray = [NSMutableArray array];
    _tempArray = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSMutableArray *tem = [MeasurementsManager shareManager].measurements;
    _noDataLabel.hidden = _noDataImageView.hidden = tem.count > 0;
    for (MeasurementsModel *model in tem) {
        if (model.type == MeasurementType_Temp) {
            [_tempArray addObject:model];
        }else if (model.type == MeasurementType_BPMeter){
            [_bpArray addObject:model];
        }
    }
    [_tempArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MeasurementsModel *meas1 = (MeasurementsModel *)obj1;
        MeasurementsModel *meas2 = (MeasurementsModel *)obj2;
        return [meas1.date compare:meas2.date]==NSOrderedAscending;
    }];
    [_bpArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MeasurementsModel *meas1 = (MeasurementsModel *)obj1;
        MeasurementsModel *meas2 = (MeasurementsModel *)obj2;
        return [meas1.date compare:meas2.date]==NSOrderedAscending;
    }];
    
}

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_bpArray.count>0&&_tempArray.count>0) {
        return 2;
    }
    if (_bpArray.count>0 || _tempArray.count>0) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (_bpArray.count > 0) {
            return _bpArray.count;
        }else if (_bpArray.count == 0 && _tempArray.count > 0){
            return _tempArray.count;
        }
    }else{
        return _tempArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *tempCellIdentifier = @"TempMeasurementsCell";
    static NSString *BPMaterCellIdentifier = @"BPMeterMeasurementsCell";
    TempMeasurementsCell *tempCell= [tableView dequeueReusableCellWithIdentifier:tempCellIdentifier];
    BPMeterMeasurementsCell *BPMeterCell= [tableView dequeueReusableCellWithIdentifier:BPMaterCellIdentifier];
    if (!tempCell) {
        tempCell = [tableView dequeueReusableCellWithIdentifier:tempCellIdentifier];
    }
    if (!BPMeterCell) {
        BPMeterCell = [tableView dequeueReusableCellWithIdentifier:BPMaterCellIdentifier];
    }
    tempCell.selectionStyle=UITableViewCellSelectionStyleNone;
    BPMeterCell.selectionStyle=UITableViewCellSelectionStyleNone;

    
    MeasurementsModel *model;
    if (indexPath.section == 0) {
        if (_bpArray.count > 0) {
            model = _bpArray[indexPath.row];
        }else if (_bpArray.count == 0 && _tempArray.count != 0){
            model = _tempArray[indexPath.row];
        }
    }else{
        model = _tempArray[indexPath.row];
    }
    if (model.type == MeasurementType_Temp) {
        tempCell.model = model;
        return tempCell;
    }else if (model.type == MeasurementType_BPMeter){
        BPMeterCell.model = model;
        return BPMeterCell;
    }
    
    return BPMeterCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (_bpArray.count > 0) {
            return 180;
        }else if (_bpArray.count == 0 && _tempArray.count != 0){
            return 145;
        }
    }else{
        return 145;
    }
    return 180;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 0 : 20;
}



@end
