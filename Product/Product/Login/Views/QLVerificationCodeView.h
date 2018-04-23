//
//  QLVerificationCodeView.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2018/2/28.
//  Copyright © 2018年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VertificationCodeBlock)(NSString *codeStr);

@interface QLVerificationCodeView : UIView

@property(nonatomic,assign)NSInteger VerificationCodeNum;//验证码位数

@property(nonatomic,assign)BOOL isSecure;//是否密文显示

@property(nonatomic,assign)CGFloat Spacing;//每个格子间距


@property (nonatomic, strong,readonly) NSString *vertificationCode;//验证码内容

@property (nonatomic, strong)UIColor *deselectColor;//未选中颜色

@property (nonatomic, strong)UIColor *selectedColor;//选中颜色

@property (nonatomic, strong)NSMutableArray *textFieldArray;//放textField的array用于在外面好取消键盘

/// 验证码回调
@property (nonatomic, copy) VertificationCodeBlock vertificationCodeBlock ;

// 清除验证码
- (void)celanVerificationCode;

@end
