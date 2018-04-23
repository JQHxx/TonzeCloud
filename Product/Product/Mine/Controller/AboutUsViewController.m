//
//  AboutUsViewController.m
//  Product
//
//  Created by Xlink on 15/12/4.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "AboutUsViewController.h"
#import "IntroduceViewController.h"
#import "BasewebViewController.h"
#import "TonzeHelpTool.h"

#define PHONE_NUMBER @"400-900-4288"
#define kBussinessPhone   @"13823391609"

@interface AboutUsViewController ()<UITableViewDelegate, UITableViewDataSource>{
    UITableView    *table;
}

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"关于我们";
    
    
    [self initRootView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-05-06" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-05-06" type:2];
#endif
}


#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.textColor = UIColorFromRGB(0x343434);
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:{
            cell.textLabel.text = @"公司简介";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = nil;
        }
            break;
        case 1:{
            cell.textLabel.text = @"平台介绍";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = nil;
        }
            break;
        case 2:{
            cell.textLabel.text = @"用户协议";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text= nil;
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"客服电话";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.text = PHONE_NUMBER;
            cell.detailTextLabel.textColor = UIColorFromRGB(0xF08201);
        }
            break;
        case 4:
            cell.textLabel.text = @"商务合作";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.text = kBussinessPhone;
            cell.detailTextLabel.textColor = UIColorFromRGB(0xF08201);
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 180;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header =[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 210)];
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2, 30, 100, 100)];
    imgView.image=[UIImage imageNamed:@"tjy_ic_logo"];
    [header addSubview:imgView];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-150)/2, imgView.bottom, 150, 30)];
    titleLabel.textColor=kSystemColor;
    titleLabel.font=[UIFont boldSystemFontOfSize:16];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.text=APP_DISPLAY_NAME;
    [header addSubview:titleLabel];
    
    UILabel *versionLabel=[[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-150)/2, titleLabel.bottom, 150, 20)];
    versionLabel.textColor=[UIColor lightGrayColor];
    versionLabel.font=[UIFont systemFontOfSize:12];
    versionLabel.textAlignment=NSTextAlignmentCenter;
    versionLabel.text=[NSString stringWithFormat:@"V%@", APP_VERSION];
    [header addSubview:versionLabel];
    
    return header;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-05-07"];
#endif
            IntroduceViewController *introduceVC=[[IntroduceViewController alloc] init];
            introduceVC.isCompany=YES;
            [self.navigationController pushViewController:introduceVC animated:YES];
        }
            break;
        case 1:
        {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-05-08"];
#endif
            IntroduceViewController *introduceVC=[[IntroduceViewController alloc] init];
            introduceVC.isCompany=NO;
            [self.navigationController pushViewController:introduceVC animated:YES];
        }
            break;
        case 2:
        {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-05-09"];
#endif
            [TonzeHelpTool sharedTonzeHelpTool].viewType=WebViewTypeUserAgreenment;
            BasewebViewController *webVC=[[BasewebViewController alloc] init];
            webVC.titleText= @"用户协议";
            webVC.isWebUrl = YES;
            webVC.urlStr=@"http://api-h.360tj.com/shared/reg/tjyHealthUserProtocol.html";
            webVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:webVC animated:YES];

        }
            break;
        case 3:
        {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-05-10"];
#endif
            NSString *urlStr = [NSString stringWithFormat:@"telprompt://%@", PHONE_NUMBER];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
            break;
        }
        case 4:
        {
#if !DEBUG
            [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-05-11"];
#endif
            NSString *urlStr = [NSString stringWithFormat:@"telprompt://%@", kBussinessPhone];

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
            break;
        }
        default:
            break;
    }
}

#pragma mark --Custom Methods
-(void)initRootView{
    table=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    table.dataSource=self;
    table.delegate=self;
    table.showsVerticalScrollIndicator=NO;
    table.tableFooterView=[[UIView alloc] init];
    table.bounces=NO;
    [self.view addSubview:table];
}

@end
