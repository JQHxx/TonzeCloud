//
//  NSString+Extension.m
//  Product
//
//  Created by WuJiezhong on 16/6/2.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "NSString+Extension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Extension)

+(BOOL)isEmpty:(NSString *)str{
    NSRange range = [str rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return YES; //yes代表包含空格
    }else {
        return NO; //反之
    }
}

+ (NSString *)hexStringWithInteger:(NSInteger)integer {
    NSString *str = @"";
    
    for (; integer != 0; integer >>= 8) {
        NSInteger tmp = integer & 0xFF;
        str = [NSString stringWithFormat:@"%@%02lX", str, (long)tmp];
    }
    return str;
}

- (BOOL)isEqualCaseInsensitive:(NSString *)aString {
    return [self caseInsensitiveCompare:aString] == NSOrderedSame;
}

#pragma mark --动态确定文本的宽高
- (CGSize)boundingRectWithSize:(CGSize)size withTextFont:(UIFont *)font {
    if ([self isEqualToString:@""]) {
        return CGSizeMake(0, 0);
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 0;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
}

#pragma mark-- 判断字符串是否为数字
+(BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

#pragma mark --MD5加密
- (NSString *)MD5{
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02x", result[i]];
    
    return [hash lowercaseString];
}
#pragma mark - 富文本操作

/**
 *  单纯改变一句话中的某些字的颜色
 *
 *  @param color    需要改变成的颜色
 *  @param totalStr 总的字符串
 *  @param subArray 需要改变颜色的文字数组
 *
 *  @return 生成的富文本
 */
+ (NSMutableAttributedString *)ql_changeCorlorWithColor:(UIColor *)color TotalString:(NSString *)totalStr SubStringArray:(NSArray *)subArray {
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:totalStr];
    for (NSString *rangeStr in subArray) {
        
        NSMutableArray *array = [self ql_getRangeWithTotalString:totalStr SubString:rangeStr];
        
        for (NSNumber *rangeNum in array) {
            
            NSRange range = [rangeNum rangeValue];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:color range:range];
        }
        
    }
    
    return attributedStr;
}
#pragma mark - 获取某个子字符串在某个总字符串中位置数组
/**
 *  获取某个字符串中子字符串的位置数组
 *
 *  @param totalString 总的字符串
 *  @param subString   子字符串
 *
 *  @return 位置数组
 */
+ (NSMutableArray *)ql_getRangeWithTotalString:(NSString *)totalString SubString:(NSString *)subString {
    
    NSMutableArray *arrayRanges = [NSMutableArray array];
    
    if (subString == nil && [subString isEqualToString:@""]) {
        return nil;
    }
    
    NSRange rang = [totalString rangeOfString:subString];
    
    if (rang.location != NSNotFound && rang.length != 0) {
        
        [arrayRanges addObject:[NSNumber valueWithRange:rang]];
        
        NSRange      rang1 = {0,0};
        NSInteger location = 0;
        NSInteger   length = 0;
        
        for (int i = 0;; i++) {
            
            if (0 == i) {
                
                location = rang.location + rang.length;
                length = totalString.length - rang.location - rang.length;
                rang1 = NSMakeRange(location, length);
            } else {
                
                location = rang1.location + rang1.length;
                length = totalString.length - rang1.location - rang1.length;
                rang1 = NSMakeRange(location, length);
            }
            
            rang1 = [totalString rangeOfString:subString options:NSCaseInsensitiveSearch range:rang1];
            
            if (rang1.location == NSNotFound && rang1.length == 0) {
                
                break;
            } else {
                
                [arrayRanges addObject:[NSNumber valueWithRange:rang1]];
            }
        }
        
        return arrayRanges;
    }
    
    return nil;
}

#pragma mark 改变一段文字某些字的颜色
+ (NSMutableAttributedString *)ql_changeRangeText:(NSString *)rangeText noRangeInedex:(NSInteger)noRangeInedex changeColor:(UIColor *)color{
    
    
    NSInteger rangeTextLength = [NSString stringWithFormat:@"%@",rangeText].length;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:rangeText];
    NSRange r1 = NSMakeRange(0, rangeTextLength - noRangeInedex);
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:r1];
    
    return attributedString;
}

#pragma mark 简单计算textsize
- (CGSize)sizeWithLabelWidth:(CGFloat)width font:(UIFont *)font{
    NSDictionary *dict=@{NSFontAttributeName : font};
    CGRect rect=[self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:dict context:nil];
    CGFloat sizeWidth=ceilf(CGRectGetWidth(rect));
    CGFloat sizeHieght=ceilf(CGRectGetHeight(rect));
    return CGSizeMake(sizeWidth, sizeHieght);
}

