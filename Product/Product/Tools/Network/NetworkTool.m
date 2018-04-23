//
//  NetworkTool.m
//  Product
//
//  Created by vision on 17/4/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "NetworkTool.h"
#import "SVProgressHUD.h"
#import "Reachability/Reachability.h"
#import "Product-Swift.h"
#import "AppDelegate.h"
#import "SSKeychain.h"
#import "UIDevice+Extend.h"

@implementation NetworkTool

singleton_implementation(NetworkTool)

-(BOOL)isConnectedToNet{
    BOOL isYes = YES;
    JAReachability *reach = [JAReachability reachabilityWithHostname:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isYes = NO;
            break;
        case ReachableViaWiFi:
            isYes = YES;
            break;
        case ReachableViaWWAN:
            isYes = YES;
            
        default:
            break;
    }
    return isYes;
}

#pragma mark post网络请求封装
-(void)postMethodWithURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostURL,urlStr];
    [self requstMethod:@"POST" url:urlString body:bodyStr isLoading:YES success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}

#pragma mark post网络请求封装（不带加载器）
-(void)postMethodWithoutLoadingForURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostURL,urlStr];
    [self requstMethod:@"POST" url:urlString body:bodyStr isLoading:NO success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}

#pragma mark 商城post网络请求封装
-(void)postShopMethodWithURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostShopURL,urlStr];
    [self requstShopMethod:@"POST" url:urlString body:bodyStr isLoading:YES success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}
#pragma mark 商城post网络请求封装（不带加载器）
-(void)postShopMethodWithoutLoadingURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostShopURL,urlStr];
    [self requstShopMethod:@"POST" url:urlString body:bodyStr isLoading:NO success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}
#pragma mark get网络请求封装
- (void)getMethodWithURL:(NSString *)urlStr isLoading:(BOOL)isLoading success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostURL,urlStr];
    [self requstMethod:@"GET" url:urlString body:nil isLoading:isLoading success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}

#pragma mark 商城get网络请求封装
- (void)getShopMethodWithURL:(NSString *)urlStr body:(NSString *)body isLoading:(BOOL)isLoading success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSString *urlString=[NSString stringWithFormat:kHostShopURL,urlStr];
    [self requstShopMethod:@"GET" url:urlString body:body isLoading:isLoading success:^(id json) {
        success(json);
    } failure:^(NSString *errorStr) {
        failure(errorStr);
    }];
}


#pragma mark --其他数据转json数据
-(NSString *)getValueWithParams:(id)params{
    SBJsonWriter *writer=[[SBJsonWriter alloc] init];
    NSString *value=[writer stringWithObject:params];
    MyLog(@"value:%@",value);
    return value;
}

#pragma mark 刷新用户凭证
-(void)refreshUserTokenSuccess:(HttpSuccess)success{
    NSString *userKey=[NSUserDefaultInfos getValueforKey:kUserKey];             //用户key
    NSString *userSecret=[NSUserDefaultInfos getValueforKey:kUserSecret];       //用户secret
    if (!kIsEmptyString(userKey)) {
        NSString *currentDateStr=[[TJYHelper sharedTJYHelper] getCurrentDateTime];
        NSInteger timeSp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:currentDateStr format:@"yyyy-MM-dd HH:mm"];  //时间戳
        NSString *userSign=[NSString stringWithFormat:@"%@%ld%@",userKey,(long)timeSp,userSecret];                     //签名
        NSString *body=[NSString stringWithFormat:@"user_key=%@&user_sign=%@&timestamp=%ld",userKey,[[userSign MD5] uppercaseString],(long)timeSp];
        [self postMethodWithoutLoadingForURL:kGetTokenAPI body:body success:^(id json) {
            NSDictionary *result=[json objectForKey:@"result"];
            if (kIsDictionary(result)&&result.count>0) {
                NSString *userToken=[result valueForKey:@"user_token"];
                [NSUserDefaultInfos putKey:kUserToken andValue:userToken];
                [NSUserDefaultInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
                success(result);
            }
        } failure:^(NSString *errorStr) {
            
        }];
    }
}

