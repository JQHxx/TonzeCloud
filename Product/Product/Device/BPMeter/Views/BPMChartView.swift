//
//  BPMChartView.swift
//  Product
//
//  Created by WuJiezhong on 16/6/28.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit
import Charts

public enum BPMChartStyle {
    ///血压
    case BloodPresure
    ///心率
    case HeartRete
    ///体温
    case BodyTemp
}

public class BPMChartView: UIView, ChartViewDelegate {
    
    public var chartStyle:BPMChartStyle = .BloodPresure
    public var xValues: [String]?
    public var YValues: [BPRecord]?
    
    private var chartView: LineChartView!
    
    override public func drawRect(rect: CGRect) {
        if chartView == nil {
            chartView = LineChartView()
            self.addSubview(chartView)
            self.initChartView()
        }
        chartView.frame = rect
        
    }
    
    
    func initChartView() {
        chartView.delegate = self
        
        chartView.noDataTextDescription = "暂无数据"
        chartView.noDataText = ""
        chartView.descriptionText = ""
        chartView.infoFont = UIFont.systemFontOfSize(16)
        chartView.infoTextColor = UIColor(hex: 0xD5D5D5)
        
        chartView.dragEnabled = true
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        
        chartView.drawGridBackgroundEnabled = false  //隐藏网格
        chartView.leftAxis.enabled = false           //隐藏左边y轴
        chartView.rightAxis.enabled = false          //隐藏右边y轴
        chartView.legend.enabled = false             //隐藏图例
        
        ///内容边距
        chartView.extraLeftOffset = 36;
        chartView.extraRightOffset = 36;
        chartView.extraTopOffset = 30;
        
        //X轴属性
        chartView.xAxis.labelPosition = .Bottom;
        chartView.xAxis.resetCustomAxisMax()
        chartView.xAxis.axisLabelModulus = 0
        chartView.xAxis.spaceBetweenLabels = 0
        chartView.xAxis.labelTextColor = UIColor.whiteColor()
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.axisLineColor = UIColor.whiteColor()
    }
    
    func setValues(XValues: [String], YValues:[BPRecord]) {
        self.xValues = XValues
        self.YValues = YValues
        self .setNeedsDisplay()
    }
    
    func loadData() {
        
    }
}
