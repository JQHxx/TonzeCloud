//
//  WeightLineChartView.m
//  Product
//
//  Created by 肖栋 on 17/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "WeightLineChartView.h"
#import "Product-Bridging-Header.h"
#import "Product-Swift.h"
@interface WeightLineChartView ()<ChartViewDelegate,UIScrollViewDelegate>{
    
    NSArray  *array;
    UILabel *rightLabel;
    UIScrollView *scrollerView;
    NSInteger maxY;
    NSInteger heightY;
    NSInteger lowY;
    NSInteger pages ;

}
@property (nonatomic, strong) LineChartView *LineChartView;
@property (nonatomic, strong) LineChartData *data;
@property (nonatomic, strong)  LineChartDataSet *set1;
@end
@implementation WeightLineChartView
- (instancetype)initWithFrame:(CGRect)frame maxY:(NSInteger)maxy title:(NSString *)tilte{
    self = [super initWithFrame:frame];
    if (self) {
        maxY = maxy;
        pages = 1;
        
        CGFloat width = frame.size.width;
        CGFloat heightValue = frame.size.height;

        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, heightValue)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
        titleLabel.text = tilte;
        titleLabel.font = [UIFont systemFontOfSize:15];
        [bgView addSubview:titleLabel];
        
        rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(width-100, 10, 100, 20)];
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.font = [UIFont systemFontOfSize:15];
        [bgView addSubview:rightLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleLabel.bottom+5, width-20, 1)];
        lineLabel.backgroundColor = [UIColor colorWithWhite:0.834 alpha:1.000];
        [bgView addSubview:lineLabel];
        
        scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, lineLabel.bottom+5, width-20, heightValue-40)];
        scrollerView.delegate = self;
        [bgView addSubview:scrollerView];

        UIView *linbgView = [[UIView alloc] initWithFrame:CGRectMake(0, heightValue-20, width, 20)];
        linbgView.backgroundColor = [UIColor whiteColor];
        [bgView addSubview:linbgView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame maxY:(NSInteger)maxy title:(NSString *)tilte height:(NSInteger)height low:(NSInteger)low{
    self = [super initWithFrame:frame];
    if (self) {
        pages = 1;
        maxY = maxy;
        heightY = height;
        lowY = low;
        CGFloat width = frame.size.width;
        CGFloat heightValue = frame.size.height;
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, heightValue)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
        titleLabel.text = tilte;
        titleLabel.font = [UIFont systemFontOfSize:15];
        [bgView addSubview:titleLabel];
        
        rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(width-100, 10, 100, 20)];
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.font = [UIFont systemFontOfSize:15];
        [bgView addSubview:rightLabel];
        
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleLabel.bottom+5, width-20, 1)];
        lineLabel.backgroundColor = [UIColor colorWithWhite:0.834 alpha:1.000];
        [bgView addSubview:lineLabel];
        
        scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, lineLabel.bottom+5, width-20, heightValue-40)];
        scrollerView.delegate = self;
        [bgView addSubview:scrollerView];
        
        UIView *linbgView = [[UIView alloc] initWithFrame:CGRectMake(0, heightValue-20, width, 20)];
        linbgView.backgroundColor = [UIColor whiteColor];
        [bgView addSubview:linbgView];
    }
    return self;
}
/** 滑动结束后调用 */
#pragma mark --UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"--------%f",scrollView.contentOffset.x );
    if (scrollView.contentOffset.x <= 0) {
        pages++;
        if ([_weightLineDelegate respondsToSelector:@selector(weightLineChartView:type:)]) {
            [_weightLineDelegate weightLineChartView:self type:self.type];
        }

    }if (scrollView.contentOffset.x > 320&&pages>1) {
        pages--;
        if ([_weightLineDelegate respondsToSelector:@selector(weightrightLineChartView:type:)]) {
            [_weightLineDelegate weightrightLineChartView:self type:self.type];
        }
        
    }
}
#pragma mark - ChartViewDelegate

