//
//  BPMeterModelHelper.swift
//  Product
//
//  Created by WuJiezhong on 16/6/6.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation

/////血压描述
//public enum BPType : UInt16{
//    case BPTypeIdealBP
//    case BPTypeNormalBP
//    case BPTypeNormalHigh
//    case BPTypeMildHypertension
//    case BPTypeModerateHypertension
//    case BPTypeSevereHypertension
//}

class BPMeterModelHelper:NSObject {
    
    ///获取高压等级
    class func HPvalueDescription(value: UInt16) -> UInt16 {
        switch value {
        case UInt16.min...119:
            return 0
        case 120...129:
            return 1
        case 130...139:
            return 2
        case 140...159:
            return 3
        case 160...179:
            return 4
        case 180..<UInt16.max:
            return 5
        default:
            return 0
        }
    }
    
    ///获取低压等级
    class func LPvalueDescription(value: UInt16) -> UInt16 {
        switch value {
        case UInt16.min...79:
            return 0
        case 80...84:
            return 1
        case 85...89:
            return 2
        case 90...99:
            return 3
        case 100...109:
            return 4
        case 110..<UInt16.max:
            return 5
        default:
            return 0
        }
    }
    
    ///根据血压等级返回血压描述
    class func BPvalueDescription(LPvalue: UInt16 ,HPvalue: UInt16) -> String {
        let type = self.LPvalueDescription(LPvalue) > self.HPvalueDescription(HPvalue) ? self.LPvalueDescription(LPvalue) : self.HPvalueDescription(HPvalue)
        switch type {
        case 0:
            return "理想血压"
        case 1:
            return "正常血压"
        case 2:
            return "正常偏高"
        case 3:
            return "轻度高血压"
        case 4:
            return "中度高血压"
        case 5:
            return "重度高血压"
        default:
            return ""
        }
    }
    
    class func BPvalueColor(LPvalue: UInt16 ,HPvalue: UInt16) -> UIColor {
        let type = self.LPvalueDescription(LPvalue) > self.HPvalueDescription(HPvalue) ? self.LPvalueDescription(LPvalue) : self.HPvalueDescription(HPvalue)
        switch type {
        case 0: //理想血压
            return UIColor(hex: 0x89d838)
        case 1: //正常血压
            return UIColor(hex: 0x89d838)
        case 2: //正常偏高
            return UIColor(hex: 0xbfd833)
        case 3: //"轻度高血压"
            return UIColor(hex: 0xfbd32d)
        case 4: // "中度高血压"
            return UIColor(hex: 0xfa8b2f)
        case 5: //"重度高血压"
            return UIColor(hex: 0xed563d)
        default:
            return UIColor.blackColor()
        }
    }
    
    

}