//
//  HttpRequest.m
//  HttpRequest
//
//  Created by xtmac on 29/10/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "HttpRequest.h"
#import <CommonCrypto/CommonDigest.h>

#define RequestTypeGet      @"GET"
#define RequestTypePUT      @"PUT"
#define RequestTypePOST     @"POST"
#define RequestTypeDelete   @"DELETE"


#ifdef test

///测试
#define Domain @"https://139.196.234.193:8016"

#else

///正式
#define Domain @"https://dev-man.360tj.com:8016"

#endif

@implementation DeviceObject

-(instancetype)initWithProductID:(NSString *)product_id withMac:(NSString *)mac withAccessKey:(NSNumber *)accessKey{
    if (self = [super init]) {
        _product_id = product_id;
        _mac = mac;
        _access_key = accessKey;
    }
    return self;
}

@end

@interface HttpRequest ()<NSURLConnectionDataDelegate>

@property (copy, nonatomic) MyBlock myBlock;

@end

@implementation HttpRequest{
    NSMutableData *_httpReceiveData;
}

-(id)init{
    if (self = [super init]) {
        _httpReceiveData = [[NSMutableData alloc] init];
    }
    return self;
}

-(void)requestWithRequestType:(NSString *)requestType withUrl:(NSString *)urlStr withHeader:(NSDictionary *)header withContent:(id)content{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:requestType];
    for (NSString *key in header.allKeys) {
        [request addValue:[header objectForKey:key] forHTTPHeaderField:key];
    }
    
    if ([content isKindOfClass:[NSData class]]) {
        [request setHTTPBody:content];
    } else if (content) {
        NSData *contentData = [NSJSONSerialization dataWithJSONObject:content options:0 error:nil];
        [request setHTTPBody:contentData];
    }
    MyLog(@"url:%@", urlStr);
    MyLog(@"header:%@", header);
    if (content) {
        MyLog(@"content:%@",content);
    }
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (_myBlock) _myBlock(nil, error);
        }else{
            NSHTTPURLResponse *r = (NSHTTPURLResponse*)response;
            NSInteger statusCode = [r statusCode];
            if (statusCode != 200) {
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (result.count>0) {
                    NSError *err = [NSError errorWithDomain:Domain code:[[[result objectForKey:@"error"] objectForKey:@"code"] integerValue] userInfo:@{NSLocalizedDescriptionKey : [[result objectForKey:@"error"] objectForKey:@"msg"]}];
                    _myBlock(nil, err);
                }else{
                    NSError *err = [NSError errorWithDomain:Domain code:9999 userInfo:@{NSLocalizedDescriptionKey : @"登录失败"}];
                    _myBlock(nil, err);
                }
            }else{
                NSError *err;
                NSDictionary *result = nil;
                if (data.length) {
                    result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                    NSLog(@"result:%@",result);
                }
                if (err) {
                    if (_myBlock) _myBlock(nil, err);
                }else{
                    if (_myBlock) _myBlock(result, nil);
                }
            }
        }
    }];
    [task resume];
}

#pragma mark
#pragma mark 用户开发接口

