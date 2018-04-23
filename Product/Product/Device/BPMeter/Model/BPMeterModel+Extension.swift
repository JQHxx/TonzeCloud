//
//  BPMeterModel+Extension.swift
//  Product
//
//  Created by WuJiezhong on 16/6/3.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation

extension BPMeterModel {
    
    var valueDiscription: String {
        return BPMeterModelHelper.BPvalueDescription(DBP, HPvalue: SBP)
    }
    
    var valueColor: UIColor {
        return BPMeterModelHelper.BPvalueColor(DBP, HPvalue: SBP)
    }
    
    //MARK: - 控制方法
    
    ///初始化血压计
    func initDevice() {
        if let peripheral = peripheral {
            BTManager.sharedManager().bpmeterWriteInitData(peripheral)
        }
    }
    
    ///验证
    func startVerify(callback: ((NSError?)->Void)?) {
        if let peripheral = peripheral {
            BTManager.sharedManager().bpmeterStartVerify(peripheral, callback: { (rcvData, userInfo, error) -> Bool in
                if let data = rcvData where data.length >= 5 {
                    data.getBytes(&self.manufacturerCode, range: NSMakeRange(3, 1))
                    NSLog("manufacturerCode: \(self.manufacturerCode)")
                    callback?(nil)
                }
                if let err = error {
                    if err.code == BTErrorCode.Timeout.rawValue && self.isConnected {
                        self.startVerify(callback)
                    }
                }
                return false
            })
        }
    }
    
    func subscribeCurrentValue(callback:((UInt16, Bool)->Void)?) {
        if let peripheral = peripheral {
            BTManager.sharedManager().bpmeterSuscribeCommandValue(peripheral, command: 0xB7, callback: { (rcvData, userInfo, error) -> Bool in
                if let err = error {
                    if err.code == BTErrorCode.Disconnected.rawValue {
                        return false
                    }
                }
                if let data = rcvData where data.length >= 6 {
                    var bytes = [Byte](count: data.length, repeatedValue: 0)
                    data.getBytes(&bytes, length: data.length)
                    let isHeartBeating = (bytes[3] & 0b0001_0000) != 0x00
                    let bpValue        = (UInt16(bytes[3] & 0b0000_1111) << 8) + UInt16(bytes[4])
                    callback?(bpValue, isHeartBeating)
                }
                return self.isConnected
            })
        }
    }
    
    /**
     监听结果
     
     - parameter callback: 结果回调，四个参数分别是(收缩压, 舒张压, 心率值, 是否心率不齐, 是否用户1)
     */
    func subscribeResultValue(callback:((UInt16, UInt16, UInt16, Bool, Bool)->Void)?) {
        if let peripheral = peripheral {
            BTManager.sharedManager().bpmeterSuscribeCommandValue(peripheral, command: 0xB8, callback: { (rcvData, userInfo, error) -> Bool in
                if let err = error {
                    if err.code == BTErrorCode.Disconnected.rawValue {
                        return false
                    }
                }
                if let data = rcvData where data.length >= 8 {
                    var bytes = [Byte](count: data.length, repeatedValue: 0)
                    data.getBytes(&bytes, length: data.length)
                    ///是否心率不齐
                    self.isHBUneven = (bytes[3] & 0b1000_0000) != 0x00
                    self.isUserOne  = (bytes[3] & 0b0100_0000) == 0x00
                    self.SBP        = (UInt16(bytes[3] & 0b0011_1111) << 8) + UInt16(bytes[4])
                    self.DBP        = UInt16(bytes[5])
                    self.heartRate  = UInt16(bytes[6])
                    callback?(self.SBP, self.DBP, self.heartRate, self.isHBUneven, self.isUserOne)
                }
                return self.isConnected
            })
        }
    }
    
    ///血压计上传结果测量的日期
    func subscribeDate(callback: ((String)->Void)?) {
        if let peripheral = peripheral {
            BTManager.sharedManager().bpmeterSuscribeCommandValue(peripheral, command: 0xBD, callback: { (rcvData, userInfo, error) -> Bool in
                if let err = error {
                    if err.code == BTErrorCode.Disconnected.rawValue {
                        return false
                    }
                }
                if let data = rcvData where data.length >= 7 {
                    var bytes = [Byte](count: data.length, repeatedValue: 0)
                    data.getBytes(&bytes, length: data.length)
                    let year  = bytes[3]
                    let month = String(format: "%02d", bytes[4])
                    let day   = String(format: "%02d", bytes[5])
                    callback?("20\(year)-\(month)-\(day)")
                }
                return self.isConnected
            })
        }
    }
    
    ///血压计上传结果测量的时间
    func subscribeTime(callback: ((String)->Void)?) {
        if let peripheral = peripheral {
            BTManager.sharedManager().bpmeterSuscribeCommandValue(peripheral, command: 0xBE, callback: { (rcvData, userInfo, error) -> Bool in
                if let err = error {
                    if err.code == BTErrorCode.Disconnected.rawValue {
                        return false
                    }
                }
                if let data = rcvData where data.length >= 6 {
                    var bytes = [Byte](count: data.length, repeatedValue: 0)
                    data.getBytes(&bytes, length: data.length)
                    let hour = String(format: "%02d", bytes[3])
                    let min  = String(format: "%02d", bytes[4])
                    callback?("\(hour):\(min)")
                }
                return self.isConnected
            })
        }
    }

    ///监听测量的错误信息
    func subscribeErrorMessage(callback: (String, String, Byte)->Void ) {
        if let peripheral = peripheral {
            BTManager.sharedManager().bpmeterSuscribeCommandValue(peripheral, command: 0xB9, callback: { (rcvData, userInfo, error) -> Bool in
                if let err = error {
                    if err.code == BTErrorCode.Disconnected.rawValue {
                        return false
                    }
                }
                if let data = rcvData where data.length >= 5 {
                    var bytes = [Byte](count: data.length, repeatedValue: 0)
                    data.getBytes(&bytes, length: data.length)
                    let code = bytes[3]
                    let message: String
                    let tips: String
                    switch code {
                    case 0:
                        message = "测量不到有效脉搏"
                        tips = "袖带绑得太松或者袖带绑得不正确，请正确绑好袖带测量"
                    case 1:
                        message = "气袋没绑好"
                        tips = "袖带未绑好、气管未连接好、测量方法不正确等原因，请确保绑好袖带后正确测量"
                    case 2:
                        message = "测量结果数值有误"
                        tips = "请使用正确测量方法"
                    case 3:
                        message = "进入超压保护"
                        tips = "气压达到300mmHg时，自动快速放气，请保持安静后正确测量"
                    case 4:
                        message = "测量过程中干预过多"
                        tips = "避免测量中移动、说话等外部干预，请保持安静进行测量"
                    default:
                        message = "未知错误"
                        tips = ""
                    }
                    callback(message, tips, code)
                }
                return self.isConnected
            })
        }
    }
    
    ///同步时间
    func syncClock(callback: ((Bool)->Void)?) {
        if let peripheral = peripheral {
            //先同步日期
            BTManager.sharedManager().bpmeterSyncDate(peripheral, callback: { (data, userInfo, error) -> Bool in
                if let _ = error {
                    callback?(false)
                } else {
                    //再同步时间
                    BTManager.sharedManager().bpmeterSyncDate(peripheral, callback: { (data, userInfo, error) -> Bool in
                        if let _ = error {
                            callback?(false)
                        } else {
                            callback?(true)                            
                        }
                        return false
                    })
                }
                return false
            })
        }
    }
    
}