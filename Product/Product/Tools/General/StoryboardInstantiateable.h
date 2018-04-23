//
//  StoryboardInstaceableViewController.h
//  Product
//
//  Created by WuJiezhong on 16/6/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryboardInstantiateableViewController : UIViewController

@end


@protocol StoryboardInstantiateable <NSObject>

///从Storyboard中取到ViewController对象
+ (instancetype)instantiateOfStoryboard;

@end