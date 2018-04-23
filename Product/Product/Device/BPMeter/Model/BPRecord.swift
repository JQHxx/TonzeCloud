//
//  BPRecord.swift
//  Product
//
//  Created by WuJiezhong on 16/6/6.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation

public class BPRecord: NSObject {
    ///测量设备的UUID->改为mac地址
    public var deviceUUID: String
    ///测量日期
    public var date: NSDate
    ///收缩压，即高压
    public var SBP: UInt16
    ///舒张压，即低压
    public var DBP: UInt16
    ///心率
    public var heartRate: UInt16
    ///心率不齐
    public var isHBUneven: Bool
    
    ///家庭成员的userId,0和1为设备的用户1、2的记录
    public var userId:Int
    
    public init(deviceUUID: String, date: NSDate, SBP: UInt16, DBP:UInt16, heartRate: UInt16, isHBUneven:Bool, userId: Int) {
        self.deviceUUID = deviceUUID
        self.date       = date
        self.SBP        = SBP
        self.DBP        = DBP
        self.heartRate  = heartRate
        self.isHBUneven = isHBUneven
        self.userId     = userId
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        let record = object as! BPRecord;
        if self.deviceUUID == record.deviceUUID && self.date == record.date && self.SBP == record.SBP && self.DBP == record.DBP && self.heartRate == record.heartRate && self.isHBUneven == record.isHBUneven && self.userId == record.userId {
            return true
        }
//        print("\(self.deviceUUID)+\(object!.deviceUUID)+\(self.date)+\(object?.date)+\(self.SBP)+\(object?.SBP)+\(self.DBP)+\(object?.DBP)+\(self.heartRate)+\(object?.heartRate)+\(self.isHBUneven)+\(object?.isHBUneven)+\(self.userId)+\(object?.userId)")
        return false
    }
    
}
