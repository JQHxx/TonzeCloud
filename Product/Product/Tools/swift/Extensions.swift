//
//  Extensions.swift
//  Product
//
//  Created by WuJiezhong on 16/5/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation
import UIKit

typealias Byte = UInt8

extension UIColor {
    convenience init(hex: UInt32){
        self.init(htmlColor: hex + 0xFF00_0000)
    }
    
    convenience init(htmlColor: UInt32){
        let alphaPiece = CGFloat((htmlColor & 0xFF00_0000) >> 24)
        let redPiece   = CGFloat((htmlColor & 0x00FF_0000) >> 16)
        let greenPiece = CGFloat((htmlColor & 0x0000_FF00) >> 8)
        let bluePiece  = CGFloat(htmlColor & 0x0000_00FF)
        self.init(red: redPiece/255, green: greenPiece/255, blue: bluePiece/255, alpha: alphaPiece/255)
    }
    
    convenience init(R: Int, G: Int, B: Int, alpha: CGFloat){
        self.init(red: CGFloat(R) / 255.0, green: CGFloat(G) / 255.0, blue: CGFloat(B) / 255.0, alpha: alpha)
    }
}


/**扩展UInt32的两个属性方法*/
extension UInt32{
    /**返回一个Byte数组，数组元素低位是UInt32值的低8位，即UInt32值由低位到高位顺序对应数组由低到高顺序*/
    func getBytes() -> [Byte]{
        let B0:Byte = Byte((UInt32(self) &       0xFF))
        let B1:Byte = Byte((UInt32(self) &     0xFF00) >> 8)
        let B2:Byte = Byte((UInt32(self) &   0xFF0000) >> 16)
        let B3:Byte = Byte((UInt32(self) & 0xFF000000) >> 24)
        
        return [B0, B1, B2, B3]
    }
    /**初始化方法，使用Byte数组赋值，与getBytes相反，注意：Byte数组应该有且只有4个元素*/
    init(fourBytes bytes: [Byte]) {
        var temp:UInt32 = 0
        if bytes.count <= 4 {
            for i in 0...bytes.count-1 {
                temp += UInt32(bytes[i]) << UInt32(8 * i)
            }
        } else {
            for i in 0...3 {
                temp += UInt32(bytes[i]) << UInt32(8 * i)
            }
        }
        self.init(temp)
    }
}

/**扩展UInt16的两个属性方法*/
extension UInt16{
    /**返回一个Byte数组，数组元素低位是UInt16值的低8位，即UInt16值由低位到高位顺序对应数组由低到高顺序*/
    func getBytes() -> [Byte]{
        let B0:Byte = Byte((UInt16(self) &       0xFF))
        let B1:Byte = Byte((UInt16(self) &     0xFF00) >> 8)
        
        return [B0, B1]
    }
    /**初始化方法，使用Byte数组赋值，与getBytes相反，注意：Byte数组应该有且只有2个元素*/
    init(twoBytes bytes: [Byte]) {
        var temp:UInt16 = UInt16(bytes[0])
        temp += UInt16(bytes[1]) << 8
        
        self.init(temp)
    }
}