#pragma mark 1、注册用户请求发送验证码
+(void)getVerifyCodeWithPhone:(NSString *)phone didLoadData:(MyBlock)block{
    HttpRequest *req = [[HttpRequest alloc] init];
    req.myBlock = block;
    NSDictionary *header = @{@"Content-Type" : @"application/json"};
    NSDictionary *content = @{@"corp_id" : CorpId, @"phone" : phone};
    [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/user_register/verifycode"] withHeader:header withContent:content];
}

#pragma mark 2、注册账号
+(void)registerWithAccount:(NSString *)account withNickname:(NSString *)nickname withVerifyCode:(NSString *)verifyCode withPassword:(NSString *)pwd didLoadData:(MyBlock)block{
    
    do {
        NSDictionary *content = nil;
        
        if ([self validatePhone:account]) {
            content = @{@"phone" : account, @"nickname" : nickname, @"corp_id": CorpId, @"verifycode" : verifyCode, @"password" : pwd, @"source" : @"3"};
        }else if ([self validateEmail:account]){
            content = @{@"email" : account, @"nickname" : nickname, @"corp_id": CorpId, @"password" : pwd, @"source" : @"3"};
        }else{
            block(nil, [NSError errorWithDomain:CustomErrorDomain code:4001008 userInfo:@{NSLocalizedDescriptionKey : @"phone/email param error"}]);
        }
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json"};
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/user_register"] withHeader:header withContent:content];
    } while (0);
    
}

#pragma mark 5、用户认证
+(void)authWithAccount:(NSString *)account withPassword:(NSString *)pwd didLoadData:(MyBlock)block{
    
    do {
        NSMutableDictionary *content = [NSMutableDictionary dictionaryWithObject:CorpId forKey:@"corp_id"];
        
        //验证账号是否正确
        if ([self validatePhone:account]) {
            [content setObject:account forKey:@"phone"];
        }else if ([self validateEmail:account]){
            [content setObject:account forKey:@"email"];
        }
        
        [content setObject:pwd forKey:@"password"];
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json"};
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/user_auth"] withHeader:header withContent:content];
    } while (0);
    
}


#pragma mark 第三方用户认证
+(void)thirdAuthWithOpenID:(NSString *)openID withToken:(NSString *)token didLoadData:(MyBlock)block{
    
    do {
        NSMutableDictionary *content = [NSMutableDictionary dictionaryWithObject:CorpId forKey:@"corp_id"];
        
        [content setObject:openID forKey:@"open_id"];
        [content setObject:token forKey:@"access_token"];
        [content setObject:Third_Auth_Source forKey:@"source"];
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json"};
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/user_auth_third"] withHeader:header withContent:content];
    } while (0);
    
}

#pragma mark 6、刷新凭证
+(void)refreshAccessToken:(NSString *)accessToken withRefreshToken:(NSString *)refreshToken didLoadData:(MyBlock)block{
    
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *content = @{@"refresh_token" : refreshToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/token/refresh", Domain] withHeader:header withContent:content];
    } while (0);
    
}

#pragma mark 6、修改账号昵称
+(void)modifyAccountNickname:(NSString *)nickname withUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *content = @{@"nickname" : nickname};
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/user/%@", Domain, userID] withHeader:header withContent:content];
    } while (0);
    
}

#pragma mark 7、重置密码
+(void)resetPasswordWithOldPassword:(NSString *)oldPwd withNewPassword:(NSString *)newPwd withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *content = @{@"old_password" : oldPwd, @"new_password" : newPwd};
        [req requestWithRequestType:RequestTypePUT withUrl:[Domain stringByAppendingString:@"/v2/user/password/reset"] withHeader:header withContent:content];
        
    } while (0);
    
}

#pragma mark 8.1、忘记密码(获取重置密码的验证码)
+(void)forgotPasswordWithAccount:(NSString *)account didLoadData:(MyBlock)block{
    
    do {
        
        NSMutableDictionary *content = [NSMutableDictionary dictionaryWithObject:CorpId forKey:@"corp_id"];
        
        //验证账号是否正确
        if ([self validatePhone:account]) {
            [content setObject:account forKey:@"phone"];
        }else if ([self validateEmail:account]){
            [content setObject:account forKey:@"email"];
        }
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json"};
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/user/password/forgot"] withHeader:header withContent:content];
        
    } while (0);
    
}

#pragma mark 8.2、找回密码(根据验证码设置新密码)
+(void)foundBackPasswordWithAccount:(NSString *)account withVerifyCode:(NSString *)verifyCode withNewPassword:(NSString *)pwd didLoadData:(MyBlock)block{
    
    do {
        
        NSMutableDictionary *content = [NSMutableDictionary dictionaryWithObject:CorpId forKey:@"corp_id"];
        
        //验证账号是否正确
        if ([self validatePhone:account]) {
            [content setObject:account forKey:@"phone"];
        }else if ([self validateEmail:account]){
            [content setObject:account forKey:@"email"];
        }
        
        [content setObject:verifyCode forKey:@"verifycode"];
        [content setObject:pwd forKey:@"new_password"];
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json"};
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/user/password/foundback"] withHeader:header withContent:content];
        
    } while (0);
    
}

