//
//  Record.swift
//  Product
//
//  Created by WuJiezhong on 16/6/28.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit

class BPRecordEntry: NSObject {
    var SBP:UInt16
    var DBP:UInt16
    var heartRate:UInt16
    var date:String
    
    
    init(sbp:UInt16,dbp:UInt16,heartRate:UInt16,date:String) {
        self.SBP = sbp
        self.DBP = dbp
        self.heartRate = heartRate
        self.date = date
    }
    
    class func recordEntries(records:[BPRecord], type: RecordDataType, startDate:NSDate) -> [BPRecordEntry]{
        
        var dataItems = [BPRecordEntry]()
        
        let formatter = NSDateFormatter()
        switch type {
        case .Week:
            formatter.dateFormat = "yyyy:MM:dd"
        case .Month:
            formatter.dateFormat = "yyyy:MM"
        case .Year:
            formatter.dateFormat = "yyyy"
        }
        
        /** 求平均值 **/
        
        var timeToSumSBPDict = [String: UInt32]()
        var timeToSumDBPDict = [String: UInt32]()
        var timeToSumHeartRateDict = [String: UInt32]()
        var timeToCountDict = [String: Int]()
        
        for record in records {
            let hhmm = formatter.stringFromDate(record.date)
            //同时间的数，总是相加
            timeToSumSBPDict[hhmm] = (timeToSumSBPDict[hhmm] ?? 0) + UInt32(record.SBP)
            timeToSumDBPDict[hhmm] = (timeToSumDBPDict[hhmm] ?? 0) + UInt32(record.DBP)
            timeToSumHeartRateDict[hhmm] = (timeToSumHeartRateDict[hhmm] ?? 0) + UInt32(record.heartRate)
            //记录加了多少个数
            timeToCountDict[hhmm] = (timeToCountDict[hhmm] ?? 0) + 1
        }
        for (hhmm, sumValue) in timeToSumSBPDict {
            let sumDBP = timeToSumDBPDict[hhmm]
            let sumHeartRate = timeToSumHeartRateDict[hhmm]
            let count = timeToCountDict[hhmm]!
            //同时间的数的总和除以记录的个数得到平均值
            let avgSBP = sumValue / UInt32(count)
            let avgDBP = sumDBP! / UInt32(count)
            let avgHeartRate = sumHeartRate! / UInt32(count)
            let item = BPRecordEntry(sbp:UInt16(avgSBP),dbp:UInt16(avgDBP),heartRate:UInt16(avgHeartRate),date:hhmm)
            dataItems.append(item)
        }
        
        //当数据少于必须的数据个数时，补零
        switch type {
        case .Week:
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
                        let item = BPRecordEntry(sbp:0,dbp:0,heartRate:0,date:yyyyMMdd)
                        dataItems.insert(item, atIndex: 0)
                        break
                    }
                    //startTime变为下一天时间
                    let startInterval: NSTimeInterval = 86400
                    startTime = NSDate(timeInterval: startInterval, sinceDate: startTime)
                }
            }
        case .Month:
            while dataItems.count < 6 {
                let item = BPRecordEntry(sbp:0,dbp:0,heartRate:0,date:"0")
                dataItems.insert(item, atIndex: 0)
            }
        case .Year:
            while dataItems.count < 12 {
                let item = BPRecordEntry(sbp:0,dbp:0,heartRate:0,date:"0")
                dataItems.insert(item, atIndex: 0)
            }
        }
        
        return dataItems.sort {$0.date < $1.date};
        
}


enum RecordDataType {
    case Week
    case Month
    case Year
}
    
    
}