//
//  ThermometerModel+Extension.swift
//  Product
//
//  Created by WuJiezhong on 16/6/3.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation

extension ThermometerModel {
    
    class func valueDescription(value: Float) -> String {
        switch value {
        case 0...35:
            return "体温过低"
        case 35...35.9:
            return "正常偏低"
        case 36...37.4:
            return "正常体温"
        case 37.5...38:
            return "低热"
        case 38.1...39:
            return "中度发热"
        case 39.1...41:
            return "高热"
        case 41...100:
            return "超高热"
        default:
            return "体温异常"
        }
    }
    
    class func valueColor(value: Float) -> UIColor {
        switch value {
        case _ where value < 0:
            return UIColor(hex: 0x22C7FC)
        case 0...35:
            return UIColor(hex: 0x22C7FC)
        case 35...35.9:
            return UIColor(hex: 0x22C7FC)
        case 36...37.4:
            return UIColor(hex: 0x53D860)
        case 37.5...38:
            return UIColor(hex: 0xEB242B)
        case 38.1...39:
            return UIColor(hex: 0xEB242B)
        case 39.1...41:
            return UIColor(hex: 0xEB242B)
        case 41...100:
            return UIColor(hex: 0xEB242B)
        default:
            return UIColor(hex: 0xEB242B)
        }
    }
    
    ///开始配对。调用此方法时，大概1s之后，需提示用户按下体温计的电源键来完成配对。callback将会在FFF1接口收到0x21之后调用
    func startVerify(callback: ((NSError?)->Void)?) {
        if let peripheral = peripheral {
            BTManager.sharedManager().thermoStartVerify(peripheral, callback: { (rcvData, userInfo, error) -> Bool in
                if let _ = error {
                    callback?(error)
                } else {
                    if let data = rcvData where data.length >= 2 {
                        var bytes = [Byte](count: data.length, repeatedValue: 0)
                        data.getBytes(&bytes, length: data.length)
                        if bytes[1] == 0x00 {
                            callback?(nil)
                        } else {
                            callback?(NSError(description: "返回验证错误", code: -111))
                        }
                    }
                }
                return false
            })
        }
    }
    
    ///同步时间
    func syncClock(callback: ((Bool)->Void)?) {
        if let peripheral = peripheral {
            BTManager.sharedManager().thermoSyncClock(peripheral, callback: { (data, userInfo, error) -> Bool in
                if let _ = error {
                    callback?(false)
                } else {
                    callback?(true)
                }
                return false
            })
        }
    }
    
    
    func enableLiveDataNotify(enable:Bool = true, callback: NotifyCallback?)  {
        if let peripheral = peripheral {
            BTManager.sharedManager().thermoEnableLiveDataNotify(peripheral, enable: enable, callback: callback);
        }
    }
    
    
    func subscribeNextValue(handler:((NSDate, Float ,Bool)->Void)?) {
        if let peripheral = peripheral {
            BTManager.sharedManager().thermoSubscribeLiverData(peripheral, enable:true, callback: { (data, userInfo, error) -> Bool in
                if let data = data {
                    if data.length >= 6 { //数据至少6个字节
                        let valueStr = data.hexString()
                        let tempStr=valueStr.substringToIndex(valueStr.startIndex.advancedBy(5))
                        NSLog("tempStr:%@", tempStr)
                        if tempStr=="FF FF"{
                            var bytes = [UInt8](count: data.length, repeatedValue:0)
                            data.getBytes(&bytes, length: data.length)
                            let pass = NSTimeInterval(UInt32(fourBytes: Array(bytes[0...3])))
                            
                            //2000-1-1 00:00:00
                            let formatter = NSDateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let sinceDate = formatter.dateFromString("2000-01-01 00:00:00")
                            let recordDate = NSDate(timeInterval: pass, sinceDate: sinceDate!)
                            
                            handler?(recordDate, 0.0,true)
                        }else{
                            var bytes = [UInt8](count: data.length, repeatedValue:0)
                            data.getBytes(&bytes, length: data.length)
                            let pass = NSTimeInterval(UInt32(fourBytes: Array(bytes[0...3])))
                            let temp = Float(UInt16(twoBytes: Array(bytes[4...5]))) / 10
                            
                            //2000-1-1 00:00:00
                            let formatter = NSDateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let sinceDate = formatter.dateFromString("2000-01-01 00:00:00")
                            let recordDate = NSDate(timeInterval: pass, sinceDate: sinceDate!)
                            
                            handler?(recordDate, temp,false)
                        }
                    }
                }
                return true
            })
        }
    }
    
    func receiveDeviceHistoryData(handler:((NSDate, Float)->Void)?) {
        if let peripheral = peripheral {
            BTManager.sharedManager().thermoReceiveDeviceHistoryDataNotify(peripheral, enable:true, callback: { (data, userInfo, error) -> Bool in
                if let data = data {
                    if data.length >= 6 { //数据至少6个字节
                        var bytes = [UInt8](count: data.length, repeatedValue:0)
                        data.getBytes(&bytes, length: data.length)
                        let pass = NSTimeInterval(UInt32(fourBytes: Array(bytes[0...3])))
                        let temp = Float(UInt16(twoBytes: Array(bytes[4...5]))) / 10
                        
                        print("时间戳 pass = \(pass)")
                        
                        //2000-1-1 00:00:00
                        let formatter = NSDateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let sinceDate = formatter.dateFromString("2000-01-01 00:00:00")
                        let recordDate = NSDate(timeInterval: pass, sinceDate: sinceDate!)
                        
                        BTManager.sharedManager().thermoReceiveDeviceHistoryDataConfirm(peripheral, timestamp: UInt32(fourBytes: Array(bytes[0...3])) , callback: nil)
                        
                        if temp == 0 && pass == 0{
                            return false
                        }else if pass == 0{
                        
                        }else{
                            handler?(recordDate, temp)
                        }
                    }
                }
                return true
            })
        }
    }
    
    
    
}