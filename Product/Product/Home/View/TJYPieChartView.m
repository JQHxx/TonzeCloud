//
//  TJYPieChartView.m
//  Product
//
//  Created by zhuqinlu on 2017/5/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYPieChartView.h"
#import "Product-Bridging-Header.h"
#import "Product-Swift.h"

@interface TJYPieChartView ()
{
    NSInteger _totalCalorie;// 总的推荐摄入量
}
/// 饼型图
@property (nonatomic, strong) PieChartView *pieChartView;
/// 饼型数据源
@property (nonatomic, strong) PieChartData *pieChartData;

@property (nonatomic, strong) NSDictionary *dic;

@end

@implementation TJYPieChartView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        // 创建饼状图
        _pieChartView = [[PieChartView alloc] initWithFrame:self.frame];
        
        _pieChartView.backgroundColor = [UIColor whiteColor];
        
        //    _pieChartView.delegate = self;
        
        [self addSubview:_pieChartView];
        
        // 基本样式
        [_pieChartView setExtraOffsetsWithLeft:kScreenWidth/3
                                           top:5.0f
                                         right:kScreenWidth/3
                                        bottom:0.0f]; // 饼状图距离边缘的间隙
        
        _pieChartView.usePercentValuesEnabled = YES; // 是否根据所提供的数据, 将显示数据转化为百分比格式
        _pieChartView.dragDecelerationEnabled = YES; // 拖拽饼状图后是否有惯性效果
        _pieChartView.drawSliceTextEnabled = YES; // 是否显示区块文本
        
        // 空心饼状图样式
        //    _pieChartView.drawHoleEnabled = YES; // 饼状图是否为空心
        
        _pieChartView.holeRadiusPercent = 0.5f; // 空心半径占比
        
        _pieChartView.holeColor = [UIColor whiteColor]; // 空心颜色
        
        _pieChartView.transparentCircleRadiusPercent = 0.52f; // 半透明空心半径占比
        _pieChartView.transparentCircleColor = [UIColor colorWithRed:210.0f / 255.0f
                                                               green:145.0f / 255.0f
                                                                blue:165.0f / 255.0f
                                                               alpha:0.3f]; // 半透明空心的颜色
        
        // 实心饼状图样式
        _pieChartView.drawHoleEnabled = NO; // 饼状图是否为空心
        
        // 饼状图中间的描述
        if (_pieChartView.isDrawHoleEnabled == YES) {
            _pieChartView.drawCenterTextEnabled = YES; // 是否显示中间的文字
            
            // 普通文本
            _pieChartView.centerText = @"饼状图"; // 中间显示的文字
            
            // 富文本
            NSMutableAttributedString *centerAttributedString = [[NSMutableAttributedString alloc] initWithString:@"饼状图"];
            
            [centerAttributedString setAttributes:@{
                                                    NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0f],
                                                    NSForegroundColorAttributeName: [UIColor orangeColor]
                                                    }
                                            range:NSMakeRange(0.0f, centerAttributedString.length)];
            
            _pieChartView.centerAttributedText = centerAttributedString;
        }
        // 饼状图描述
        _pieChartView.descriptionText = @"";
        _pieChartView.descriptionFont = [UIFont systemFontOfSize:10];
        _pieChartView.descriptionTextColor = [UIColor grayColor];
                // 饼状图图例
        _pieChartView.legend.maxSizePercent = 5.0f; // 图例在饼状图中的大小占比, 这会影响图例的宽高
        _pieChartView.legend.formToTextSpace = 5.0f; // 文本间隔
        _pieChartView.legend.font = [UIFont systemFontOfSize:10.0f]; // 字体大小
        _pieChartView.legend.textColor = [UIColor whiteColor]; // 字体颜色
        _pieChartView.legend.position = ChartLegendPositionBelowChartLeft; // 图例在饼状图中的位置
        _pieChartView.legend.form = ChartLegendFormSquare; // 图示样式: 方形、线条、圆形
        _pieChartView.legend.formSize = 0.0f; // 图示大小
        
        // 为饼状图提供数据
        _pieChartView.data = _pieChartData;
        
        // 设置动画效果
        [_pieChartView animateWithXAxisDuration:1.0f
                                   easingOption:ChartEasingOptionEaseOutExpo];
        
    }
    return self;
}
- (void)setChartDataDic:(NSDictionary *)chartDataDic
{
    _dic = chartDataDic;
    NSMutableArray *addArr = [NSMutableArray new];
    if (kIsDictionary(chartDataDic)) {
        NSString *morningData =[chartDataDic objectForKey:@"breakfast"];
        NSString *lunchData = [chartDataDic objectForKey:@"lunch"];
        NSString *dinner = [chartDataDic objectForKey:@"dinner"];
        NSString *snack = [chartDataDic objectForKey:@"supper"];
        _totalCalorie  = [[chartDataDic objectForKey:@"totalCalorie"] integerValue];
        [addArr addObject:morningData];
        [addArr addObject:lunchData];
        [addArr addObject:dinner];
        [addArr addObject:snack];
    }
    // 每个区块的数据 //addArr 饼状图组成数目
    NSMutableArray *yValues = [[NSMutableArray alloc] init];
    for (int i = 0; i < addArr.count; i++) {
        NSString *add = [NSString stringWithFormat:@"%@",addArr[i]];
        double randomValue = [add doubleValue];
        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithValue:randomValue xIndex:i];
        [yValues addObject:entry];
    }
    
    // 每个区块的名称或描述
    NSMutableArray *xValues = [[NSMutableArray alloc] init];
