//
//  TMPChartViewController.swift
//  Product
//
//  Created by WuJiezhong on 16/5/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit
import Charts

class TMPChartViewController: LightStatusBarViewController,ChartViewDelegate {
    
    var tempDevice: ThermometerModel!

    
    @IBOutlet weak var dateSegment: UISegmentedControl!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var lineHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var chartView: LineChartView!
    ///最高体温
    @IBOutlet weak var highestTempLabel: UILabel!
    ///平均体温
    @IBOutlet weak var averageTempLabel: UILabel!
    ///最低体温
    @IBOutlet weak var lowestTempLabel: UILabel!
    
    @IBOutlet weak var weekCycleContainerView: UIView!
    @IBOutlet var weekCycleButtons: [UIButton]!
    
    @IBOutlet weak var dayCycleContainerView: UIView!
    @IBOutlet var dayCycleButtons: [UIButton]!
    var dayCycleDates:[NSDate]!
    
    ///当前周的开始date，底部button被选中的开始日期
    private var curWeekStartDate: NSDate!
    ///当前周的结束date，底部button被选中的结束日期
    private var curWeekEndDate: NSDate!
    ///周循环的前面date, <箭头位置的
    private var curWeekCyclePrevDate: NSDate!
    ///周循环的后面date， >箭头位置的
    private var curWeekCycleNextDate: NSDate!
    ///日循环的当前date
    private var curDayCycleDate: NSDate!
    
    private var curDataEntryItems: [DataEntryItem]?
    
    
    let guardLimitColor = UIColor(hex:0xF90E1B)
    var guardLimitValue = 37.5
    
    
    class func viewControllerFromSB() -> TMPChartViewController {
        return UIStoryboard(name: "Thermometer", bundle: nil).instantiateViewControllerWithIdentifier("TMPChartViewController") as! TMPChartViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseTitle = "曲线分析"
        guardLimitValue = Double(self.tempDevice.downFever)/10.0
        
        initViews()
        //今天
        curWeekCycleNextDate = NSDate()
        curDayCycleDate = NSDate()
        self.setDateForCurrent(curDayCycleDate)
    }
    
    private func initViews() {
        lineHeightConstraints.constant = singleLineWidth
        self.view.layer.contents = UIImage(named: "背景")?.CGImage
        for button in weekCycleButtons + dayCycleButtons {
            button.layer.cornerRadius = 4
        }
        
        //init chart view
        chartView.descriptionText       = "";
        chartView.noDataTextDescription = "数据加载中..."
        chartView.noDataText            = ""
        chartView.infoFont              = UIFont.systemFontOfSize(16)
        chartView.infoTextColor         = UIColor(hex: 0xD5D5D5)
        
        chartView.dragEnabled               = true
        chartView.scaleXEnabled             = true
        chartView.scaleYEnabled             = false
        chartView.pinchZoomEnabled          = false
        chartView.doubleTapToZoomEnabled    = false
        chartView.drawGridBackgroundEnabled = false
        chartView.rightAxis.enabled         = false
        chartView.legend.enabled            = false
        chartView.extraLeftOffset           = 30;
        chartView.extraRightOffset          = 50;
        chartView.extraBottomOffset         = 30;
        chartView.extraTopOffset            = 50;
        chartView.xAxis.enabled             = false
        chartView.leftAxis.axisMaxValue     = 43;
        chartView.leftAxis.axisMinValue     = 31;
        chartView.leftAxis.enabled          = true
        chartView.leftAxis.labelTextColor   = .whiteColor()
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.delegate                  = self
        
        let formatter = NSNumberFormatter()
        formatter.allowsFloats = false
        chartView.leftAxis.valueFormatter = formatter
        
        let marker = BalloonMarker(color: UIColor.blackColor().colorWithAlphaComponent(0.4), font: UIFont.systemFontOfSize(12), insets: UIEdgeInsetsMake(8.0, 8, 8.0, 8))
        marker.minimumSize = CGSizeMake(20, 10)
        marker.arrowSize   = CGSizeMake(40, 20)
        marker.guardLimitColor = self.guardLimitColor
        marker.guardLimitValue = self.guardLimitValue
        marker.valueIsAvarage  = false
        chartView.marker = marker
        
        //
        let limitLine = ChartLimitLine(limit: guardLimitValue)
        limitLine.lineWidth = 1.0
        limitLine.lineColor = guardLimitColor
        
        chartView.leftAxis.addLimitLine(limitLine)
    }
    
