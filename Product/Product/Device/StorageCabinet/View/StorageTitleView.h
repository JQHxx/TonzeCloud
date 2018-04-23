//
//  StorageTitleView.h
//  Product
//
//  Created by vision on 17/6/12.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StorageTitleView;

@protocol  StorageTitleViewDelegate<NSObject>

-(void)storageTitleViewdidSetAction:(StorageTitleView *)storageTitleView;

@end

@interface StorageTitleView : UIView

@property (nonatomic,weak)id<StorageTitleViewDelegate>delegate;

@property (nonatomic, copy )NSString *titleStr;
@property (nonatomic,assign)NSInteger workType;

@end
