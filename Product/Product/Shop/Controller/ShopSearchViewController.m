//
//  ShopSearchViewController.m
//  Product
//
//  Created by 肖栋 on 17/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "ShopSearchViewController.h"
#import "ShopSearchTableView.h"
#import "ShopSearchResultViewController.h"
#import "ShopDetailViewController.h"

@interface ShopSearchViewController ()<UISearchBarDelegate,ShopSearchTableViewDelegate,ShopSearchResultDelegate>{
    NSMutableArray                 *friendHistoryArray;
    
    ShopSearchResultViewController   *searchResultViewController;    //搜索结果展示
}

@property (nonatomic,strong)UISearchBar         *mySearchBar;         //搜索框
@property (nonatomic,strong)ShopSearchTableView   *searchTableView;     //历史记录
@property (nonatomic, assign) BOOL     isLogin;        // 是否登入
@end

@implementation ShopSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenBackBtn=YES;
    self.view.backgroundColor=[UIColor bgColor_Gray];
    
    friendHistoryArray=[[NSMutableArray alloc] init];
    
    [self.view addSubview:self.mySearchBar];
    [self.view addSubview:self.searchTableView];
    
    [self requestHotSearchWords];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _isLogin =[[NSUserDefaultInfos getValueforKey:kIsLogin] boolValue];
    
    if ([TJYHelper sharedTJYHelper].isSearchKeyboard==YES) {
        [self.mySearchBar becomeFirstResponder];
        [TJYHelper sharedTJYHelper].isSearchKeyboard = NO;
    }
}

#pragma mark -- CustomDelegate
#pragma mark  TCSearchTableViewDelegate
- (void)shopSearchTableViewWillBeginDragging:(ShopSearchTableView *)searchTableView{
    [self.mySearchBar resignFirstResponder];
    [self setSearchBarCancelButton];
}

#pragma amrk 选择搜索词
- (void)shopSearchtableView:(ShopSearchTableView *)searchTableView didSelectKeyword:(NSString *)keyword{
    self.mySearchBar.text=keyword;
    [self searchBarSearchButtonClicked:self.mySearchBar];
}

#pragma mark 清除历史记录
- (void)shopSearchTableViewDidDeleteAllHistory:(ShopSearchTableView *)searchTableView{
    [NSUserDefaultInfos removeObjectForKey:@"sugarFriendHistory"];
    [friendHistoryArray removeAllObjects];
    self.searchTableView.historyRecordsArray=friendHistoryArray;
    [self.searchTableView reloadData];
}
#pragma mark -- 删除单条历史纪录
- (void)deleteHistoryRecord:(NSMutableArray *)history{
    self.searchTableView.historyRecordsArray=history;
    [self.searchTableView reloadData];
}
#pragma mark -- 点击热门搜索
- (void)seleteHotSearch:(ShopSearchTableView *)searchTableView didSelectTitle:(NSString *)title{
    self.mySearchBar.text=title;
    [self searchBarSearchButtonClicked:self.mySearchBar];
}
#pragma mark -- ShopSearchResultDelegate
#pragma mark -- 点击搜索结果查看商品
- (void)seleteSearchShopID:(NSInteger)goods_id{
    ShopDetailViewController *shopDetailVC = [[ShopDetailViewController alloc] init];
    shopDetailVC.product_id = goods_id;
    [self.navigationController pushViewController:shopDetailVC animated:YES];
}
#pragma mark -- Network Methods
#pragma mark 加载历史搜索记录
-(void)requestHotSearchWords{
    NSArray *tempArr=(NSArray *)[NSUserDefaultInfos getValueforKey:@"sugarFriendHistory"];
    if (kIsArray(tempArr)) {
        friendHistoryArray=[[NSMutableArray alloc] initWithArray:tempArr];
        self.searchTableView.historyRecordsArray=friendHistoryArray;
    }else{
        self.searchTableView.historyRecordsArray=friendHistoryArray;
    }

     [[NetworkTool sharedNetworkTool] postShopMethodWithURL:KShopHotKeyWords body:@"" success:^(id json) {
         
         NSArray *result = [json objectForKey:@"result"];
         self.searchTableView.hotSearchWordsArray =[NSMutableArray arrayWithArray:result];
         [self.searchTableView reloadData];
         
     } failure:^(NSString *errorStr) {
         [self.searchTableView reloadData];
     }];

    
}

