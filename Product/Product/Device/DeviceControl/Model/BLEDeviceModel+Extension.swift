//
//  BLEDeviceModel+Extension.swift
//  Product
//
//  Created by WuJiezhong on 16/5/31.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation


extension BLEDeviceModel {
    
    ///搜索设备，扫描到设备之后停止扫描
    func searchPeripheral(finish: ((NSError?)->Void)?) {
        BTManager.scanDevice(self, success: { deviceForScan in
            if deviceForScan.peripheral != nil {
                self.peripheral = deviceForScan.peripheral
                finish?(nil)
            } else {
                finish?(NSError(description: "扫描失败", code: -100))
            }
        }, fail: { error in
            finish?(error)
        })
    }
    
    func stopSearchPeer() {
        BTManager.stopScan()
    }
    
    func connect() {
        if let peripheral = peripheral {
            BTManager.connect(peripheral)
        } else {
            self.searchPeripheral({[weak self] (error) in
                if let err = error {
                    NSLog("搜索失败：\(err.localizedDescription)")
                } else {
                    if let peripheral = self?.peripheral {
                        BTManager.connect(peripheral)
                    }
                }
            })
        }
    }
    
    func stopScan() {
        BTManager.stopScan()
    }
    
    func disconnect() {
        if let peripheral = peripheral {
            BTManager.disconnect(peripheral)
        }
    }
    
}