//点击选中折线拐点时回调
- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * _Nonnull)highlight{
    NSLog(@"---chartValueSelected---value: %g", entry.value);
}
//没有选中折线拐点时回调
- (void)chartValueNothingSelected:(ChartViewBase * _Nonnull)chartView{
    NSLog(@"---chartValueNothingSelected---");
}
//放大折线图时回调
- (void)chartScaled:(ChartViewBase * _Nonnull)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    NSLog(@"---chartScaled---scaleX:%g, scaleY:%g", scaleX, scaleY);
}
//拖拽折线图时回调
- (void)chartTranslated:(ChartViewBase * _Nonnull)chartView dX:(CGFloat)dX dY:(CGFloat)dY{
    NSLog(@"---chartTranslated---dX:%g, dY:%g", dX, dY);
}
#pragma mark -- setters
- (void)setBloodDataArray:(NSArray *)bloodDataArray{
    [self bloodChart];
    //X轴上面需要显示的数据
    array = [[TJYHelper sharedTJYHelper] getDateFromTodayWithDays:20*_page];
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < bloodDataArray.count; i++) {
        [xVals addObject:[NSString stringWithFormat:@"%@", array[i]]];
    }
    
    //对应Y轴上面需要显示的数据
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < bloodDataArray.count; i++) {
        double mult = [bloodDataArray[i] doubleValue];
        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithValue:mult xIndex:i];
        [yVals addObject:entry];
    }
    
//    LineChartDataSet *set1 = nil;
    //创建LineChartDataSet对象
    if (_set1==nil) {
        _set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@""];
    }
    //设置折线的样式
    
    _set1.lineWidth = 2.0/[UIScreen mainScreen].scale;//折线宽度
    _set1.drawValuesEnabled = YES;//是否在拐点处显示数据
    _set1.valueColors = @[[UIColor brownColor]];//折线拐点处显示数据的颜色
    [_set1 setColor:[UIColor colorWithHexString:@"#ffe9d4"]];//折线颜色
    _set1.drawSteppedEnabled = NO;//是否开启绘制阶梯样式的折线图
    //折线拐点样式
    _set1.drawCirclesEnabled = YES;//是否绘制拐点
    _set1.circleColors = @[[UIColor orangeColor], [UIColor orangeColor]];//拐点颜色
    //拐点中间的空心样式
    _set1.circleRadius = 4.0f;//空心的半径
    _set1.circleHoleColor = [UIColor orangeColor];//空心的颜色
    
    //点击选中拐点的交互样式
    _set1.highlightEnabled = YES;//选中拐点,是否开启高亮效果(显示十字线)
    _set1.highlightColor = [UIColor colorWithHexString:@"#c83c23"];//点击选中拐点的十字线的颜色
    _set1.highlightLineWidth = 1.0/[UIScreen mainScreen].scale;//十字线宽度
    _set1.highlightLineDashLengths = @[@5, @5];//十字线的虚线样式
    
    //将 LineChartDataSet 对象放入数组中
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:_set1];
    
    //创建 LineChartData 对象, 此对象就是lineChartView需要最终数据对象
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:8.f]];//文字字体
    [data setValueTextColor:[UIColor grayColor]];//文字颜色
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    //自定义数据显示格式
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setPositiveFormat:@"#0.0"];
    [data setValueFormatter:formatter];
    
    self.LineChartView.data = data;
    [self.LineChartView animateWithXAxisDuration:2.0f];

}

