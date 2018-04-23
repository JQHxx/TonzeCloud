
//
//  AddtimeIntervalViewController.m
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddTimeIntervalViewController.h"
#import "SceneTimeIntervalPickerView.h"

@interface AddTimeIntervalViewController ()<AddTimePickerViewDelegate>
{
    NSInteger _hour;// 小时
    NSInteger _minute;// 分钟
    NSInteger _second;// 秒
}
// 添加时间间隔
@property (nonatomic ,strong) UIButton *addTimeBtn;
/// 延时文字
@property (nonatomic ,strong) UILabel *delayTextLab;
/// 时间选择
@property (nonatomic ,strong) SceneTimeIntervalPickerView *timePickView;

@end

@implementation AddTimeIntervalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.baseTitle = @"添加时间间隔";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    _hour = 0;
    _minute = 0;
    _second = 1;// 默认为"1"秒
    [self setAddtimeIntervalVC];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-06" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"006-04-06" type:2];
#endif
}

#pragma mark -- Bulid UI

- (void)setAddtimeIntervalVC{
    [self.view addSubview:self.delayTextLab];
    [self.timePickView show:self.view];
    [self.view addSubview:self.addTimeBtn];
    [_timePickView selectRow:1 inComponent:4 animated:NO];// 默认选中为1秒
}

#pragma mark ====== Event response =======
- (void)addTimeClick
{
    NSInteger timeSum = _hour * 3600 + _minute * 60 + _second;
    if (timeSum == 0) {
        [self.view makeToast:@"时间间隔不能小于1秒" duration:1.0 position:CSToastPositionCenter];
    }else{
        // 时间回调
        if (self.timeIntervalBlock) {
            self.timeIntervalBlock(timeSum);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark ====== AddTimePickerViewDelegate =======
- (void)didSelectedPickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row    inComponent:(NSInteger)component RowText:(NSString *)text{
//    NSString *st =[NSString stringWithFormat:@"您选择了第%ld列的第%ld行，内容是%@",(long)component,(long)row,text];
    switch (component) {
        case 0:
        {
            _hour = row;
        }break;
         case 2:
        {
            _minute = row;
        }break;
        case 4:
        {
            _second = row;
        }break;
        default:
            break;
    }
}
#pragma mark ====== Getter =======

- (UIButton *)addTimeBtn{
    if (!_addTimeBtn) {
        _addTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addTimeBtn.frame = CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44);
        [_addTimeBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_addTimeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addTimeBtn.titleLabel.font = kFontSize(15);
        _addTimeBtn.backgroundColor = KSysOrangeColor;
        [_addTimeBtn addTarget:self action:@selector(addTimeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addTimeBtn;
}
- (SceneTimeIntervalPickerView *)timePickView{
    if (!_timePickView) {
        _timePickView = [[SceneTimeIntervalPickerView alloc]initWithFrame:CGRectMake(0, 48 + 64 , kScreenWidth, 240)];
        _timePickView.fzdelegate = self;
        _timePickView.proTitleList = @[@[@"0",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"],@[@"小时"],@[@"0",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59"],@[@"分"],@[@"0",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59"],@[@"秒"]];
        _timePickView.showsSelectionIndicator = YES;
    }
    return _timePickView;
}
- (UILabel *)delayTextLab{
    if (!_delayTextLab) {
        _delayTextLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 12 + 64, 100, 20)];
        _delayTextLab.text = @"延时";
        _delayTextLab.textColor = UIColorHex(0x313131);
        _delayTextLab.font = kFontSize(15);
    }
    return _delayTextLab;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