#pragma mark -- Private Methods
#pragma mark 设置取消按钮
-(void)setSearchBarCancelButton{
    for (id cc in [self.mySearchBar.subviews[0] subviews]) {
        if ([cc isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)cc;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.enabled=YES;
        }
    }
}

#pragma mark -- Getters and Setters
#pragma mark 搜索框
-(UISearchBar *)mySearchBar{
    if (_mySearchBar==nil) {
        _mySearchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, KStatusHeight +( kNavigationHeight - 28)/2, kScreenWidth, 28)];
        _mySearchBar.delegate=self;
        _mySearchBar.placeholder=@"输入商品关键词";
        
        UITextField *textField = [_mySearchBar valueForKey:@"_searchField"];
        UIImage *image = [UIImage imageNamed:@"ic_shop_search"];
        UIImageView *leftImg = [[UIImageView alloc] initWithImage:image];
        leftImg.frame = CGRectMake(0,0,image.size.width, image.size.height);
        textField.leftView = leftImg;
        
        
        textField.backgroundColor = [UIColor colorWithHexString:@"0xf9c877"];
        [textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        textField.textColor = [UIColor whiteColor];
        textField.layer.cornerRadius = 14;
        [_mySearchBar setBackgroundImage:[UIImage imageWithColor:kSystemColor size:CGSizeMake(kScreenWidth, kNavigationHeight)]];
    }
    return _mySearchBar;
}

#pragma mark 历史记录
-(ShopSearchTableView *)searchTableView{
    if (_searchTableView==nil) {
        _searchTableView=[[ShopSearchTableView alloc] initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight) style:UITableViewStyleGrouped];
        _searchTableView.shopSearchDelegate=self;
        _searchTableView.scrollsToTop = NO;
    }
    return _searchTableView;
}

#pragma mark -- UISearchBarDelegate
#pragma mark 搜索框编辑开始
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self.mySearchBar setShowsCancelButton:YES animated:YES];
    [self setSearchBarCancelButton];
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{  if ([searchBar isFirstResponder]) {
    
    if ([[[searchBar textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[searchBar textInputMode] primaryLanguage]) {
        return NO;
    }
    
    //判断键盘是不是九宫格键盘
    if ([[TJYHelper sharedTJYHelper] isNineKeyBoard:text] ){
        return YES;
    }else{
        if ([[TJYHelper sharedTJYHelper] hasEmoji:text] || [[TJYHelper sharedTJYHelper] strIsContainEmojiWithStr:text]){
            return NO;
        }
    }
}
    return YES;
    
}
#pragma mark 点击搜索
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    BOOL isSearchBool = [[TJYHelper sharedTJYHelper] strIsContainEmojiWithStr:searchBar.text];
    if (isSearchBool) {
        [self.view makeToast:@"不能搜索特殊符号" duration:1.0 position:CSToastPositionCenter];
        [self.mySearchBar resignFirstResponder];
        [self setSearchBarCancelButton];
    } else {
        [self.mySearchBar resignFirstResponder];
        [self setSearchBarCancelButton];
        
        NSString *searchText=[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        searchBar.text=searchText;
        if (kIsEmptyString(searchText)) {
            searchBar.text=@"";
            [self showAlertWithTitle:@"" Message:@"请输入商品关键词"];
        }else{
            if (searchResultViewController==nil) {
                searchResultViewController=[[ShopSearchResultViewController alloc] init];
            }
            searchResultViewController.tableView.scrollsToTop = YES;
            searchResultViewController.view.frame=CGRectMake(0, kNewNavHeight, kScreenWidth, kRootViewHeight);
            searchResultViewController.shopSearchDelegate=self;
            searchResultViewController.page = 1;
            searchResultViewController.keyword=searchText;
            [self.view addSubview:searchResultViewController.view];
            
            if (![friendHistoryArray containsObject:searchText]) {
                [friendHistoryArray insertObject:searchText atIndex:0];
            }else{
                NSMutableArray *history = [[NSMutableArray alloc] init];
                for (int i=0; i<friendHistoryArray.count; i++) {
                    if ([friendHistoryArray[i] isEqualToString:searchText]) {
                        [history insertObject:friendHistoryArray[i] atIndex:0];
                    }else{
                        [history addObject:friendHistoryArray[i]];
                    }
                }
                friendHistoryArray = history;
            }
            [NSUserDefaultInfos putKey:@"sugarFriendHistory" andValue:friendHistoryArray];
        }
    }
}

#pragma mark 点击取消按钮
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 点击空白收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


@end
