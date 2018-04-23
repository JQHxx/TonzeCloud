//
//  SubscriberInfoCell.h
//  Product
//
//  Created by zhuqinlu on 2017/12/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscriberInfoCell : UITableViewCell

///
@property (nonatomic ,copy) NSString     *iconStr;
///
@property (nonatomic ,copy) NSString     *titleStr;
///
@property (nonatomic ,copy) NSString     *subStr;
///
@property (nonatomic ,copy) NSString     *iconImgStr;

@property (nonatomic ,strong) UIImageView *arrowImg;


@end
