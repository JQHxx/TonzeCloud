//
//  BodyTempRecord.swift
//  Product
//
//  Created by WuJiezhong on 16/7/2.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation

///体温记录
public class BodyTempRecord: NSObject {
    ///测量设备的UUID->改为mac地址
    public var deviceUUID: String
    ///测量日期
    public var date: NSDate
    ///温度
    public var temperature: Float
    ///家庭成员的userId
    public var memberId:Int
    
    public init(deviceUUID: String, date: NSDate, temperature: Float, memberId: Int) {
        self.deviceUUID  = deviceUUID
        self.date        = date
        self.temperature = temperature
        self.memberId    = memberId
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        let record = object as! BodyTempRecord;
//        if self.deviceUUID == record.deviceUUID && self.date == record.date && self.memberId == record.memberId {
            if self.date == record.date && self.memberId == record.memberId {
            return true
        }
        return false
    }
}
