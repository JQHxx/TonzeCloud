//
//  BMPChartViewController.swift
//  Product
//
//  Created by WuJiezhong on 16/5/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit
import Charts

class BMPChartViewController: LightStatusBarViewController,ChartViewDelegate {

    var BPDevice: BPMeterModel!

    @IBOutlet weak var dateSegment: UISegmentedControl!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var lineHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var weekCycleContainer: UIView!
    @IBOutlet var weekCycleButtons: [UIButton]!

    @IBOutlet weak var monthCycleContainer: UIView!
    @IBOutlet var monthCycleButtons: [UIButton]!

    @IBOutlet weak var yearCycleContainer: UIView!
    @IBOutlet var yearCycleButtons: [UIButton]!

    @IBOutlet weak var bottomSegment: UISegmentedControl!
    //显示血压心率的label
    @IBOutlet weak var detailLabel: UILabel!
    
    
    ///当前周
    ///当前周的开始date，底部button被选中的开始日期
    private var curWeekStartDate: NSDate!
    ///当前周的结束date，底部button被选中的结束日期
    private var curWeekEndDate: NSDate!
    ///周循环的前面date, <箭头位置的
    private var curWeekCyclePrevDate: NSDate!
    ///周循环的后面date， >箭头位置的
    private var curWeekCycleNextDate: NSDate!

    ///当前月
    ///当前月的开始date，底部button被选中的开始日期
    private var curMonthStartDate: NSDate!
    ///当前月的结束date，底部button被选中的结束日期
    private var curMonthEndDate: NSDate!
    ///月循环的前面date, <箭头位置的
    private var curMonthCyclePrevDate: NSDate!
    ///月循环的后面date， >箭头位置的
    private var curMonthCycleNextDate: NSDate!

    ///当前年
    ///当前年的开始date，底部button被选中的开始日期
    private var curYearStartDate: NSDate!
    ///当前年的结束date，底部button被选中的结束日期
    private var curYearEndDate: NSDate!
    ///年循环的前面date, <箭头位置的
    private var curYearCyclePrevDate: NSDate!
    ///年循环的后面date， >箭头位置的
    private var curYearCycleNextDate: NSDate!

    ///图表的模型，ture为血压曲线图，false为心率曲线图
    private var lineModel: Bool!

    private var curDataEntryItems: [BPRecordEntry]?

    let guardLimitColor = UIColor(hex:0xF90E1B)
    let guardLimitValue = 200.0
    
    class func viewControllerFromSB() -> BMPChartViewController {
        return UIStoryboard(name: "BPMeter", bundle: nil).instantiateViewControllerWithIdentifier("BMPChartViewController") as! BMPChartViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.baseTitle="曲线分析"
        
        lineHeightConstraints.constant = singleLineWidth
        self.view.layer.contents = UIImage(named: "背景")?.CGImage
        
        self.initViews()
        self.loadChartData()
        
        //今天
        curWeekCycleNextDate = NSDate()
        curWeekStartDate = NSDate()
        curMonthCycleNextDate = NSDate()
        curMonthStartDate = NSDate()
        curMonthCyclePrevDate = NSDate()
        curYearCycleNextDate = NSDate()
        curYearStartDate = NSDate()
        curYearCyclePrevDate = NSDate()
        //默认显示血压曲线图
        lineModel = true
        let startInterval: NSTimeInterval = -7 * 86400
        curWeekEndDate = NSDate(timeInterval: startInterval, sinceDate: NSDate())
        self.setDateForCurrent(curWeekStartDate)
        self.chooseIndexOfdataSets(6)

    }
    
    
    @IBAction func previousButtonClicked(sender: UIButton) {
        let intervalPassDays: NSTimeInterval
        let curNextDate: NSDate
        
        chartView.highlightValues([])
//        self.changeLabel([])

        if dateSegment.selectedSegmentIndex == 0 {
            intervalPassDays = -7 * 86400
            curNextDate = curWeekCycleNextDate
            let prevDate = NSDate(timeInterval: intervalPassDays, sinceDate: curNextDate)
            self.setDateForCurrent(prevDate)
            self.chooseIndexOfdataSets(6)
        } else if dateSegment.selectedSegmentIndex == 1 {
            intervalPassDays = -30 * 86400
            curNextDate = curMonthCycleNextDate
            let prevDate = NSDate(timeInterval: intervalPassDays, sinceDate: curNextDate)
            self.setDateForCurrent(prevDate)
            self.chooseIndexOfdataSets(5)
        }
        else {
            self.setDateForCurrent(self.cycleNextMonthDate(curYearCycleNextDate, buttonOffsetRightToLeft: 12))
            self.chooseIndexOfdataSets(11)
        }
    }
    