    private func setDateForCurrent(currentDate: NSDate) {
        
        let marker = BalloonMarker(color: UIColor.blackColor().colorWithAlphaComponent(0.4), font: UIFont.systemFontOfSize(12), insets: UIEdgeInsetsMake(8.0, 8, 8.0, 8))
        marker.minimumSize = CGSizeMake(20, 10)
        marker.arrowSize   = CGSizeMake(40, 20)
        marker.guardLimitColor = self.guardLimitColor
        marker.guardLimitValue = self.guardLimitValue
        
        if dateSegment.selectedSegmentIndex == 0 {
            marker.valueIsAvarage = false
            chartView.marker = marker
            curDayCycleDate = currentDate
            dateLabel.text = self.dayCycleDateDescription(curDayCycleDate)
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd"
            let curDateButtonTitle = formatter.stringFromDate(curDayCycleDate)
            ///在底部的buttons中是否存在当前选择的天
            var existCurDateInButtons = false
            
            if dayCycleDates == nil {
                dayCycleDates = [NSDate]()
                for button in dayCycleButtons {
                    let offsetByDay = dayCycleButtons.count - button.tag - 1
                    let offsetInterval = -86400 * NSTimeInterval(offsetByDay)
                    let theDate = NSDate(timeInterval: offsetInterval, sinceDate: currentDate)
                    
                    let title = formatter.stringFromDate(theDate)
                    button .setTitle(title, forState: .Normal)
                    dayCycleDates.append(theDate)
                }
                selectedDayCycleButton(dayCycleButtons.last!)
            }
            
            for button in dayCycleButtons {
                if button.titleLabel?.text == curDateButtonTitle {
                    existCurDateInButtons = true
                    selectedDayCycleButton(button)
                }
            }
            
            if !existCurDateInButtons {
                dayCycleDates = [NSDate]()
                for button in dayCycleButtons {
                    let offsetByDay = dayCycleButtons.count - button.tag - 1
                    let offsetInterval = -86400 * NSTimeInterval(offsetByDay)
                    let theDate = NSDate(timeInterval: offsetInterval, sinceDate: currentDate)
                    
                    let title = formatter.stringFromDate(theDate)
                    button .setTitle(title, forState: .Normal)
                    dayCycleDates.append(theDate)
                }
                selectedDayCycleButton(dayCycleButtons.last!)
            }
            
        } else {
            marker.valueIsAvarage = true
            chartView.marker = marker
            curWeekCycleNextDate = currentDate
            ///35天前, 86400是一天的秒数
            let intervalPass35Days: NSTimeInterval = -34 * 86400
            curWeekCyclePrevDate = NSDate(timeInterval: intervalPass35Days, sinceDate: curWeekCycleNextDate)
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM月dd日"
            let previousStr = formatter.stringFromDate(curWeekCyclePrevDate)
            let nextStr    = formatter.stringFromDate(curWeekCycleNextDate)
            
            dateLabel.text = "\(previousStr) - \(nextStr)"
            
            for button in weekCycleButtons {
                let offsetBy7Day = weekCycleButtons.count - button.tag - 1
                let startDate = self.cycleStartDate(curWeekCycleNextDate, buttonOffsetRightToLeft: offsetBy7Day)
                let endDate = self.cycleEndDate(curWeekCycleNextDate, buttonOffsetRightToLeft: offsetBy7Day)
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = "dd"
                let title = "\(formatter.stringFromDate(startDate))~\(formatter.stringFromDate(endDate))"
                button .setTitle(title, forState: .Normal)
            }
            
            selectedWeekCycleButton(weekCycleButtons.last!)
            curWeekStartDate = self.cycleStartDate(curWeekCycleNextDate, buttonOffsetRightToLeft: weekCycleButtons.count - weekCycleButtons.last!.tag-1)
            curWeekEndDate   = self.cycleEndDate(curWeekCycleNextDate, buttonOffsetRightToLeft: weekCycleButtons.count - weekCycleButtons.last!.tag-1)
            
        }
        self.queryData()
    }
    
    private func cycleStartDate(cycleNextDate: NSDate, buttonOffsetRightToLeft index: Int) -> NSDate {
        let startInterval: NSTimeInterval = -NSTimeInterval(7 * index + 6) * 86400
        return NSDate(timeInterval: startInterval, sinceDate: cycleNextDate)
    }
    
    private func cycleEndDate(cycleNextDate: NSDate, buttonOffsetRightToLeft index: Int) -> NSDate {
        let endInterval: NSTimeInterval = -NSTimeInterval(index) * 7 * 86400
        return NSDate(timeInterval: endInterval, sinceDate: cycleNextDate)
    }
    
