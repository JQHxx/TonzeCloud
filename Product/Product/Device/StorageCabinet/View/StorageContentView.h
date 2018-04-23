//
//  StorageContentView.h
//  Product
//
//  Created by vision on 17/6/12.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StorageContentViewDelegate <NSObject>

-(void)storageContentViewSaveFoodAction;

@end

@interface StorageContentView : UIView

@property (nonatomic,weak)id<StorageContentViewDelegate>delegate;
@property (nonatomic,strong)NSDictionary  *foodCountDict;
@property (nonatomic,assign)NSInteger humidityValue;
@property (nonatomic,assign)NSInteger temperatureValue;


@end