    @IBAction func nextButtonClicked(sender: UIButton) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.stringFromDate(NSDate())
        
        let curNextDate: NSDate
        let intervalFutureDays: NSTimeInterval
        
        chartView.highlightValues([])
//        self.changeLabel([])
        
        var index = 0
        

        if dateSegment.selectedSegmentIndex == 0 {
            intervalFutureDays = 7 * 86400
            curNextDate = curWeekCycleNextDate
            index = 6
        } else if dateSegment.selectedSegmentIndex == 1 {
            intervalFutureDays = 30 * 86400
            curNextDate = curMonthCycleNextDate
            index = 5
        } else {
//            intervalFutureDays = 365 * 86400
//            curNextDate = curYearCycleNextDate
            let nextDate = self.cycleNextMonthDate(curYearCycleNextDate, buttonOffsetRightToLeft: -12)
            if NSDate.getYearFromDate(nextDate) as Int > NSDate.getYearFromDate(NSDate()) as Int {
                return
            }else{
                self.setDateForCurrent(nextDate)
                self.chooseIndexOfdataSets(11)
            }
            return
        }
        if formatter.stringFromDate(curNextDate) >= todayStr {   //最后一天
            return
        }
        let prevDate = NSDate(timeInterval: intervalFutureDays, sinceDate: curNextDate)
        self.setDateForCurrent(prevDate)
        