    ///日期的描述
    private func dayCycleDateDescription(paramDate: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let yestodayDate = NSDate(timeInterval: -60*60*24, sinceDate: NSDate())
        
        let todayStr = formatter.stringFromDate(NSDate())
        let yestodayStr = formatter.stringFromDate(yestodayDate)
        let dateStr = formatter.stringFromDate(paramDate)
        
        switch dateStr {
        case todayStr:
            return "今天"
        case yestodayStr:
            return "昨天"
        default:
            formatter.dateFormat = "MM月dd日"
            return formatter.stringFromDate(paramDate)
        }
    }
    
    //MARK: - IBAction functions
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func previousButtonClicked(sender: UIButton) {
        let intervalPassDays: NSTimeInterval
        let curNextDate: NSDate
        if dateSegment.selectedSegmentIndex == 0 {
            intervalPassDays = -1 * 86400
            curNextDate = curDayCycleDate
        } else {
            intervalPassDays = -35 * 86400
            curNextDate = curWeekCycleNextDate
        }
        let prevDate = NSDate(timeInterval: intervalPassDays, sinceDate: curNextDate)
        self.setDateForCurrent(prevDate)
    }
    
    @IBAction func nextButtonClicked(sender: UIButton) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.stringFromDate(NSDate())
        
        let curNextDate: NSDate
        let intervalFutureDays: NSTimeInterval
        
