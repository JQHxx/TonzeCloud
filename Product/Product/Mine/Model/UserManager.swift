//
//  UserManager.swift
//  Product
//
//  Created by WuJiezhong on 16/6/24.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation


public class UserManager: NSObject {
    
    ///XLink用户信息
    public var xlUser: XLUserInfo?
    
    ///商派用户信息
    public var spUser: SPUserInfo?
    
    ///用于云菜谱、食材、延保功能的token
    public var menuFuncToken: String?
    
    //MARK: - static 
    
    public class func shareManager() -> UserManager {
        struct Singleton{
            static var predicate: dispatch_once_t  = 0
            static var instance: UserManager? = nil
        }
        dispatch_once(&Singleton.predicate, {
            Singleton.instance = UserManager()
        })
        return Singleton.instance!
    }
    
    
    public class func getMenuAccessToken(callback: (token: String?)->Void) {
        [HttpRequest .applyMenuTokendidLoadData({ (result, error) in
            if let resultDict = result as? NSDictionary {
                let token = resultDict["access_token"] as? String
                UserManager.shareManager().menuFuncToken = token
                callback(token: token)
            } else {
                callback(token: nil)
            }
        })]
    }
    
    
    public class func saveUserAvatarForXlinkUser(userId: Int, image: UIImage) -> Bool{
        let fileManager = NSFileManager.defaultManager()
        let avatarDir = "\(NSHomeDirectory())/Documents/user_avatars"
        var yes:ObjCBool = true
        if !fileManager.fileExistsAtPath(avatarDir, isDirectory: &yes) {
            do{
               try fileManager.createDirectoryAtPath(avatarDir, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                NSLog("Cannot create directory: \(error)")
                return false
            }
        }
        let imageData = UIImagePNGRepresentation(image)
        let filePath = "\(avatarDir)/\(userId)"
        
        return imageData?.writeToFile(filePath, atomically: false) ?? false
    }
    
    public class func getUserAvatarForXlinkUser(userId: Int) -> UIImage? {
        let avatarDir = "\(NSHomeDirectory())/Documents/user_avatars"
        let filePath = "\(avatarDir)/\(userId)"
        
        return UIImage(contentsOfFile: filePath)
    }
}