        self.chooseIndexOfdataSets(index)

    }

    private func initViews() {
        lineHeightConstraints.constant = singleLineWidth
        self.view.layer.contents = UIImage(named: "背景")?.CGImage
        for button in weekCycleButtons + monthCycleButtons + yearCycleButtons {
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
        chartView.leftAxis.axisMaxValue     = 240;
        chartView.leftAxis.axisMinValue     = 30;
        chartView.leftAxis.enabled          = true
        chartView.leftAxis.labelTextColor   = .whiteColor()
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.delegate                  = self
        
        let formatter = NSNumberFormatter()
        formatter.allowsFloats = false
        chartView.leftAxis.valueFormatter = formatter
        
        let marker = BPMarker(color: UIColor.blackColor().colorWithAlphaComponent(0.4), font: UIFont.systemFontOfSize(12), insets: UIEdgeInsetsMake(0, 0, 0, 0))
        marker.minimumSize = CGSizeMake(0, 0)
        marker.arrowSize   = CGSizeMake(0, 0)
        marker.valueIsAvarage  = false
        chartView.marker = marker
        
        weekCycleContainer.hidden = false
        monthCycleContainer.hidden = true
        yearCycleContainer.hidden = true
        
    }

    //MARK: - 数据库操作
    private func queryData() {
        let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
        guard let userId = userDict["user_id"]?.integerValue else {
            return
        }
        
        let oneDay = dateSegment.selectedSegmentIndex == 0 ? curWeekCyclePrevDate : dateSegment.selectedSegmentIndex == 1 ? curMonthCyclePrevDate : curYearCyclePrevDate
        let otherDay = dateSegment.selectedSegmentIndex == 0 ? curWeekCycleNextDate : dateSegment.selectedSegmentIndex == 1 ? curMonthCycleNextDate : curYearCycleNextDate
        

        guard let records = DBManager.shareManager().readBPRecords(
        self.BPDevice,
        fromeOneDay: oneDay,
        toOtherDay: otherDay,
        loginUserId: userId,
        memberUserId: userId
            ) as? [BPRecord] else {
                return
        }
        
        //得到折线图的点数组
        if dateSegment.selectedSegmentIndex == 0 {
            self.curDataEntryItems = BPRecordEntry.recordEntries(records, type: .Week, startDate: oneDay)
        } else if dateSegment.selectedSegmentIndex == 1 {
            self.curDataEntryItems = BPRecordEntry.recordEntries(records,type: .Month, startDate: oneDay)
        } else if dateSegment.selectedSegmentIndex == 2 {
            self.curDataEntryItems = BPRecordEntry.recordEntries(records,type: .Year, startDate: oneDay)
        }
        
        //加载表格数据
        self.loadChartData()
        
    }
    
    private func loadChartData() {
        guard let dataEntries = self.curDataEntryItems else {
            return
        }
        
        var xVals = [String?]()
        var ySBPVals = [ChartDataEntry]()
        var yDBPVals = [ChartDataEntry]()
        var yHRVals = [ChartDataEntry]()
        var minSBPValue:UInt16 = 100
        var maxSBPValue:UInt16 = 1
        var minDBPValue:UInt16 = 200
        var maxDBPValue:UInt16 = 1
        var minHRValue:UInt16 = 100
        var maxHRValue:UInt16 = 1
        
        for (index, entry) in dataEntries.enumerate() {
            let sbpValve = UInt16(entry.SBP)
            let dbpValve = UInt16(entry.DBP)
            let hrValve = UInt16(entry.heartRate)
            minSBPValue = min(minSBPValue, sbpValve)
            maxSBPValue = max(maxSBPValue, sbpValve)
            minDBPValue = min(minDBPValue, dbpValve)
            maxDBPValue = max(maxDBPValue, dbpValve)
            minHRValue = min(minHRValue, hrValve)
            maxHRValue = max(maxHRValue, hrValve)
            let ySBPVal = ChartDataEntry(value: Double(sbpValve), xIndex: index, data:entry)
            let yDBPVal = ChartDataEntry(value: Double(dbpValve), xIndex: index, data:entry)
            let yHRVal = ChartDataEntry(value: Double(hrValve), xIndex: index, data:entry)
            xVals.append(entry.date)
            ySBPVals.append(ySBPVal)
            yDBPVals.append(yDBPVal)
            yHRVals.append(yHRVal)
        }
        
        if Double(minSBPValue) < chartView.leftAxis.axisMinValue {
            chartView.leftAxis.axisMinValue = Double(minSBPValue)
        }
        if Double(maxSBPValue) > chartView.leftAxis.axisMaxValue {
            chartView.leftAxis.axisMaxValue = Double(maxSBPValue) * 1.1
        }
        if Double(minDBPValue) < chartView.leftAxis.axisMinValue {
            chartView.leftAxis.axisMinValue = Double(minDBPValue)
        }
        if Double(maxDBPValue) > chartView.leftAxis.axisMaxValue {
            chartView.leftAxis.axisMaxValue = Double(maxDBPValue) * 1.1
        }
        if Double(minHRValue) < chartView.leftAxis.axisMinValue {
            chartView.leftAxis.axisMinValue = Double(minHRValue)
        }
        if Double(maxHRValue) > chartView.leftAxis.axisMaxValue {
            chartView.leftAxis.axisMaxValue = Double(maxHRValue) * 1.1
        }
        
        let dataSBPSet: LineChartDataSet
        let dataDBPSet: LineChartDataSet
        let dataHRSet: LineChartDataSet
        if chartView.data?.dataSetCount > 0 {
            
            //SBP
            dataSBPSet = chartView.data!.dataSets.first as! LineChartDataSet
            dataSBPSet.yVals = ySBPVals
            //DBP
            if chartView.data?.dataSets.count > 1 {
                dataDBPSet = chartView.data!.dataSets[1] as! LineChartDataSet
            }else{
                dataDBPSet = LineChartDataSet(yVals: yDBPVals, label: nil)
                dataDBPSet.setColor(UIColor.whiteColor())
                dataDBPSet.setCircleColor(UIColor.whiteColor())
                dataDBPSet.lineWidth             = 1.0
                dataDBPSet.circleRadius          = 5.0
                dataDBPSet.drawCircleHoleEnabled = false
                dataDBPSet.drawValuesEnabled     = false
                dataDBPSet.axisDependency        = .Left
                dataDBPSet.drawFilledEnabled     = false
                dataDBPSet.drawVerticalHighlightIndicatorEnabled = false
                dataDBPSet.drawHorizontalHighlightIndicatorEnabled = false
//                dataDBPSet = chartView.data!.dataSets.first as! LineChartDataSet
            }
            dataDBPSet.yVals = yDBPVals

            //HR
            if lineModel == false {
                dataHRSet = chartView.data!.dataSets.first as! LineChartDataSet
                dataHRSet.yVals = yHRVals
            }else{
                dataHRSet = LineChartDataSet(yVals: yHRVals, label: nil)
            }
            
            chartView.data?.xVals = xVals
            
            var colors = [UIColor]()
            for _ in ySBPVals {
//                let color = entry.value >= guardLimitValue ? guardLimitColor:UIColor.whiteColor()
                let color = UIColor.whiteColor()
                colors.append(color)
            }
            dataSBPSet.circleColors = colors
            dataDBPSet.circleColors = colors
            dataHRSet.circleColors = colors
            let data : ChartData
            if lineModel == true {
                data = LineChartData(xVals: xVals, dataSets: [dataSBPSet,dataDBPSet])
            }else{
                data = LineChartData(xVals: xVals, dataSets: [dataHRSet])
            }
            chartView.data = data
            chartView.notifyDataSetChanged()
        } else {
            //第一次进入界面，进入
            dataSBPSet = LineChartDataSet(yVals: ySBPVals, label: nil)
            dataSBPSet.setColor(UIColor.whiteColor())
            dataSBPSet.setCircleColor(UIColor.whiteColor())
            dataSBPSet.lineWidth             = 1.0
            dataSBPSet.circleRadius          = 5.0
            dataSBPSet.drawCircleHoleEnabled = false
            dataSBPSet.drawValuesEnabled     = false
            dataSBPSet.axisDependency        = .Left
            dataSBPSet.drawFilledEnabled     = false
            dataSBPSet.drawVerticalHighlightIndicatorEnabled = false
            dataSBPSet.drawHorizontalHighlightIndicatorEnabled = false
            
            dataDBPSet = LineChartDataSet(yVals: yDBPVals, label: nil)
            dataDBPSet.setColor(UIColor.whiteColor())
            dataDBPSet.setCircleColor(UIColor.whiteColor())
            dataDBPSet.lineWidth             = 1.0
            dataDBPSet.circleRadius          = 5.0
            dataDBPSet.drawCircleHoleEnabled = false
            dataDBPSet.drawValuesEnabled     = false
            dataDBPSet.axisDependency        = .Left
            dataDBPSet.drawFilledEnabled     = false
            dataDBPSet.drawVerticalHighlightIndicatorEnabled = false
            dataDBPSet.drawHorizontalHighlightIndicatorEnabled = false
            
            var colors = [UIColor]()
            for _ in ySBPVals {
//                let color = entry.value >= guardLimitValue ? guardLimitColor:UIColor.whiteColor()
                let color = UIColor.whiteColor()
                colors.append(color)
            }
            dataSBPSet.circleColors = colors
            dataDBPSet.circleColors = colors
            
            let data = LineChartData(xVals: xVals, dataSets: [dataSBPSet,dataDBPSet])
            chartView.data = data
            
        }
        
    }
    
    @IBAction func weekCycleButtonsClicked(button: UIButton) {
        selectedWeekCycleButton(button)
        curWeekStartDate = self.cycleWeekStartDate(curWeekCycleNextDate, buttonOffsetRightToLeft: weekCycleButtons.count - button.tag-1)
        curWeekEndDate   = self.cycleWeekEndDate(curWeekCycleNextDate, buttonOffsetRightToLeft: weekCycleButtons.count - button.tag-1)
        self.queryData()
        self.chooseIndexOfdataSets(button.tag)
    }
    
    @IBAction func monthCycleButtonsClicked(button: UIButton) {
        selectedMonthCycleButton(button)
        curMonthStartDate = self.cycleMonthStartDate(curMonthCycleNextDate, buttonOffsetRightToLeft: monthCycleButtons.count - button.tag-1)
        curMonthEndDate   = self.cycleMonthEndDate(curMonthCycleNextDate, buttonOffsetRightToLeft: monthCycleButtons.count - button.tag-1)
        self.queryData()
        self.chooseIndexOfdataSets(button.tag)
    }

    @IBAction func yearCycleButtonsClicked(button: UIButton) {
        selectedYearCycleButton(button)
        curYearStartDate = self.cycleNextMonthDate(curYearCycleNextDate, buttonOffsetRightToLeft: yearCycleButtons.count - button.tag-1)
        curYearEndDate   = self.cycleNextMonthDate(curYearCycleNextDate, buttonOffsetRightToLeft: monthCycleButtons.count - button.tag-1)
        self.queryData()
        self.chooseIndexOfdataSets(button.tag)
    }
    
    private func selectedWeekCycleButton(button: UIButton) {
        for _btn in weekCycleButtons where _btn !== button {
            _btn.backgroundColor = nil
            _btn.setTitleColor(.whiteColor(), forState: .Normal)
        }
        button.backgroundColor = .whiteColor()
        button.setTitleColor(UIColor(hex:0xFF8314), forState: .Normal)
    }
    
    private func selectedMonthCycleButton(button: UIButton) {
        for _btn in monthCycleButtons where _btn !== button {
            _btn.backgroundColor = nil
            _btn.setTitleColor(.whiteColor(), forState: .Normal)
        }
        button.backgroundColor = .whiteColor()
        button.setTitleColor(UIColor(hex:0xFF8314), forState: .Normal)
    }
    
    private func selectedYearCycleButton(button: UIButton) {
        for _btn in yearCycleButtons where _btn !== button {
            _btn.backgroundColor = nil
            _btn.setTitleColor(.whiteColor(), forState: .Normal)
        }
        button.backgroundColor = .whiteColor()
        button.setTitleColor(UIColor(hex:0xFF8314), forState: .Normal)
    }

    @IBAction func segmentCycleChanged(sender: UISegmentedControl) {
        
        chartView.highlightValues([])
//        self.changeLabel([])

        if sender.selectedSegmentIndex == 0 {
            self.setDateForCurrent(curWeekCycleNextDate)
            weekCycleContainer.hidden  = false
            monthCycleContainer.hidden = true
            yearCycleContainer.hidden = true
            self.chooseIndexOfdataSets(6)
        } else if sender.selectedSegmentIndex == 1 {
            self.chartView.zoom(0, scaleY: 0, x: 0, y: 0)
            self.setDateForCurrent(curMonthCycleNextDate)
            weekCycleContainer.hidden  = true
            monthCycleContainer.hidden = false
            yearCycleContainer.hidden = true
            self.chooseIndexOfdataSets(5)
        } else if sender.selectedSegmentIndex == 2 {
            self.chartView.zoom(0, scaleY: 0, x: 0, y: 0)
            self.setDateForCurrent(curYearCycleNextDate)
            weekCycleContainer.hidden  = true
            monthCycleContainer.hidden = true
            yearCycleContainer.hidden = false
            self.chooseIndexOfdataSets(11)
        }
    }
    
    @IBAction func segmentBPAndHeartbeatChanged(sender: UISegmentedControl) {
        
        chartView.highlightValues([])
//        self.changeLabel([])
        
        if sender.selectedSegmentIndex == 0 {
            self.lineModel = true
        } else {
            self.lineModel = false
        }
        
        self.chartView.zoom(0, scaleY: 0, x: 0, y: 0)
        self.queryData()
        
        if dateSegment.selectedSegmentIndex == 0 {
            self.chooseIndexOfdataSets(6)
        }else if dateSegment.selectedSegmentIndex == 1{
            self.chooseIndexOfdataSets(5)
        }else if dateSegment.selectedSegmentIndex == 2{
            self.chooseIndexOfdataSets(11)
        }
    }

    private func cycleStartDate(cycleNextDate: NSDate, buttonOffsetRightToLeft index: Int) -> NSDate {
        let startInterval: NSTimeInterval = -NSTimeInterval(5 * index + 4) * 86400
        return NSDate(timeInterval: startInterval, sinceDate: cycleNextDate)
    }
    
    private func cycleEndDate(cycleNextDate: NSDate, buttonOffsetRightToLeft index: Int) -> NSDate {
        let endInterval: NSTimeInterval = -NSTimeInterval(index) * 5 * 86400
        return NSDate(timeInterval: endInterval, sinceDate: cycleNextDate)
    }

    
    private func cycleWeekStartDate(cycleNextDate: NSDate, buttonOffsetRightToLeft index: Int) -> NSDate {
        let startInterval: NSTimeInterval = -NSTimeInterval(7 * index + 6) * 86400
        return NSDate(timeInterval: startInterval, sinceDate: cycleNextDate)
    }
    
    private func cycleWeekEndDate(cycleNextDate: NSDate, buttonOffsetRightToLeft index: Int) -> NSDate {
        let endInterval: NSTimeInterval = -NSTimeInterval(index) * 7 * 86400
        return NSDate(timeInterval: endInterval, sinceDate: cycleNextDate)
    }

    private func cycleMonthStartDate(cycleNextDate: NSDate, buttonOffsetRightToLeft index: Int) -> NSDate {
        let startInterval: NSTimeInterval = -NSTimeInterval(30 * index + 29) * 86400
        return NSDate(timeInterval: startInterval, sinceDate: cycleNextDate)
    }
    
    private func cycleMonthEndDate(cycleNextDate: NSDate, buttonOffsetRightToLeft index: Int) -> NSDate {
        let endInterval: NSTimeInterval = -NSTimeInterval(index) * 30 * 86400
        return NSDate(timeInterval: endInterval, sinceDate: cycleNextDate)
    }
    
    //获取上index天
    private func cycleNextDate(cycleNextDate: NSDate, buttonOffsetRightToLeft index: Int) -> NSDate {
        let startInterval: NSTimeInterval = -NSTimeInterval(index) * 86400
        return NSDate(timeInterval: startInterval, sinceDate: cycleNextDate)
    }

    //获取上index月(index = 1\2\3··· -1\-2\-3···)
    private func cycleNextMonthDate(cycleNextDate: NSDate, buttonOffsetRightToLeft index: Int) -> NSDate {
        
        //判断年递增还是递减
        let yearIncrease = index < 0 ? 1 : -1
        
        //获取年、月
        let calendar = NSCalendar.currentCalendar()
        let comps = calendar.components(([.Year , .Month]), fromDate: cycleNextDate)
        
        let month = Int(comps.month) - index < 1 ? Int(comps.month) - index + 12 : Int(comps.month) - index
        let year = Int(comps.month) - index < 1 ? Int(comps.year) + yearIncrease : Int(comps.year)
        
        let components = NSDateComponents()
        components.second = 0
        components.minute = 0
        components.hour = 0
        components.day = 1
        components.month = month
        components.year = year
        let gregorian = NSCalendar.init(identifier: NSGregorianCalendar)
        
        return (gregorian?.dateFromComponents(components))!
    }
    
    //设置当前的时间，即传入：周、月、年循环的后面date， >箭头位置的
    private func setDateForCurrent(currentDate: NSDate) {
        
        let marker = BPMarker(color: UIColor.blackColor().colorWithAlphaComponent(0.4), font: UIFont.systemFontOfSize(12), insets: UIEdgeInsetsMake(0, 0, 0, 0))
        marker.minimumSize = CGSizeMake(0, 0)
        marker.arrowSize   = CGSizeMake(0, 0)
        marker.guardLimitColor = self.guardLimitColor
        marker.guardLimitValue = self.guardLimitValue
        
        if dateSegment.selectedSegmentIndex == 0 {
            //周
            marker.valueIsAvarage = true
            chartView.marker = marker
            curWeekCycleNextDate = currentDate
            ///6天前, 86400是一天的秒数
            let intervalPass7Days: NSTimeInterval = -6 * 86400
            curWeekCyclePrevDate = NSDate(timeInterval: intervalPass7Days, sinceDate: curWeekCycleNextDate)
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M月d日"
            let previousStr = formatter.stringFromDate(curWeekCyclePrevDate)
            let nextStr    = formatter.stringFromDate(curWeekCycleNextDate)
            
            dateLabel.text = "\(previousStr) - \(nextStr)"
            
            for button in weekCycleButtons {
                let offsetByDay = weekCycleButtons.count - button.tag - 1
                let startDate = self.cycleNextDate(curWeekCycleNextDate, buttonOffsetRightToLeft: offsetByDay)
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = "d"
                let title = "\(formatter.stringFromDate(startDate))"
                button .setTitle(title, forState: .Normal)
                button.titleLabel?.font = UIFont.systemFontOfSize(13)
            }
            
            selectedWeekCycleButton(weekCycleButtons.last!)
            curWeekStartDate = self.cycleWeekStartDate(curWeekCycleNextDate, buttonOffsetRightToLeft: weekCycleButtons.count - weekCycleButtons.last!.tag-1)
            curWeekEndDate   = self.cycleWeekEndDate(curWeekCycleNextDate, buttonOffsetRightToLeft: weekCycleButtons.count - weekCycleButtons.last!.tag-1)
            
        } else if dateSegment.selectedSegmentIndex == 1 {
            //月
            marker.valueIsAvarage = true
            chartView.marker = marker
            curMonthCycleNextDate = currentDate
            ///30天前, 86400是一天的秒数
            let intervalPass30Days: NSTimeInterval = -29 * 86400
            curMonthCyclePrevDate = NSDate(timeInterval: intervalPass30Days, sinceDate: curMonthCycleNextDate)
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M月d日"
            let previousStr = formatter.stringFromDate(curMonthCyclePrevDate)
            let nextStr    = formatter.stringFromDate(curMonthCycleNextDate)
            
            dateLabel.text = "\(previousStr) - \(nextStr)"
            
            for button in monthCycleButtons {
                let offsetBy5Day = monthCycleButtons.count - button.tag - 1
                let startDate = self.cycleStartDate(curMonthCycleNextDate, buttonOffsetRightToLeft: offsetBy5Day)
                let endDate = self.cycleEndDate(curMonthCycleNextDate, buttonOffsetRightToLeft: offsetBy5Day)
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = "d"
                let title = "\(formatter.stringFromDate(startDate))~\(formatter.stringFromDate(endDate))"
                button .setTitle(title, forState: .Normal)
                button.titleLabel?.font = UIFont.systemFontOfSize(13)
            }
            
            selectedMonthCycleButton(monthCycleButtons.last!)
            curMonthStartDate = self.cycleStartDate(curMonthCycleNextDate, buttonOffsetRightToLeft: monthCycleButtons.count - monthCycleButtons.last!.tag-1)
            curMonthEndDate   = self.cycleEndDate(curMonthCycleNextDate, buttonOffsetRightToLeft: monthCycleButtons.count - monthCycleButtons.last!.tag-1)
            
        } else {
            //年
            marker.valueIsAvarage = true
            chartView.marker = marker
            curYearCycleNextDate = currentDate
//            ///365天前, 86400是一天的秒数
//            let intervalPass365Days: NSTimeInterval = -365 * 86400
//            curWeekCyclePrevDate = NSDate(timeInterval: intervalPass365Days, sinceDate: curWeekCycleNextDate)
            curYearCyclePrevDate = self.cycleNextMonthDate(curYearCycleNextDate, buttonOffsetRightToLeft: 11)
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy年M月"
            let previousStr = formatter.stringFromDate(curYearCyclePrevDate)
            let nextStr    = formatter.stringFromDate(curYearCycleNextDate)
            
            dateLabel.text = "\(previousStr) - \(nextStr)"
            
            for button in yearCycleButtons {
                let offsetByMonth = yearCycleButtons.count - button.tag - 1
                let startDate = self.cycleNextMonthDate(curYearCycleNextDate, buttonOffsetRightToLeft: offsetByMonth)
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = "M"
                let month : Int8 = Int8(formatter.stringFromDate(startDate))!
//                month -= Int8(offsetByMonth)
//                month = month <= 0 ? 12 + month : month
                
                let title = "\(month)"
                button .setTitle(title, forState: .Normal)
                button.titleLabel?.font = UIFont.systemFontOfSize(13)
            }
            
            selectedYearCycleButton(yearCycleButtons.last!)
            curYearStartDate = self.cycleStartDate(curYearCycleNextDate, buttonOffsetRightToLeft: yearCycleButtons.count - yearCycleButtons.last!.tag-1)
            curYearEndDate   = self.cycleEndDate(curYearCycleNextDate, buttonOffsetRightToLeft: yearCycleButtons.count - yearCycleButtons.last!.tag-1)
        }
        self.queryData()
    }
    
    
    ///chartViewDelegate方法
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let dataSetOne: LineChartDataSet = chartView.data!.dataSets.first as! LineChartDataSet
        var dataSetSec: LineChartDataSet = chartView.data!.dataSets.first as! LineChartDataSet
        if chartView.data!.dataSets.count > 1 {
            dataSetSec = chartView.data!.dataSets[1] as! LineChartDataSet
        }

        var index = dataSetOne.entryIndex(entry: entry)
        if index < 0 {
            index = dataSetSec.entryIndex(entry: entry)
        }
        
        self.chooseIndexOfdataSets(index)
        
    }
    
    ///无选中状态的点时
    func chartValueNothingSelected(chartView: ChartViewBase) {
        
        chartView .highlightValue(nil)
        self.changeLabel([])
        self.selectedWeekCycleButton(UIButton())
        self.selectedMonthCycleButton(UIButton())
        self.selectedYearCycleButton(UIButton())
    }
    
    func changeLabel(entrys : [ChartDataEntry]) {
        if entrys.count > 1 {
            //血压
            let one = uint((entrys.first?.value)!)
            let sec = uint((entrys[1].value))
            
            detailLabel.text = "高血压：\(one)mmHg 低血压：\(sec)mmHg"
        }else if entrys.count == 1{
            //心率
            let one = uint((entrys.first?.value)!)
            detailLabel.text = "心率：\(one)次/秒"
        }else{
            detailLabel.text = ""
        }
    }
    
    //选择第几个点
    func chooseIndexOfdataSets(index : Int) {
        var hasHR = true
        //找到线
        let dataSetOne: LineChartDataSet = chartView.data!.dataSets.first as! LineChartDataSet
        var dataSetSec: LineChartDataSet = chartView.data!.dataSets.first as! LineChartDataSet
        if chartView.data!.dataSets.count > 1 {
            hasHR = false
            dataSetSec = chartView.data!.dataSets[1] as! LineChartDataSet
        }
        let heighlight0 = ChartHighlight(xIndex:index, dataSetIndex:0)
        let heighlight1 = ChartHighlight(xIndex:index, dataSetIndex:1)
        //点改变
        chartView.highlightValues([heighlight0,heighlight1])
        
        let oneEntry = dataSetOne.entryForIndex(index)
        let secEntry = dataSetSec.entryForIndex(index)
        //文字显示改变
        if hasHR {
            self.changeLabel([oneEntry!])
        }else{
            self.changeLabel([oneEntry!,secEntry!])
        }
        //下面一排按钮的选中状态
        if dateSegment.selectedSegmentIndex == 0 {
            for but in weekCycleButtons {
                if but.tag == index {
                    self.selectedWeekCycleButton(but)
                    break
                }
            }
        }else if dateSegment.selectedSegmentIndex == 1{
            for but in monthCycleButtons {
                if but.tag == index {
                    self.selectedMonthCycleButton(but)
                    break
                }
            }
        }else if dateSegment.selectedSegmentIndex == 2{
            for but in yearCycleButtons {
                if but.tag == index {
                    self.selectedYearCycleButton(but)
                    break
                }
            }
        }
    }
}