#pragma mark 10、取消订阅
+(void)unsubscribeDeviceWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withDeviceID:(NSNumber *)deviceID didLoadData:(MyBlock)block{
    do {
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/unsubscribe", Domain, userID] withHeader:header withContent:@{@"device_id" : deviceID}];
        
    } while (0);
}

#pragma mark 11、用户列表查询
+(void)getUserListWithAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/users", Domain] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 12、获取用户详细信息
+(void)getUserInfoWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@", Domain, userID] withHeader:header withContent:nil];
    } while (0);
    
}

#pragma mark 13、获取设备列表
+(void)getDeviceListWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withVersion:(NSNumber *)version didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/subscribe/devices?version=%@", Domain, userID,version] withHeader:header withContent:nil];
        
    } while (0);
}

#pragma mark 14、获取设备的订阅用户列表
+(void)getDeviceUserListWithUserID:(NSNumber *)userID withDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/subscribe_users?device_id=%@", Domain, userID, deviceID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 15、设置用户扩展属性
+(void)setUserPropertyDictionary:(NSDictionary *)dic withUserID:(NSString *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/property", Domain, userID] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 16、获取用户扩展属性
+(void)getUserPropertyWithUserID:(NSString *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/property", Domain, userID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 17、修改用户扩展属性
+(void)modifyUserPropertyDictionary:(NSDictionary *)dic withUserID:(NSString *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/property", Domain, userID] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 18、获取用户单个扩展属性
+(void)getUserSinglePropertyWithUserID:(NSString *)userID withPropertyKey:(NSString *)key withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/property/%@", Domain, userID, key] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 19、删除用户扩展属性
+(void)delUserPropertyWithUserID:(NSString *)userID withPropertyKey:(NSString *)key withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeDelete withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/property/%@", Domain, userID, key] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 20、停用用户
+(void)disableUserWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/status", Domain, userID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 21、更新用户所在区域
+(void)UpdateUserAreaWithUserID:(NSNumber *)userID withAreaID:(NSString *)areaID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/region", Domain, userID] withHeader:header withContent:@{@"region_id" : areaID}];
    } while (0);
}

#pragma mark 22、用户注册APN服务
+(void)registerAPNServiceWithUserID:(NSNumber *)userID withAppID:(NSString *)appID withDeviceToken:(NSString *)deviceToken withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *content = @{@"app_id" : appID, @"device_token" : deviceToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/apn_register", Domain, userID] withHeader:header withContent:content];
    } while (0);
}

#pragma mark 23、用户停用APN服务
+(void)disableAPNServiceWithUserID:(NSNumber *)userID withAppID:(NSString *)appID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *content = @{@"app_id" : appID};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/apn_unregister", Domain, userID] withHeader:header withContent:content];
    } while (0);
}

#pragma mark 24、获取用户注册的APN服务信息列表
+(void)getUserAPNServiceInfoWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/apns", Domain, userID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 25、上传用户头像
+(void)saveUserAvatarWithAccessToken:(NSString *)accessToken avatarContent:(NSData *)avatarContent  didLoadData:(MyBlock)block {
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Access-Token" : accessToken};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/avatar/upload?avatarType=png", Domain] withHeader:header withContent:avatarContent];
    } while (0);
}


#pragma mark 
#pragma mark 数据存储服务开发接口

