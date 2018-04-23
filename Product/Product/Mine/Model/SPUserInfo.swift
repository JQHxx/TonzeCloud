//
//  SPUserInfo.swift
//  Product
//
//  Created by WuJiezhong on 16/6/24.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation

///商派用户信息
public class SPUserInfo: NSObject {
    public var mobile: String = ""
    public var email: String  = ""
    ///用户昵称
    public var name: String   = ""
    ///姓氏
    public var lastname: String?
    ///名字
    public var firstname: String?
    ///地址
    public var addr: String?
    ///固定电话
    public var tel: String?
    ///邮编， 因为接口没有height字段，所有身高统一用zip保存
    public var zip: String    = "175"
    ///生年（如1990）
    public var b_year: Int    = 2000
    ///生月（如1）
    public var b_month: Int   = 1
    ///生日（如1）
    public var b_day: Int     = 1
    ///性别（0女 1男 -无）
    public var sex: String    = "男"
    ///婚姻状况（0未婚1已婚）
    public var wedlock: Int   = 0
    ///教育程度
    public var education: String?
    public var vocation: String?
    
    ///年龄
    public var age: String = "26"
    ///身高，因为接口没有height字段，所有身高统一用zip保存
    public var height: String = "170"
    
    override init() { }
    
    init(dictionary: [NSObject: AnyObject]) {
        self.mobile    = dictionary["mobile"] as? String ?? ""
        self.email     = dictionary["email"] as? String ?? ""
        self.name      = dictionary["name"] as? String ?? ""
        self.lastname  = dictionary["lastname"] as? String
        self.firstname = dictionary["firstname"] as? String
        self.addr      = dictionary["addr"] as? String
        self.tel       = dictionary["tel"] as? String
        if dictionary["zip"]?.integerValue > 0 {
            self.zip       = dictionary["zip"] as? String ?? ""
        }
        self.b_year    = dictionary["b_year"]?.integerValue ?? 2000
        self.b_month   = dictionary["b_month"]?.integerValue ?? 1
        self.b_day     = dictionary["b_day"]?.integerValue ?? 1
        self.sex       = dictionary["sex"]?.integerValue == 0 ? "女":"男"
        self.wedlock   = dictionary["wedlock"]?.integerValue ?? 0
        self.education = dictionary["education"] as? String
        self.vocation  = dictionary["vocation"] as? String
        
        self.height = self.zip
        self.age = NSUserDefaultInfos.getAgeFromBirthYear(dictionary["b_year"] as? String ?? "2000")
    }
    
    
    
    class func userFromUserDefaults() -> SPUserInfo? {
        guard let name = NSUserDefaultInfos.getValueforKey(USER_NAME) else {
            return nil
        }
        let user = SPUserInfo()
        user.name = name
        user.sex = NSUserDefaultInfos.getValueforKey(USER_SEX) ?? "男"
        user.age = NSUserDefaultInfos.getValueforKey(USER_AGE) ?? "24"
        user.height = NSUserDefaultInfos.getValueforKey(USER_HEIGHT) ?? "175"
        
        return user
    }
}