#pragma mark 判断用户数据是否改变
+ (BOOL)isNeedLoadData{
    BOOL isloadData;
    NSString *userId =[NSString stringWithFormat:@"%ld",(long)[TonzeHelpTool sharedTonzeHelpTool].user.user_id];
    NSString *sex = [NSString stringWithFormat:@"%ld",(long)[TonzeHelpTool sharedTonzeHelpTool].user.sex];
    NSString *birthday =[NSString stringWithFormat:@"%@",[TonzeHelpTool sharedTonzeHelpTool].user.birthday];
    NSString *height = [NSString stringWithFormat:@"%@",[TonzeHelpTool sharedTonzeHelpTool].user.height];
    NSString *weight =[NSString stringWithFormat:@"%@",[TonzeHelpTool sharedTonzeHelpTool].user.weight];
    NSString *userInfoStr = [NSString stringWithFormat:@"%@%@%@%@%@",userId,sex,birthday,height,weight];
    
    if (kIsEmptyString(sex) && kIsEmptyString(birthday) && kIsEmptyString(userId) && kIsEmptyString(height) && kIsEmptyString(birthday)) {
        NSString *saveUserInfo = [NSUserDefaultInfos getValueforKey:KuserInfo];
        if (kIsEmptyString(saveUserInfo)) {
            if ([userInfoStr isEqualToString:saveUserInfo]) {
                isloadData = NO;
            }else{
                isloadData = YES;
            }
        }else{
            [NSUserDefaultInfos putKey:KuserInfo andValue:userInfoStr];
        }
    }else{
        isloadData = NO;
        [NSUserDefaultInfos removeObjectForKey:KuserInfo];
    }
    return isloadData;
}

+ (NSString *)ql_getStepTimeWithTime:(NSInteger)time{
    NSInteger remainingSeconds = time;
    NSInteger hours = remainingSeconds / 3600;
    remainingSeconds = remainingSeconds - hours * 3600;
    NSInteger minutes = remainingSeconds / 60;
    remainingSeconds = remainingSeconds - minutes * 60;
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"间隔%ld小时%ld分钟%ld秒", (long)hours, (long)minutes, (long)remainingSeconds];
    } else if (minutes > 0) {
        return [NSString stringWithFormat:@"间隔%ld分钟%ld秒",(long)minutes,(long)remainingSeconds];
    } else {
        return [NSString stringWithFormat:@"间隔%ld秒",(long) remainingSeconds];
    }
}


+ (NSString *)ql_getDeviceCodeWithCloudMenu:(NSString *)cloudMenu type:(NSInteger)type cookerTag:(NSInteger )cookerTag isPreference:(BOOL)isPreference{
    
    NSString *commandStr=@"140000";
    switch (type) {
        case CLOUD_COOKER:
        case WATER_COOKER:
        {
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"08",@"0000"]];
            NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
            commandStr=[commandStr stringByAppendingString:controlStr];
        }break;
        case ELECTRIC_COOKER:
        {
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"0E",@"0000"]];
            NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
            commandStr=[commandStr stringByAppendingString:controlStr];
        }break;
        case CLOUD_KETTLE:
        {
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"07",@"0000"]];
            NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
            commandStr=[commandStr stringByAppendingString:controlStr];
        }break;
        case WATER_COOKER_16AIG:
        {// 判断其为降压粥 || 降压汤
            if (cookerTag == 1) {// -- 降压粥
                if (isPreference) {// -- 偏好指令
                    commandStr =@"13000005";
                    commandStr=[commandStr stringByAppendingString:cloudMenu];
                    
                }else{// 启动指令
                    commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"05",@"0000"]];
                    NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
                    commandStr=[commandStr stringByAppendingString:controlStr];
                }
            }else{ // -- 降压汤
                if (isPreference) {// -- 偏好指令
                    commandStr =@"13000006";
                    commandStr=[commandStr stringByAppendingString:cloudMenu];
                }else{// 启动指令
                    commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"06",@"0000"]];
                    NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
                    commandStr=[commandStr stringByAppendingString:controlStr];
                }
            }
        }break;
        case COOKFOOD_KETTLE:
        {
            commandStr =[commandStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"06",@"0000"]];
            NSString *controlStr=[NSString stringWithFormat:@"%@",cloudMenu];
            commandStr=[commandStr stringByAppendingString:controlStr];
        }break;
        default:
            break;
    }
    return commandStr;
}

// 浮点型数据不四舍五入
+ (NSString *)notRounding:(NSString *)price afterPoint:(NSInteger)position
{
    if ([price isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)price;
        ;
        price = [NSString stringWithFormat:@"%lf",[number doubleValue]];
    }
    
    if ([price isKindOfClass:[NSNumber class]] && price) {
        price = [NSString stringWithFormat:@"%@",price];
    }else{
        if (kIsEmptyString(price)) {
            return nil;
        }
    }
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal = nil;
    NSDecimalNumber *roundedOunces = nil;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithString:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    return [NSString stringWithFormat:[NSString formatStringWithPiontNum:position],[roundedOunces doubleValue]];
}
///浮点型:保留几位小数 格式字符串
+ (NSString *)formatStringWithPiontNum:(NSInteger)pointNum
{
    NSString *format;
    switch (pointNum) {
        case 0:
            format = @"%f";
            break;
        default:
            format = [NSString stringWithFormat: @"%@%lu%@",@"%.",(unsigned long)pointNum,@"f"];
            break;
    }
    return format;
}

+ (NSString *)ql_phoneNumberCodeText:(NSString *)text{
    if (text.length == 11) {
        
        NSString *tel = [text stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        return tel;
    }else{
        return nil;
    }
}

@end
