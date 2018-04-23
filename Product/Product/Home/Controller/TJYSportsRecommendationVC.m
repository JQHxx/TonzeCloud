//
//  TJYSportsRecommendationVC.m
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYSportsRecommendationVC.h"
#import "TJYSportsRecommendationCell.h"
#import "TJYRecommendMotionModel.h"
#import "TJYRecommendTextCell.h"

static CGFloat sectionHight = 45;

@interface TJYSportsRecommendationVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UITableView *tableView;

@property (nonatomic, copy) NSMutableArray *dataSource;
/// 运动建议
@property (nonatomic, copy) NSString *motion_adviceStr;
/// 不易运动
@property (nonatomic, copy) NSString *motion_inadvisableStr;

@end
@implementation TJYSportsRecommendationVC

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.baseTitle = @"体疗推荐";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self sportsRecommendsetUI];
    [self sportsRecommendloadData];
}
#pragma mark -- Build UI

- (void)sportsRecommendsetUI{
    [self.view addSubview:self.tableView];
}
#pragma mark -- request Data

- (void)sportsRecommendloadData{
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]getMethodWithURL:KRecommendMotion isLoading:YES success:^(id json) {
        NSDictionary *resultDic = [json objectForKey:@"result"];
        _motion_adviceStr = [resultDic objectForKey:@"motion_advice"];
        _motion_inadvisableStr = [resultDic objectForKey:@"motion_inadvisable"];
        NSArray *recommendMotionArr = [resultDic objectForKey:@"recommend_motion"];
        if (recommendMotionArr.count > 0 && kIsArray(recommendMotionArr)) {
            for (NSDictionary *dic  in recommendMotionArr) {
                TJYRecommendMotionModel *recommendMotionModel =[TJYRecommendMotionModel new];
                [recommendMotionModel setValues:dic];
                [weakSelf.dataSource addObject:recommendMotionModel];
            }
        }
        [_tableView reloadData];
    } failure:^(NSString *errorStr) {
        
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark -- UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==1) {
        return self.dataSource.count;
    }else{
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            if (!kIsEmptyString(_motion_adviceStr)) {
                CGFloat Texthight = [TJYRecommendTextCell tableView:tableView rowHeightForObject:_motion_adviceStr];
                return Texthight + 10;
            }else{
                return 0.01;
            }
        }break;
        case 1:
        {
            return 58;
        }break;
        case 2:
        {
            if (!kIsEmptyString(_motion_inadvisableStr)) {
                CGFloat Texthight = [TJYRecommendTextCell tableView:tableView rowHeightForObject:_motion_inadvisableStr];
                return Texthight + 10;
            }else{
                return 0.01;
            }
        }break;
        default:
            break;
    }
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            if (!kIsEmptyString(_motion_adviceStr)) {
                return sectionHight;
            }else{
                return 0.01;
            }
        }break;
        case 1:
        {
           return sectionHight;
        }break;
        case 2:
        {
            if (!kIsEmptyString(_motion_inadvisableStr)) {
                return sectionHight;
            }else{
                return 0.01;
            }
        }break;
        default:
            break;
    }
     return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = InsertView(nil, CGRectMake(0, 0, kScreenWidth, sectionHight), [UIColor whiteColor]);
    UIView *len =InsertView(sectionView, CGRectMake(0, 0, kScreenWidth, 10),kBackgroundColor);
    
    UIView *leftIcon =InsertView(sectionView, CGRectMake(15, len.bottom + 10, 3, 15), kSystemColor);
    
    UILabel *sectionTitle = InsertLabel(sectionView, CGRectMake(leftIcon.right + 5, leftIcon.top , 180, 15), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
    
    switch (section) {
        case 0:
        {
            if (!kIsEmptyString(_motion_adviceStr)) {
            sectionTitle.text = @"运动建议";
            }
        }break;
        case 1:
        {
            InsertView(sectionView, CGRectMake(0, sectionHight - 0.5,kScreenWidth, 0.5),kLineColor);
            sectionTitle.text = @"运动推荐";
        }break;
        case 2:
        {
          if (!kIsEmptyString(_motion_inadvisableStr)){
              sectionTitle.text = @"不宜运动";
            }
        }break;
        default:
            break;
    }
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identiifer = @"cell";
    static NSString *inadvisableCellIdentifer =@"commmentsCell";
    static NSString *adviceCellIdentifer = @"adviceCell";
    
    switch (indexPath.section) {
        case 0:
        {
            TJYRecommendTextCell *adviceCell = [[TJYRecommendTextCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:adviceCellIdentifer];
            [adviceCell setCellDataWithStr:_motion_adviceStr];
            adviceCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return adviceCell;
        }break;
          case 2:
        {
            TJYRecommendTextCell *inadvisableCell = [[TJYRecommendTextCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inadvisableCellIdentifer];
            [inadvisableCell setCellDataWithStr:_motion_inadvisableStr];
            inadvisableCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return inadvisableCell;
        }
        default:
            break;
    }
    
    TJYSportsRecommendationCell *cell = [tableView dequeueReusableCellWithIdentifier:identiifer];
    if (!cell) {
        cell = [[TJYSportsRecommendationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identiifer];
    }
    [cell cellInitWithData:self.dataSource[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
#pragma mark -- Getter --

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}
-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