#pragma mark 新增字段
-(void)addData:(NSDictionary *)dic withTableName:(NSString *)tableName withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/data/%@", Domain, tableName] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 查询表
-(void)queryDataWithTableName:(NSString *)tableName withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/datas/%@", Domain, tableName] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 修改数据
-(void)modifyData:(NSDictionary *)dic withTableName:(NSString *)tableName withObjectID:(NSString *)objectID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/data/%@/%@", Domain, tableName, objectID] withHeader:header withContent:dic];
        
    } while (0);

}

-(void)delDataWithTableName:(NSString *)tableName withObjectID:(NSString *)objectID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeDelete withUrl:[NSString stringWithFormat:@"%@/v2/data/%@/%@", Domain, tableName, objectID] withHeader:header withContent:nil];
        
    } while (0);
}

#pragma mark 
#pragma mark 设备开发接口
#pragma mark 获取产品数据端点列表
+(void)getDataPointListWithProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/datapoints", Domain, productID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 获取产品快照规则
+(void)getDeviceSnapshotsListWithProductID:(NSString *)productID accessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/snapshots", Domain, productID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 获取设备快照
+(void)getDeviceSnapshotWithContent:(NSDictionary *)content ProductID:(NSString *)productID withAccessToken:(NSString *)accessToken deviceID:(int)device_id didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%d/snapshot", Domain, productID,device_id] withHeader:header withContent:content];
    } while (0);
}

#pragma mark 获取产品快照规则详情
+(void)getDeviceSnapshotDetailWithProductId:(NSString *)productID ccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/snapshot/%@", Domain, productID,@"rice_auto_out"] withHeader:header withContent:nil];
    } while (0);
}


#pragma mark 1、添加设备
+(void)addDeviceWithMacAddress:(NSString *)mac withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device", Domain, productID] withHeader:header withContent:@{@"mac" : mac}];
    } while (0);
}

#pragma mark 2、导入设备
+(void)importDeviceWithMacAddressArr:(NSArray *)macArr withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device_batch", Domain, productID] withHeader:header withContent:macArr];
    } while (0);
}

#pragma mark 3、获取设备信息
+(void)getDeviceInfoWithDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@", Domain, productID, deviceID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 4、修改设备信息
+(void)modifyDeviceInfoWithDeviceID:(NSNumber *)deviceID withInfoDic:(NSDictionary *)dic withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@", Domain, productID, deviceID] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 5、查询设备列表
+(void)queryDeviceListWithProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/devices", Domain, productID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 6、删除设备
+(void)delDeviceWithDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeDelete withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@", Domain, productID, deviceID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 7、设置设备扩展属性
+(void)setDevicePropertyDictionary:(NSDictionary *)dic withDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@/property", Domain, productID, deviceID] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 8、获取设备扩展属性
+(void)getDevicePropertyWithDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@/property", Domain, productID, deviceID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 9、修改设备扩展属性
+(void)modifyDevicePropertyDictionary:(NSDictionary *)dic withDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@/property", Domain, productID, deviceID] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark
#pragma mark 分享部分

#pragma mark 1、分享设备
+(void)shareDeviceWithDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken withShareAccount:(NSString *)account withExpire:(NSNumber *)expire didLoadData:(MyBlock)block{
    
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *dic = @{@"device_id" : deviceID, @"user_id" : account, @"expire" : expire, @"mode" : @"app"};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/share/device", Domain] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 1.2、qrcode分享设备
+(void)shareDeviceInQRcodeWithDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken withExpire:(NSNumber *)expire didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *dic = @{@"device_id" : deviceID, @"expire" : expire, @"mode" : @"qrcode"};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/share/device", Domain] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 2、取消分享
+(void)cancelShareDeviceWithAccessToken:(NSString *)accessToken withInviteCode:(NSString *)inviteCode didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *dic = @{@"invite_code" : inviteCode};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/share/device/cancel", Domain] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 3、接受分享
+(void)acceptShareWithInviteCode:(NSString *)inviteCode withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *dic = @{@"invite_code" : inviteCode};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/share/device/accept", Domain] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 4、拒绝分享
+(void)denyShareWithInviteCode:(NSString *)inviteCode withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *dic = @{@"invite_code" : inviteCode};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/share/device/deny", Domain] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 5、获取分享列表
+(void)getShareListWithAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/share/device/list", Domain] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 6、删除分享记录
+(void)delShareRecordWithInviteCode:(NSString *)inviteCode withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeDelete withUrl:[NSString stringWithFormat:@"%@/v2/share/device/delete/%@", Domain, inviteCode] withHeader:header withContent:nil];
    } while (0);
}


