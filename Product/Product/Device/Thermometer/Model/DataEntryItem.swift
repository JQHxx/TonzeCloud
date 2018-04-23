//
//  DataEntryItem.swift
//  Product
//
//  Created by WuJiezhong on 16/7/7.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation

///折线图的一个点
class DataEntryItem {
    
    var value: Float
    var date: String

    init(value: Float, date: String) {
        self.value = value
        self.date = date
    }
    
    
    /**
     从体温记录的数组统计得到折线图的点数组。静态方法
     
     - parameter records: 体温记录
     - returns: 折线图的点数组
     */
    class func dataEntryItemsFromTempRecords(records: [BodyTempRecord]) -> [DataEntryItem] {
        return dataEntryItemsFromTempRecords(records, avarageOneMinmuteValues: false)
    }
    
    /**
     从体温记录的数组统计得到折线图的点数组。静态方法
     
     - parameter records: 体温记录
     - parameter avarage: 是否对1分钟的点进行求平均值，如果为true，则每分钟就只有一个点
     
     - returns: 折线图的点数组
     */
    class func dataEntryItemsFromTempRecords(records: [BodyTempRecord], avarageOneMinmuteValues avarage: Bool) -> [DataEntryItem] {
        var dataItems = [DataEntryItem]()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        
        if !avarage {   //不求平均值
            for record in records {
                let dateStr = formatter.stringFromDate(record.date)
                let dataItem = DataEntryItem(value: record.temperature, date: dateStr)
                dataItems.append(dataItem)
            }
            return dataItems
        }
        
        /** 求每分钟的平均值 **/
        
        var timeToSumValueDict = [String: Float]()
        var timeToCountDict = [String: Int]()
        
        for record in records {
            let hhmm = formatter.stringFromDate(record.date)
            //同一分钟的数，总是相加
            timeToSumValueDict[hhmm] = (timeToSumValueDict[hhmm] ?? 0) + record.temperature
            //记录加了多少个数
            timeToCountDict[hhmm] = (timeToCountDict[hhmm] ?? 0) + 1
        }
        for (hhmm, sumValue) in timeToSumValueDict {
            let count = timeToCountDict[hhmm]!
            //每分钟的总和除以记录的个数得到平均值
            let avgValue = sumValue / Float(count)
            let item = DataEntryItem(value: avgValue, date: hhmm)
            dataItems.append(item)
        }
        return dataItems.sort({$0.date < $1.date})
    }
    
    
    /**
     从体温记录的数组统计得到折线图的点数组。静态方法
     
     - parameter records: 体温记录
     - returns: 折线图的点数组
     */
    class func dataItemsForDaysFromTempRecords(records: [BodyTempRecord], startDate:NSDate) -> [DataEntryItem] {
        var dataItems = [DataEntryItem]()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM月dd日"
        
        
        var dayToSumValueDict = [String: Float]()
        var dayToCountDict    = [String: Int]()
        
        for record in records {
            let mmdd = formatter.stringFromDate(record.date)
            //同一天的数，总是相加
            dayToSumValueDict[mmdd] = (dayToSumValueDict[mmdd] ?? 0) + record.temperature
            //记录加了多少个数
            dayToCountDict[mmdd] = (dayToCountDict[mmdd] ?? 0) + 1
        }
        for (mmdd, sumValue) in dayToSumValueDict {
            let count = dayToCountDict[mmdd]!
            //每天的总和除以记录的个数得到平均值
            let avgValue = sumValue / Float(count)
            let item = DataEntryItem(value: avgValue, date: mmdd)
            dataItems.append(item)
        }
        
        //当数据少于必须的数据个数时，补零
        while dataItems.count < 7 {
            var startTime = startDate
            while true {
                let yyyyMMdd = formatter.stringFromDate(startTime)
                var hasThisDay = false
                for bpRecord in dataItems {
                    if yyyyMMdd == bpRecord.date {
                        hasThisDay = true
                        break
                    }
                }
                if !hasThisDay {
                    let item = DataEntryItem(value: 0, date: yyyyMMdd)
                    dataItems.insert(item, atIndex: 0)
                    break
                }
                //startTime变为下一天时间
                let startInterval: NSTimeInterval = 86400
                startTime = NSDate(timeInterval: startInterval, sinceDate: startTime)
            }
        }
        
        return dataItems.sort({$0.date < $1.date})
    }
    

    
    
}
