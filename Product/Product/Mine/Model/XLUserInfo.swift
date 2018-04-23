//
//  XLUserInfo.swift
//  Product
//
//  Created by WuJiezhong on 16/6/24.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation

public class XLUserInfo: NSObject {
    public var userId: Int
    ///企业ID
    public var corp_id: String      = ""
    ///手机号/邮箱
    public var phoneOrEmail: String = ""
    ///用户昵称
    public var nickname: String     = ""
    ///创建时间
    public var create_date: String  = ""
    ///用户状态
    public var status: Int          = 0
    ///用户来源
    public var source: Int          = 0
    ///所在区域ID
    public var region_id: Int       = 0
    ///用户账号是否已认证
    public var is_vaild: Bool       = false
    ///[标签1,标签2]
    public var tags: AnyObject?
    ///头像资源地址url
    public var avatar: String?
    
    init(userId: Int) {
        self.userId = userId
    }
    
    init(dictionary: [NSObject: AnyObject]) {
        self.userId       = dictionary["id"]?.integerValue ?? 0
        self.corp_id      = dictionary["corp_id"] as? String ?? ""
        self.phoneOrEmail = dictionary["phone/email"] as? String ?? ""
        self.nickname     = dictionary["nickname"] as? String ?? ""
        self.create_date  = dictionary["create_date"] as? String ?? ""
        self.status       = dictionary["status"]?.integerValue ?? 0
        self.source       = dictionary["source"]?.integerValue ?? 0
        self.region_id    = dictionary["region_id"]?.integerValue ?? 0
        self.is_vaild     = dictionary["is_vaild"]?.boolValue ?? false
        self.tags         = dictionary["tags"]
        self.avatar       = dictionary["avatar"] as? String
    }
    
}