#pragma mark - mark
#pragma mark - 固件升级新接口

#pragma mark - 获取固件版本
+(void)getVersionWithDeviceID:(NSString *)device_id withProduct_id:(NSString *)product_id withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *dic = @{@"product_id" : product_id, @"device_id" : device_id};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/upgrade/device/newest_version", Domain] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark - 升级固件
+(void)upgradeWithDeviceID:(NSString *)device_id withProduct_id:(NSString *)product_id withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *dic = @{@"product_id" : product_id, @"device_id" : device_id};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/upgrade/device", Domain] withHeader:header withContent:dic];
    } while (0);
}



#pragma mark 
#pragma mark 错误信息
+(NSString *)getErrorInfoWithErrorCode:(NSInteger)errCode{
    NSString *errInfo;
    switch (errCode) {
        case 4001001:errInfo = @"请求数据字段验证不通过";break;
        case 4001002:errInfo = @"请求数据必须字段不可为空";break;
        case 4001003:errInfo = @"手机验证码不存在";break;
        case 4001004:errInfo = @"手机验证码错误";break;
        case 4001005:errInfo = @"注册的手机号已存在";break;
        case 4001006:errInfo = @"注册的邮箱已存在";break;
        case 4001007:errInfo = @"密码错误";break;
        case 4001008:errInfo = @"帐号不合法";break;
        case 4001009:errInfo = @"企业成员状态不合法";break;
        case 4001010:errInfo = @"刷新token不合法";break;
        case 4001011:errInfo = @"未知成员角色类型";break;
        case 4001012:errInfo = @"只有管理员才能邀请";break;
        case 4001013:errInfo = @"不可修改其他成员信息";break;
        case 4001014:errInfo = @"不能删除本人";break;
        case 4001015:errInfo = @"未知的产品连接类型";break;
        case 4001016:errInfo = @"已发布的产品不可删除";break;
        case 4001017:errInfo = @"固件版本已存在";break;
        case 4001018:errInfo = @"数据端点未知数据类型";break;
        case 4001019:errInfo = @"数据端点索引已存在";break;
        case 4001020:errInfo = @"已发布的数据端点不可删除";break;
        case 4001021:errInfo = @"该产品下设备MAC地址已存在";break;
        case 4001022:errInfo = @"不能删除已激活的设备";break;
        case 4001023:errInfo = @"扩展属性Key为预留字段";break;
        case 4001024:errInfo = @"设备扩展属性超过上限";break;
        case 4001025:errInfo = @"新增已存在的扩展属性";break;
        case 4001026:errInfo = @"更新不存在的扩展属性";break;
        case 4001027:errInfo = @"属性字段名不合法";break;
        case 4001028:errInfo = @"邮件验证码不存在";break;
        case 4001029:errInfo = @"邮件验证码错误";break;
        case 4001030:errInfo = @"用户状态不合法";break;
        case 4001031:errInfo = @"用户手机尚未认证";break;
        case 4001032:errInfo = @"用户邮箱尚未认证";break;
        case 4001033:errInfo = @"用户已经订阅设备";break;
        case 4001034:errInfo = @"用户没有订阅该设备";break;
        case 4001035:errInfo = @"自动升级任务名称已存在";break;
        case 4001036:errInfo = @"升级任务状态未知";break;
        case 4001037:errInfo = @"已有相同的起始版本升级任务";break;
        case 4001038:errInfo = @"设备激活失败";break;
        case 4001039:errInfo = @"设备认证失败";break;
        case 4001041:errInfo = @"订阅设备认证码错误";break;
        case 4001042:errInfo = @"授权名称已存在";break;
        case 4001043:errInfo = @"该告警规则名称已存在";break;
        case 4001045:errInfo = @"数据变名称已存在";break;
        case 4001046:errInfo = @"产品固件文件超过大小限制";break;
        case 4001047:errInfo = @"APN密钥文件超过大小限制";break;
        case 4001048:errInfo = @"APP的APN功能未启用";break;
        case 4001049:errInfo = @"产品未允许用户注册设备";break;
        case 4001050:errInfo = @"该类型的邮件模板已存在";break;
        case 4001051:errInfo = @"邮件模板正文内容参数缺失";break;
        case 4031001:errInfo = @"禁止访问";break;
        case 4031002:errInfo = @"禁止访问，需要Access-Token";break;
        case 4031003:errInfo = @"无效的Access-Token";break;
        case 4031004:errInfo = @"需要企业的调用权限";break;
        case 4031005:errInfo = @"需要企业管理员权限";break;
        case 4031006:errInfo = @"需要数据操作权限";break;
        case 4031007:errInfo = @"禁止访问私有数据";break;
        case 4031008:errInfo = @"分享已经被取消";break;
        case 4031009:errInfo = @"分享已经接受";break;
        case 4031010:errInfo = @"用户没有订阅设备，不能执行操作";break;
        case 4041001:errInfo = @"URL找不到";break;
        case 4041002:errInfo = @"企业成员帐号不存在";break;
        case 4041003:errInfo = @"企业成员不存在";break;
        case 4041004:errInfo = @"激活的成员邮箱不存在";break;
        case 4041005:errInfo = @"产品信息不存在";break;
        case 4041006:errInfo = @"产品固件不存在";break;
        case 4041007:errInfo = @"数据端点不存在";break;
        case 4041008:errInfo = @"设备不存在";break;
        case 4041009:errInfo = @"设备扩展属性不存在";break;
        case 4041010:errInfo = @"企业不存在";break;
        case 4041011:errInfo = @"用户不存在";break;
        case 4041012:errInfo = @"用户扩展属性不存在";break;
        case 4041013:errInfo = @"升级任务不存在";break;
        case 4041014:errInfo = @"第三方身份授权不存在";break;
        case 4041015:errInfo = @"告警规则不存在";break;
        case 4041016:errInfo = @"数据表不存在";break;
        case 4041017:errInfo = @"数据不存在";break;
        case 4041018:errInfo = @"分享资源不存在";break;
        case 4041019:errInfo = @"企业邮箱不存在";break;
        case 4041020:errInfo = @"APP不存在";break;
        case 4041021:errInfo = @"产品转发规则不存在";break;
        case 4041022:errInfo = @"邮件模板不存在";break;
        case 5031001:errInfo = @"服务端发生异常";break;
        case -1009:errInfo = @"网络错误";break;
        case -1004:errInfo = @"网络错误";break;
        case 404:errInfo = @"网络错误";break;
            
        default:errInfo = @"请求超时，请稍后重试！";break;
    }
    return errInfo;
}


