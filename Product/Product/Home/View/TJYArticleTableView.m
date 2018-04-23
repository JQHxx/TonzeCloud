//
//  TCArticleTableView.m
//  TonzeCloud
//
//  Created by vision on 17/2/17.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TJYArticleTableView.h"
#import "TJYArticleTableViewCell.h"
#import "TJYArticleModel.h"

@implementation TJYArticleTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self=[super initWithFrame:frame style:style];
    if (self) {
        self.delegate=self;
        self.dataSource=self;
        self.showsVerticalScrollIndicator=NO;
        self.tableFooterView=[[UIView alloc] init];
    }
    return self;
}

-(void)setArticlesArray:(NSMutableArray *)articlesArray{
    if (_articlesArray==nil) {
        _articlesArray=[[NSMutableArray alloc] init];
    }
    _articlesArray=articlesArray;
}

-(void)setType:(NSInteger)type{
    _type=type;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.articlesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"TCArticleTableViewCell";
    TJYArticleTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[TJYArticleTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    TJYArticleModel *article=self.articlesArray[indexPath.row];
    [cell cellDisplayWithModel:article type:self.type searchText:@""];
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.type==0?@"推荐阅读":nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100 * kScreenWidth/320;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.type==0?30:0.01;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    TJYArticleModel *article=self.articlesArray[indexPath.row];
    [self.articleDetagate returnarticleIndex:article.article_management_id articleTitle:article.title isCollection:article.is_collection index:indexPath.row imgUrl:article.image_url];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.articlesArray.count; i++ ) {
        TJYArticleModel *model = self.articlesArray[i];
        if (i == indexPath.row) {
            model.reading_number = model.reading_number + 1;
        }
        [dataArray addObject:model];
    }
    self.articlesArray = dataArray;
    [self reloadData];
}
@end
