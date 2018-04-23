//
//  BodyHeaderView.h
//  Product
//
//  Created by vision on 17/5/4.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BodySectionModel;

typedef void(^BodyHeaderViewExpandCallback)(BOOL isExpanded);

@interface BodyHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) BodySectionModel *sectionModel;
@property (nonatomic,  copy ) BodyHeaderViewExpandCallback expandCallback;

@end