#pragma mark
#pragma mark 不公开接口

#pragma mark 注册设备
+(void)registerDeviceWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withDevice:(DeviceObject *)deviceObject didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:deviceObject.product_id, @"product_id", deviceObject.mac, @"mac", nil];
        if (deviceObject.name) [contentDic setObject:deviceObject.name forKey:@"name"];
        if (deviceObject.access_key) [contentDic setObject:deviceObject.access_key forKey:@"access_key"];
        if (deviceObject.mcu_mod) [contentDic setObject:deviceObject.mcu_mod forKey:@"mcu_mod"];
        if (deviceObject.mcu_version) [contentDic setObject:deviceObject.mcu_version forKey:@"mcu_version"];
        if (deviceObject.firmware_mod) [contentDic setObject:deviceObject.firmware_mod forKey:@"firmware_mod"];
        if (deviceObject.firmware_version) [contentDic setObject:deviceObject.firmware_version forKey:@"firmware_version"];
        
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/register_device", Domain, userID] withHeader:header withContent:[NSDictionary dictionaryWithDictionary:contentDic]];
        
    } while (0);
}

#pragma mark
#pragma mark 辅助工具
+(BOOL)validateEmail:(NSString *)email{
    
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:email];
    
}

+(BOOL)validatePhone:(NSString *)phone{
    
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:phone];
    
}