#pragma mark 获取用户信息
-(void)requestUserInfo{
    [self postMethodWithoutLoadingForURL:kSetUserInfo body:@"doSubmit=0" success:^(id json) {
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            TJYUserModel *userModel=[[TJYUserModel alloc] init];
            [userModel setValues:result];
            [TonzeHelpTool sharedTonzeHelpTool].user=userModel;
        }
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark -- Private Methods
#pragma mark 具体请求方法
-(void)requstMethod:(NSString *)method url:(NSString *)urlStr body:(NSString *)body isLoading:(BOOL)isLoading success:(HttpSuccess)success failure:(HttpFailure)failure{
    if (isLoading) {
        [SVProgressHUD show];
    }
    
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setHTTPMethod:method];
   
    //请求头信息
    NSString *userKey=[NSUserDefaultInfos getValueforKey:kUserKey];      //用户Key
    NSString *userToken=[NSUserDefaultInfos getValueforKey:kUserToken];  //用户token
    
    NSString *currentDateStr=[[TJYHelper sharedTJYHelper] getCurrentDateTime];
    NSInteger timeSp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:currentDateStr format:@"yyyy-MM-dd HH:mm"];  //时间戳
    NSString *appToken=[[[NSString stringWithFormat:@"%@%ld%@",kAppID,(long)timeSp,kAppSecret] MD5] uppercaseString];   //app签名
    NSDictionary *headDict=[[NSDictionary alloc] init];
    if (!kIsEmptyString(userToken)&&!kIsEmptyString(userKey)) {
        headDict=@{@"AppId":kAppID,@"AppToken":appToken,@"TimeStamp":[NSString stringWithFormat:@"%ld",(long)timeSp],@"UserKey":userKey,@"UserToken":userToken};
    }else{
        headDict=@{@"AppId":kAppID,@"AppToken":appToken,@"TimeStamp":[NSString stringWithFormat:@"%ld",(long)timeSp]};
    }
    [request setAllHTTPHeaderFields:headDict];
    MyLog(@"headerFields:%@",headDict);
    
    if ([method isEqualToString:@"POST"]) {
        NSData *bodyData=[body dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyData];
        MyLog(@"url:%@,bodyStr:%@",urlStr,body);
    }else{
        MyLog(@"url:%@",urlStr);
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [SVProgressHUD dismiss];
        if (data != nil) {
            NSString *html=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            MyLog(@"html:%@",html);
            id json=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            MyLog(@"json:%@",json);
            NSInteger status=[[json objectForKey:@"status"] integerValue];
            NSString *message=[json objectForKey:@"message"];
            if (status==1) {
                success(json);
            }else if(status==10001||status==10002||status==10003||status==10004||status==10000){
                AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate pushtoLoginVCWithStatus:status message:message];
            }else{
                message=kIsEmptyString(message)?@"暂时无法访问，请稍后再试":message;
                failure(message);
            }
        } else if (data == nil && connectionError == nil) {
            MyLog(@"接收到空数据");
        } else {
            MyLog(@"request %@ error:%@", urlStr,connectionError.localizedDescription);
            failure(connectionError.localizedDescription);
        }
    }];
}

