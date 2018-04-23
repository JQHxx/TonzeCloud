//
//  FoodListViewController.m
//  Product
//
//  Created by 梁家誌 on 16/8/19.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "FoodListViewController.h"
#import "RecommendFoodCell.h"
#import "UIImageView+WebCache.h"
#import "FoodDetailViewController.h"
#import "HttpRequest.h"
#import "Product-Swift.h"

@interface FoodListViewController (){
    NSDictionary *menuDic;
    NSString *menuToken;
    
    IBOutlet UITableView *foodTableView;
    

}

@end

@implementation FoodListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle=@"食材推荐";
    
    menuToken = [UserManager shareManager].menuFuncToken;
    if (!menuToken) {
        [self getMenuToken];
    } else {
        [self doGetMenuWithOffset:@"0"];
    }
}

-(void)getMenuToken{
    
    [HttpRequest applyMenuTokendidLoadData:^(id result, NSError *err) {
        if (!err && [result isKindOfClass:[NSDictionary class]] && result[@"access_token"]) {
            menuToken = result[@"access_token"];
            [UserManager shareManager].menuFuncToken = menuToken;
            [self doGetMenuWithOffset:@"0"];
        }
    }];
    
}

//根据偏移量获取时令食材
- (void)doGetMenuWithOffset:(NSString *)offset {
    
    NSDictionary *queryDic=@{@"properties.push_rules":@{@"$in":@[self.discriptionString]}};
    NSDictionary *order=@{@"created_at":@"asc"};
    
    [HttpRequest getFoodWithOffset:offset withAccessToken:menuToken withLimit:@"4" withFilter:@[@"name",@"instructions",@"images"] withQuery:queryDic withOrder:order didLoadData:^(id result, NSError *err) {
        if (err) {
            NSLog(@"err(%ld): %@", (long)err.code, err.localizedDescription);
            if (err.code == 4031003) {
                [self performSelector:@selector(getMenuToken) withObject:nil afterDelay:1.0];
            }
        }else{
            NSLog(@"%@",result);
            
            menuDic=result;
            
            [foodTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
        }
    }];
}

#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[menuDic objectForKey:@"list"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"RecommendFoodCell";
    RecommendFoodCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"RecommendFoodCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    NSDictionary *dic=[[menuDic objectForKey:@"list"]objectAtIndex:indexPath.row];
    
    cell.titleLbl.text=[dic objectForKey:@"name"];
    cell.detailLbl.text=[dic objectForKey:@"instructions"];
    
    NSString *imgURL=[[dic objectForKey:@"images"] objectAtIndex:0]
    ;
    [cell.foodIV sd_setImageWithURL:[NSURL URLWithString:imgURL]
                   placeholderImage:[UIImage imageNamed:@"菜谱默认图.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    
    if (indexPath.row==[[menuDic objectForKey:@"list"] count]-1) {
        cell.lineLbl.hidden=NO;
    }else{
        cell.lineLbl.hidden=YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic=[[menuDic objectForKey:@"list"]objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FoodDetailViewController *view = [storyboard instantiateViewControllerWithIdentifier:@"FoodDetailViewController"];
    view.foodDic = dic;
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toDetailView"]) {
        FoodDetailViewController *VC=[segue destinationViewController];
        VC.foodDic=sender;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