-(void)printByteData:(NSData *)data{
    
    char temp[data.length];
    [data getBytes:temp range:NSMakeRange(0, data.length)];
    
    for (int i=0; i<data.length; i++) {
        NSLog(@"%d ->%02x",i,temp[i]);
    }
    
}

-(void)dealloc{
//    NSLog(@"%s", __func__);
}


#pragma mark 食材菜谱
+(void)getFoodWithOffset:(NSString *)offset withAccessToken:(NSString *)token withLimit:(NSString *)limit withFilter:(NSArray *)filter withQuery:(NSDictionary *)query withOrder:(NSDictionary *)order didLoadData:(MyBlock)block{

    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/x-www-form-urlencoded",
                                 @"Access-Token":token};
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        
        if (offset) {
            [dic setObject:offset forKey:@"offset"];
            
        }
        if (limit) {
            [dic setObject:limit forKey:@"limit"];
            
        }
        if (query) {
            [dic setObject:query forKey:@"query"];
            
        }
        if (order) {
            [dic setObject:order forKey:@"order"];
            
        }
        
        
//        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"http://plugin.xlink.cn/39352b6f8d224064832bcec9b96958d1/ingredient/list"] withHeader:header withContent:dic];
        NSString *url = [NSString stringWithFormat:@"%@/module/recipes/%@/api/ingredient/list", Domain, APP_ID_FOR_MENU];
        
        [req requestWithRequestType:RequestTypePOST withUrl:url withHeader:header withContent:dic];
        
        
    } while (0);
}
    

+(void)getMenuWithOffset:(NSString *)offset accessToken:(NSString *)token withLimit:(NSString *)limit withFilter:(NSArray *)filter withQuery:(NSDictionary *)query withOrder:(NSDictionary *)order didLoadData:(MyBlock)block{
    
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/x-www-form-urlencoded",
                                 @"Access-Token": token};
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        
        if (offset) {
            [dic setObject:offset forKey:@"offset"];
            
        }
        if (limit) {
            [dic setObject:limit forKey:@"limit"];
            
        }
        if (query) {
            [dic setObject:query forKey:@"query"];
            
        }
        if (order) {
            [dic setObject:order forKey:@"order"];
            
        }
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/module/recipes/%@/api/recipes/list", Domain, APP_ID_FOR_MENU] withHeader:header withContent:dic];
        
    } while (0);
}


#pragma mark 获取延保列表
/**
 *  获取延保列表4001034
 *
 *  @param offset 偏移量
 *  @param limit  数量
 *  @param filter 查询列名
 *  @param query  查询条件
 *  @param order  排序条件
 *  @param block  返回数据
 */