#pragma mark 商城基本请求方法
-(void)requstShopMethod:(NSString *)method url:(NSString *)urlStr body:(NSString *)body isLoading:(BOOL)isLoading success:(HttpSuccess)success failure:(HttpFailure)failure{
    if (isLoading) {
        [SVProgressHUD show];
    }

    NSString *currentDateStr=[[TJYHelper sharedTJYHelper] getCurrentDateTime];
    NSInteger timeSp=[[TJYHelper sharedTJYHelper] timeSwitchTimestamp:currentDateStr format:@"yyyy-MM-dd HH:mm"];  //时间戳
    NSString *tempBodyStr=nil;
    if (kIsEmptyString(body)) {
        tempBodyStr=[NSString stringWithFormat:@"timestamp=%ld&version=01",(long)timeSp];
    }else{
        tempBodyStr=[NSString stringWithFormat:@"%@&timestamp=%ld&version=01",body,(long)timeSp];
    }
    NSString *sortedStr= [self getSortedStrWithParamsString:tempBodyStr method:method];
    NSString *tempSortedStr=[sortedStr stringByAppendingString:kShopAuthoriseCode];
    NSString *signStr=[tempSortedStr MD5];
    
    NSString *tempUrlStr=nil;
    NSString *bodyStr=nil;
    sortedStr=[sortedStr substringToIndex:sortedStr.length-1];
    if ([method isEqualToString:@"POST"]) {
        bodyStr=[NSString stringWithFormat:@"%@&sign=%@&sign_type=MD5",sortedStr,signStr];
        tempUrlStr=urlStr;
        MyLog(@"url:%@,bodyStr:%@",urlStr,bodyStr);
    }else{
       tempUrlStr=[NSString stringWithFormat:@"%@?%@&sign=%@&sign_type=MD5",urlStr,sortedStr,signStr];
        MyLog(@"url:%@",tempUrlStr);
    }
    
    NSURL *url=[NSURL URLWithString:tempUrlStr];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setHTTPMethod:method];
    
    if ([method isEqualToString:@"POST"]&&!kIsEmptyString(bodyStr)) {
        NSData *bodyData=[bodyStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyData];
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (isLoading) {
            [SVProgressHUD dismiss];
        }
        if (data != nil) {
            NSString *html=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            MyLog(@"html:%@",html);
            id json=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            MyLog(@"json:%@",json);
            NSInteger status=[[json objectForKey:@"status"] integerValue];
            NSString *message=[json objectForKey:@"message"];
            if (status==1) {
                success(json);
            }else if(status==10001||status==10002||status==10003||status==10004||status==10000){
                AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate pushtoLoginVCWithStatus:status message:message];
            }else{
                message=kIsEmptyString(message)?@"暂时无法访问，请稍后再试":message;
                failure(message);
            }
        } else if (data == nil && connectionError == nil) {
            MyLog(@"接收到空数据");
        } else {
            MyLog(@"request %@ error:%@", urlStr,connectionError.localizedDescription);
            failure(connectionError.localizedDescription);
        }
    }];
}

#pragma mark 请求参数按字母排序
-(NSString *)getSortedStrWithParamsString:(NSString *)paramsStr method:(NSString *)method{
    NSArray *subArray = [paramsStr componentsSeparatedByString:@"&"];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:4];
    for (int i = 0 ; i < subArray.count; i++){
        //在通过=拆分键和值
        NSArray *dicArray = [subArray[i] componentsSeparatedByString:@"="];
        //给字典加入元素
        [tempDic setObject:dicArray[1] forKey:dicArray[0]];
    }
    MyLog(@"打印参数列表生成的字典：%@", tempDic);
    
    NSArray *keys = [tempDic allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    NSMutableString *contentString  =[NSMutableString string];
    for (NSString *categoryId in sortedArray) {
        [contentString appendFormat:@"%@=%@&", categoryId, [tempDic valueForKey:categoryId]];
    }
    
    return contentString;
}


#pragma mark 数据统计
#pragma mark 点击事件
-(void)clickOnEventWithTargetId:(NSString *)target_id{
    
#if !DEBUG    
    
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    NSString *phoneScreen = [NSString stringWithFormat:@"%.0f*%.0f",kScreenHeight*2,kScreenWidth*2];
    NSString *body = [NSString stringWithFormat:@"target_id=%@&sn=%@&phone_sn=%@&phone_version=iOS&phone_screen=%@",target_id,uuid,[UIDevice iphoneType],phoneScreen];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kClickEventCount body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        
    }];
    
#endif
}

#pragma mark 分享事件
-(void)shareEventWithTargetID:(NSInteger)target_id way:(NSInteger)share_way type:(NSInteger)target_type name:(NSString *)target_name{
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    NSString *body = [NSString stringWithFormat:@"sn=%@&way=iPhone&request_platform=iOS&share_way=%ld&target_type=%ld&target_id=%ld&target_name=%@",uuid,share_way,target_type,(long)target_id,target_name];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kShareEventCount body:body success:^(id json) {
        
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark 页面统计事件
-(void)pageCountEventWithTargetID:(NSString *)target_id type:(NSInteger)type{
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    NSString *body = [NSString stringWithFormat:@"target_id=%@&sn=%@&type=%ld",target_id,uuid,(long)type];
    [[NetworkTool sharedNetworkTool] postMethodWithoutLoadingForURL:kPageEventCount body:body success:^(id json) {
        NSLog(@"----json=%@",json);
    } failure:^(NSString *errorStr) {
        
    }];
}



@end
