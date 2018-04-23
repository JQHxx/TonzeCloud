//
//  SceneNameAlertView.h
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^removeCoverAndInputView)(NSString *inputContent);

@interface SceneNameAlertView : UIView

@property (nonatomic, copy) NSString *inputText;

@property (nonatomic,strong)UITextField    *textField_input;


@property (nonatomic, copy) removeCoverAndInputView removeView;

@end