+(void)getWarrantyListWithOffset:(NSString *)offset withLimit:(NSString *)limit withFilter:(NSArray *)filter withQuery:(NSDictionary *)query withOrder:(NSDictionary *)order didLoadData:(MyBlock)block{
    NSString *token=[NSUserDefaultInfos getValueforKey:WARRANTY_TOKEN];
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json",@"Access-Token":token};
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        if (offset) {
            [dic setObject:offset forKey:@"offset"];
        }
        if (limit) {
            [dic setObject:limit forKey:@"limit"];
        }
        if (query) {
            [dic setObject:query forKey:@"query"];
        }
        if (order) {
            [dic setObject:order forKey:@"order"];
        }
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/module/warranty/%@/api/warranty/list",Domain, APP_ID] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 添加延保列表
+(void)addWarrantyWithUserID:(NSString*)userid withName:(NSString*)name withPhone:(NSString *)phone withEmail:(NSString*)email withGender:(NSString*)gender withArea:(NSString *)area withAddress:(NSString *)address withRemark:(NSString *)remark withProductSN:(NSString *)sn withProductName:(NSString *)productname withProductModel:(NSString *)productmodel withProvince:(NSString *)province withCity:(NSString *)city withDistrict:(NSString *)district withPurDate:(NSString *)purdate withExpDate:(NSString *)expdate didLoadData:(MyBlock)block{

    NSString *token=[NSUserDefaultInfos getValueforKey:WARRANTY_TOKEN];
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json",@"Access-Token":token};
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        if (userid)  [dic setObject:userid forKey:@"user_id"];
        if (name)   [dic setObject:name forKey:@"name"];
        if (gender) [dic setObject:gender forKey:@"gender"];
        if (phone)  [dic setObject:phone forKey:@"phone"];
        if(email && email.length>0) [dic setObject:email forKey:@"email"];
        if (area)   [dic setObject:area forKey:@"area"];
        if (address)   [dic setObject:address forKey:@"address"];
        if (remark&&![remark isEqualToString:@"请输入备注信息"])   [dic setObject:remark forKey:@"remark"];
        if (sn)   [dic setObject:sn forKey:@"product_sn"];
        if (productname)   [dic setObject:productname forKey:@"product_name"];
        if (productmodel)   [dic setObject:productmodel forKey:@"product_type"];
        if (province)   [dic setObject:province forKey:@"province"];
        if (city)   [dic setObject:city forKey:@"city"];
        if (district)   [dic setObject:district forKey:@"district"];
        if (purdate)   [dic setObject:[purdate stringByAppendingString:@"T00:00:00.000Z"] forKey:@"purchase_date"];
        if (expdate)   [dic setObject:[expdate stringByAppendingString:@"T00:00:00.000Z"] forKey:@"expired_date"];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
       [dic setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"create_time"];
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/module/warranty/%@/api/warranty/save",Domain, APP_ID] withHeader:header withContent:dic];
    } while (0);
}


#pragma mark 企业成员或用户申请应用接口调用凭证（延保使用）
/**
 *  企业成员或用户申请应用接口调用凭证。
 *
 *  @param block 	{
                   "app_id": "应用ID",
                   "access_token": "应用接口调用凭证"
	}
 */
+(void)applyWarrantyTokendidLoadData:(MyBlock)block{
    
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    NSString *token=[userDic objectForKey:@"access_token"];

    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : token};
        
        NSMutableDictionary *contentDic = [NSMutableDictionary  dictionary];
        contentDic[@"app_id"] = APP_ID;
        
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/plugin/apply_token"] withHeader:header withContent:contentDic];
        
        
    } while (0);
}

#pragma mark 企业成员或用户申请应用接口调用凭证(菜谱使用)
/**
 *  企业成员或用户申请应用接口调用凭证。
 *
 *  @param block 	{
 "app_id": "应用ID",
 "access_token": "应用接口调用凭证"
	}
 */
+(void)applyMenuTokendidLoadData:(MyBlock)block{
    
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    NSString *token=[userDic objectForKey:@"access_token"];
    
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : token};
        
        NSMutableDictionary *contentDic = [NSMutableDictionary  dictionary];
        contentDic[@"app_id"] = APP_ID_FOR_MENU;
        
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/plugin/apply_token"] withHeader:header withContent:contentDic];
        
        
    } while (0);
}

#pragma mark 企业成员或用户验证凭证
+(void)validWarrantyTokenWithToken:(NSString *)token didLoadData:(MyBlock)block{
    
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json"};
        
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:APP_ID,@"app_id",token,@"access_token", nil];
        
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/developer/valid_token"] withHeader:header withContent:contentDic];
        
        
    } while (0);
}

@end