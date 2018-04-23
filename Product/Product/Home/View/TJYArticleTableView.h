//
//  TCArticleTableView.h
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TCArticleExpertDelegate <NSObject>
@required
- (void)returnarticleIndex:(NSInteger)expert_id articleTitle:(NSString *)title isCollection:(BOOL)isCollection index:(NSInteger)index imgUrl:(NSString *)imgUrl;
@end
@interface TJYArticleTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign)NSInteger      type;
@property (nonatomic,strong)NSMutableArray *articlesArray;

@property (nonatomic,weak) id <TCArticleExpertDelegate> articleDetagate;

@end