-(void)setDataArray:(NSArray *)dataArray{
    [self lineChart];
    
    //X轴上面需要显示的数据
    array = [[TJYHelper sharedTJYHelper] getDateFromTodayWithDays:20*_page];
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataArray.count; i++) {
        [xVals addObject:[NSString stringWithFormat:@"%@", array[i]]];
    }
    
    //对应Y轴上面需要显示的数据
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataArray.count; i++) {
        double mult = [dataArray[i] doubleValue];
        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithValue:mult xIndex:i];
        [yVals addObject:entry];
    }
    
        LineChartDataSet *set1 = nil;
        //创建LineChartDataSet对象
        set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@""];
        //设置折线的样式
        
        set1.lineWidth = 2.0/[UIScreen mainScreen].scale;//折线宽度
        set1.drawValuesEnabled = YES;//是否在拐点处显示数据
        set1.valueColors = @[[UIColor brownColor]];//折线拐点处显示数据的颜色
        [set1 setColor:[UIColor colorWithHexString:@"#ffe9d4"]];//折线颜色
        set1.drawSteppedEnabled = NO;//是否开启绘制阶梯样式的折线图
        //折线拐点样式
        set1.drawCirclesEnabled = YES;//是否绘制拐点
        set1.circleColors = @[[UIColor orangeColor], [UIColor orangeColor]];//拐点颜色
        //拐点中间的空心样式
        set1.circleRadius = 4.0f;//空心的半径
        set1.circleHoleColor = [UIColor orangeColor];//空心的颜色
        
        //点击选中拐点的交互样式
        set1.highlightEnabled = YES;//选中拐点,是否开启高亮效果(显示十字线)
        set1.highlightColor = [UIColor colorWithHexString:@"#c83c23"];//点击选中拐点的十字线的颜色
        set1.highlightLineWidth = 1.0/[UIScreen mainScreen].scale;//十字线宽度
        set1.highlightLineDashLengths = @[@5, @5];//十字线的虚线样式
        
        //将 LineChartDataSet 对象放入数组中
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        //创建 LineChartData 对象, 此对象就是lineChartView需要最终数据对象
        LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
        [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:8.f]];//文字字体
        [data setValueTextColor:[UIColor grayColor]];//文字颜色
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        //自定义数据显示格式
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setPositiveFormat:@"#0.0"];
        [data setValueFormatter:formatter];
        
        self.LineChartView.data = data;
        [self.LineChartView animateWithXAxisDuration:2.0f];
}
#pragma mark -- 体重chart
- (void)lineChart{
    //添加LineChartView
    
    scrollerView.contentSize = CGSizeMake((kScreenWidth-20)*3, 0);
    CGPoint position = CGPointMake((kScreenWidth-20)*2, 0);
    
    [scrollerView setContentOffset:position animated:YES];
    
    if (self.LineChartView==nil) {
        self.LineChartView = [[LineChartView alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth-20)*3, 180)];
        self.LineChartView.backgroundColor =  [UIColor whiteColor];
        self.LineChartView.delegate = self;//设置代理
        [scrollerView addSubview:self.LineChartView];
    }
    self.LineChartView.noDataText = @"暂无数据";
    //交互样式
    self.LineChartView.scaleYEnabled = NO;//取消Y轴缩放
    self.LineChartView.doubleTapToZoomEnabled = NO;//取消双击缩放
    self.LineChartView.dragEnabled = NO;//启用拖拽图标
    self.LineChartView.dragDecelerationEnabled = YES;//拖拽后是否有惯性效果
    self.LineChartView.dragDecelerationFrictionCoef = 0.9;//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
    //X轴样式
    ChartXAxis *xAxis = self.LineChartView.xAxis;
    xAxis.axisLineWidth = 1.0/[UIScreen mainScreen].scale;//设置X轴线宽
    xAxis.labelPosition = XAxisLabelPositionBottom;//X轴的显示位置，默认是显示在上面的
    xAxis.drawGridLinesEnabled = NO;//不绘制网格线
    xAxis.spaceBetweenLabels = 1;//设置label间隔
    xAxis.labelTextColor = [UIColor colorWithHexString:@"#057748"];//label文字颜色
    //Y轴样式
    self.LineChartView.rightAxis.enabled = NO;//不绘制右边轴
    self.LineChartView.leftAxis.enabled = NO;
    ChartYAxis *leftAxis = self.LineChartView.leftAxis;//获取左边Y轴
    leftAxis.labelCount = 5;//Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
    leftAxis.forceLabelsEnabled = NO;//不强制绘制指定数量的label
    leftAxis.showOnlyMinMaxEnabled = NO;//是否只显示最大值和最小值
    leftAxis.axisMinValue = 0;//设置Y轴的最小值
    leftAxis.startAtZeroEnabled = YES;//从0开始绘制
    leftAxis.axisMaxValue = maxY;//设置Y轴的最大值
    leftAxis.inverted = NO;//是否将Y轴进行上下翻转
    leftAxis.axisLineWidth = 1.0/[UIScreen mainScreen].scale;//Y轴线宽
    leftAxis.axisLineColor = [UIColor blackColor];//Y轴颜色
    leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];//自定义格式
    leftAxis.valueFormatter.positiveSuffix = @"";//数字后缀单位
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;//label位置
    leftAxis.labelTextColor = [UIColor colorWithHexString:@"#057748"];//文字颜色
    leftAxis.labelFont = [UIFont systemFontOfSize:10.0f];//文字字体
    
    //描述及图例样式
    [self.LineChartView setDescriptionText:@""];
    [self.LineChartView setDescriptionTextColor:[UIColor darkGrayColor]];
    self.LineChartView.legend.form = ChartLegendFormLine;
    self.LineChartView.legend.formSize = 30;
    self.LineChartView.legend.textColor = [UIColor darkGrayColor];
    
    self.LineChartView.data = self.data;
    [self.LineChartView animateWithXAxisDuration:1.0f];


}
- (void)bloodChart{
    scrollerView.contentSize = CGSizeMake((kScreenWidth-20)*3, 0);
    CGPoint position = CGPointMake((kScreenWidth-20)*2, 0);
    
    [scrollerView setContentOffset:position animated:YES];
    //添加LineChartView
    if (self.LineChartView==nil) {
        self.LineChartView = [[LineChartView alloc] initWithFrame: CGRectMake(0, 0, (kScreenWidth-20)*3, 180)];
        self.LineChartView.backgroundColor =  [UIColor whiteColor];
        self.LineChartView.delegate = self;//设置代理
        [scrollerView addSubview:self.LineChartView];
    }
    //基本样式
    self.LineChartView.noDataText = @"暂无数据";
    //交互样式
    self.LineChartView.scaleYEnabled = NO;//取消Y轴缩放
    self.LineChartView.doubleTapToZoomEnabled = NO;//取消双击缩放
    self.LineChartView.dragEnabled = NO;//启用拖拽图标
    
    self.LineChartView.dragDecelerationEnabled = YES;//拖拽后是否有惯性效果
    self.LineChartView.dragDecelerationFrictionCoef = 0.9;//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
    //X轴样式
    ChartXAxis *xAxis = self.LineChartView.xAxis;
    xAxis.axisLineWidth = 1.0/[UIScreen mainScreen].scale;//设置X轴线宽
    xAxis.labelPosition = XAxisLabelPositionBottom;//X轴的显示位置，默认是显示在上面的
    xAxis.drawGridLinesEnabled = NO;//不绘制网格线
    xAxis.spaceBetweenLabels = 1;//设置label间隔
    xAxis.labelTextColor = [UIColor colorWithHexString:@"#057748"];//label文字颜色
    self.LineChartView._maxVisibleValueCount = 5;
    //Y轴样式
    self.LineChartView.rightAxis.enabled = NO;//不绘制右边轴
    self.LineChartView.leftAxis.enabled = NO;
    ChartYAxis *leftAxis = self.LineChartView.leftAxis;//获取左边Y轴
    leftAxis.labelCount = 5;//Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
    leftAxis.forceLabelsEnabled = NO;//不强制绘制指定数量的label
    leftAxis.showOnlyMinMaxEnabled = NO;//是否只显示最大值和最小值
    leftAxis.axisMinValue = 0;//设置Y轴的最小值
    leftAxis.startAtZeroEnabled = YES;//从0开始绘制
    leftAxis.axisMaxValue = maxY;//设置Y轴的最大值
    leftAxis.inverted = NO;//是否将Y轴进行上下翻转
    leftAxis.axisLineWidth = 1.0/[UIScreen mainScreen].scale;//Y轴线宽
    leftAxis.axisLineColor = [UIColor blackColor];//Y轴颜色
    leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];//自定义格式
    leftAxis.valueFormatter.positiveSuffix = @"";//数字后缀单位
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;//label位置
    leftAxis.labelTextColor = [UIColor colorWithHexString:@"#057748"];//文字颜色
    leftAxis.labelFont = [UIFont systemFontOfSize:10.0f];//文字字体
    //添加限制线
    ChartLimitLine *limitLine = [[ChartLimitLine alloc] initWithLimit:heightY label:[NSString stringWithFormat:@"%ld",(long)heightY]];
    limitLine.lineWidth = 1;
    limitLine.lineColor = [UIColor redColor];
    limitLine.lineDashLengths = @[@5.0f, @5.0f];//虚线样式
    limitLine.labelPosition = ChartLimitLabelPositionRightBottom;//位置
    limitLine.valueTextColor = [UIColor colorWithHexString:@"#057748"];//label文字颜色
    limitLine.valueFont = [UIFont systemFontOfSize:12];//label字体
    [leftAxis addLimitLine:limitLine];//添加到Y轴上
    
    //添加限制线
    ChartLimitLine *limitLine2 = [[ChartLimitLine alloc] initWithLimit:lowY label:[NSString stringWithFormat:@"%ld",(long)lowY]];
    limitLine2.lineWidth = 1;
    limitLine2.lineColor = [UIColor greenColor];
    limitLine2.lineDashLengths = @[@5.0f, @5.0f];//虚线样式
    limitLine2.labelPosition = ChartLimitLabelPositionRightBottom;//位置
    limitLine2.valueTextColor = [UIColor colorWithHexString:@"#057748"];//label文字颜色
    limitLine2.valueFont = [UIFont systemFontOfSize:12];//label字体
    [leftAxis addLimitLine:limitLine2];//添加到Y轴上
    leftAxis.drawLimitLinesBehindDataEnabled = YES;//设置限制线绘制在折线图的后面
    
    //描述及图例样式
    [self.LineChartView setDescriptionText:@""];
    [self.LineChartView setDescriptionTextColor:[UIColor darkGrayColor]];
    self.LineChartView.legend.form = ChartLegendFormLine;
    self.LineChartView.legend.formSize = 30;
    self.LineChartView.legend.textColor = [UIColor darkGrayColor];
    
    self.LineChartView.data = self.data;
    [self.LineChartView animateWithXAxisDuration:1.0f];
}
@end