//    NSArray *titleArr = @[@"早餐",@"午餐",@"晚餐",@"加餐"];
    for (int i = 0; i < addArr.count; i++) {
        NSString *title = [NSString stringWithFormat:@"%@", addArr[i]];
        [xValues addObject:title];
    }
    // DataSet
    PieChartDataSet *dataSet =[[PieChartDataSet alloc]initWithYVals:yValues label:@""];
    
    dataSet.drawValuesEnabled = NO; // 是否绘制显示数据
    
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObject:[UIColor colorWithHex:0xFCD03F alpha:1]];
    [colors addObject:[UIColor colorWithHex:0xFE6C6E alpha:1]];
    [colors addObject:[UIColor colorWithHex:0xFF9E36 alpha:1]];
    [colors addObject:[UIColor colorWithHex:0x1CDEB1 alpha:1]];
    dataSet.colors = colors; // 区块颜色
    
    dataSet.sliceSpace = 0.5f; // 相邻区块之间的间距
    
    dataSet.selectionShift = 1.0f; // 选中区块时, 放大的半径
    
    dataSet.xValuePosition = PieChartValuePositionInsideSlice; // 名称位置
    dataSet.yValuePosition = PieChartValuePositionOutsideSlice; // 数据位置
    
    // 数据与区块之间的用于指示的折线样式
    dataSet.valueLinePart1OffsetPercentage = 0.90f; // 折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
    
    dataSet.valueLinePart1Length = 0.5f; // 折线中第一段长度占比
    dataSet.valueLinePart2Length = 0.4f; // 折线中第二段长度占比
    
    dataSet.valueLineWidth = 1; // 折线的粗细
    
    dataSet.valueLineColor = UIColorHex(0x939393); // 折线颜色
    //将BarChartDataSet对象放入数组中
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:dataSet];
    
    // PieChartData
    PieChartData *pieChartData = [[PieChartData alloc]initWithXVals:xValues dataSets:dataSets];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    formatter.maximumFractionDigits = 0; // 小数位数
    formatter.multiplier = @03.f;
    
    [pieChartData setValueTextColor:[UIColor whiteColor]];
    
    [pieChartData setValueFont:[UIFont systemFontOfSize:12]];
    
    _pieChartView.data = pieChartData;
    [_pieChartView notifyDataSetChanged];
}

@end
