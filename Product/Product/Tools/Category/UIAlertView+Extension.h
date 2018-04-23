//
//  UIAlertView+Extension.h
//  Product
//
//  Created by zhuqinlu on 2017/5/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^CompleteBlock) (NSInteger buttonIndex);

@interface UIAlertView (Extension)

// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showAlertViewWithCompleteBlock:(CompleteBlock) block;

@end