        if dateSegment.selectedSegmentIndex == 0 {
            intervalFutureDays = 1 * 86400
            curNextDate = curDayCycleDate
        } else {
            intervalFutureDays = 35 * 86400
            curNextDate = curWeekCycleNextDate
        }
        if formatter.stringFromDate(curNextDate) >= todayStr {   //最后一天
            return
        }
        let prevDate = NSDate(timeInterval: intervalFutureDays, sinceDate: curNextDate)
        self.setDateForCurrent(prevDate)
    }
    
    
    @IBAction func weekCycleButtonsClicked(button: UIButton) {
        selectedWeekCycleButton(button)
        curWeekStartDate = self.cycleStartDate(curWeekCycleNextDate, buttonOffsetRightToLeft: weekCycleButtons.count - button.tag-1)
        curWeekEndDate   = self.cycleEndDate(curWeekCycleNextDate, buttonOffsetRightToLeft: weekCycleButtons.count - button.tag-1)
        self.queryData()
    }
    
    @IBAction func dayCycleButtonsClicked(button: UIButton) {
        selectedDayCycleButton(button)
        let curIndex = button.tag
        setDateForCurrent(dayCycleDates[curIndex])
    }
    
    private func selectedWeekCycleButton(button: UIButton) {
        for _btn in weekCycleButtons where _btn !== button {
            _btn.backgroundColor = nil
            _btn.setTitleColor(.whiteColor(), forState: .Normal)
        }
        button.backgroundColor = .whiteColor()
        button.setTitleColor(UIColor(hex:0xFF8314), forState: .Normal)
    }
    
    private func selectedDayCycleButton(button: UIButton) {
        for _btn in dayCycleButtons where _btn !== button {
            _btn.backgroundColor = nil
            _btn.setTitleColor(.whiteColor(), forState: .Normal)
        }
        button.backgroundColor = .whiteColor()
        button.setTitleColor(UIColor(hex:0xFF8314), forState: .Normal)
    }
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.setDateForCurrent(curDayCycleDate)
            dayCycleContainerView.hidden  = false
            weekCycleContainerView.hidden = true
        } else {
            self.chartView.zoom(0, scaleY: 0, x: 0, y: 0)
            self.setDateForCurrent(curWeekCycleNextDate)
            dayCycleContainerView.hidden  = true
            weekCycleContainerView.hidden = false
        }
    }
    
    //MARK: - 数据库操作
    private func queryData() {
        let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
        guard let userId = userDict["user_id"]?.integerValue else {
            return
        }
        let dayWidth = dateSegment.selectedSegmentIndex == 0 ? 1 : 7
        let oneDay = dateSegment.selectedSegmentIndex == 0 ? curDayCycleDate : curWeekStartDate
        guard let records = DBManager.shareManager()
                                     .readBodyTempRecords(
                                            self.tempDevice,
                                            forOneDay:oneDay,
                                            dayWidth: dayWidth,
                                            loginUserId: userId,
                                            memberUserId: userId
                                        ) as? [BodyTempRecord] else {
            return
        }
        
        //得到折线图的点数组
        if dateSegment.selectedSegmentIndex == 0 {
            self.curDataEntryItems = DataEntryItem.dataEntryItemsFromTempRecords(records)
        } else {
            self.curDataEntryItems = DataEntryItem.dataItemsForDaysFromTempRecords(records, startDate: oneDay)
        }

        //加载表格数据
        self.loadChartData()
        
        dispatch_async(dispatch_get_main_queue(), {
            //设置不可缩放
            self.chartView.setScaleEnabled(false)
            //还原为1：1全点图状态
            self.chartView.zoom(CGFloat(1/self.chartView.scaleX), scaleY: 1, x: 0, y: 0)
            let xCount = self.chartView.xValCount
            if (xCount > 10) {
                let scaleX = (xCount-1)/(10-1);
                let chartWidth = UIScreen.mainScreen().bounds.width - self.chartView.extraLeftOffset - self.chartView.extraRightOffset;
                let minPosX = chartWidth * CGFloat(scaleX - 1);
                print("发大比例：\(scaleX)")
                self.chartView.zoom(CGFloat(scaleX), scaleY: 1, x: minPosX, y: 0)
            } else {
                self.chartView.zoom(1, scaleY: 1, x: 0, y: 0)
            }
            //最右边点高亮
            //找到线
            let heighlight0 = ChartHighlight(xIndex:xCount-1, dataSetIndex:0)
            //点改变
            self.chartView.highlightValues([heighlight0])
        })
        
        //查询最大、最小、平均值
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let max = DBManager.shareManager().queryBodyTemperature(self.tempDevice, forOneDay: oneDay, dayWidth:dayWidth, function: .Max, loginUserId: userId, memberUserId: userId)
            let min = DBManager.shareManager().queryBodyTemperature(self.tempDevice, forOneDay: oneDay, dayWidth:dayWidth, function: .Min, loginUserId: userId, memberUserId: userId)
            let avg = DBManager.shareManager().queryBodyTemperature(self.tempDevice, forOneDay: oneDay, dayWidth:dayWidth, function: .Avg, loginUserId: userId, memberUserId: userId)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.highestTempLabel.text = String(format: "%.1f", max)
                self.averageTempLabel.text = String(format: "%.1f", avg)
                self.lowestTempLabel.text  = String(format: "%.1f", min)
            })
        })
    }
    
    
    private func loadChartData() {
        guard let dataEntries = self.curDataEntryItems else {
            return
        }
        
        var xVals = [String?]()
        var yVals = [ChartDataEntry]()
        var minValue:Double = 100
        var maxValue:Double = -100
        
        for (index, entry) in dataEntries.enumerate() {
            let value = Double(entry.value)
            minValue = min(minValue, value)
            maxValue = max(maxValue, value)
            let yVal = ChartDataEntry(value: value, xIndex: index, data:entry)
            
            xVals.append(entry.date)
            yVals.append(yVal)
        }
        

        chartView.leftAxis.axisMinValue = min(minValue, 31)

        chartView.leftAxis.axisMaxValue = max(maxValue * 1.1, 43)

        
        let dataSet: LineChartDataSet
        if chartView.data?.dataSetCount > 0 {
            dataSet = chartView.data!.dataSets.first as! LineChartDataSet
            dataSet.yVals = yVals
            chartView.data?.xVals = xVals
            
            var colors = [UIColor]()
            for entry in yVals {
                let color = entry.value >= guardLimitValue ? guardLimitColor:UIColor.whiteColor()
                colors.append(color)
            }
            dataSet.circleColors = colors
            
            chartView.notifyDataSetChanged()
        } else {
            dataSet = LineChartDataSet(yVals: yVals, label: nil)
            dataSet.setColor(UIColor.whiteColor())
            dataSet.setCircleColor(UIColor.whiteColor())
            dataSet.lineWidth             = 1.0
            dataSet.circleRadius          = 5.0
            dataSet.drawCircleHoleEnabled = false
            dataSet.drawValuesEnabled     = false
            dataSet.axisDependency        = .Left
            dataSet.drawFilledEnabled     = false
            dataSet.drawVerticalHighlightIndicatorEnabled = false
            dataSet.drawHorizontalHighlightIndicatorEnabled = false
            var colors = [UIColor]()
            for entry in yVals {
                let color = entry.value >= guardLimitValue ? guardLimitColor:UIColor.whiteColor()
                colors.append(color)
            }
            dataSet.circleColors = colors
            
            let data = LineChartData(xVals: xVals, dataSets: [dataSet])
            chartView.data = data
        }
        
    }
    
    func chartTranslated(chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {

    }
    
}
