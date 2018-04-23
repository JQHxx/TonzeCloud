//
//  MessageClassificationViewController.m
//  Product
//
//  Created by 梁家誌 on 16/8/5.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "MessageClassificationViewController.h"
#import "MessageCenterViewController.h"
#import "MeasurementsViewController.h"
#import "TonzeHelpTool.h"

@interface MessageClassificationViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray *messageClassArr;
}


@property (strong, nonatomic) UITableView *messageTableView;

@end

@implementation MessageClassificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"消息中心";
    
    messageClassArr=@[@"设备工作",@"设备分享",@"测量结果",@"故障消息"];
    
    [self.view addSubview:self.messageTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-03" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-03" type:2];
#endif
}

#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return messageClassArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"MessageClassCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.textLabel.text=messageClassArr[indexPath.row];
    cell.imageView.image=[UIImage imageNamed:messageClassArr[indexPath.row]];
    cell.separatorInset=UIEdgeInsetsMake(0, 10, 0, 0);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *targetID=[NSString stringWithFormat:@"003-03-%02ld",(long)(indexPath.row+2)];
    [TonzeHelpTool sharedTonzeHelpTool].messageTargetId=targetID;
    if (indexPath.row == 2) {
#if !DEBUG
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:@"003-03-04"];
#endif

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MeasurementsViewController *view = [storyboard instantiateViewControllerWithIdentifier:@"MeasurementsViewController"];
        [self.navigationController pushViewController:view animated:YES];
    }else{
        
#if !DEBUG
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:targetID];
#endif
        MessageCenterViewController *view = [[MessageCenterViewController alloc] init];
        view.type = indexPath.row;
        [self.navigationController pushViewController:view animated:YES];
    }
}

#pragma mark -- Setters
-(UITableView *)messageTableView{
    if (_messageTableView==nil) {
        _messageTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight) style:UITableViewStylePlain];
        _messageTableView.backgroundColor=[UIColor bgColor_Gray];
        _messageTableView.dataSource=self;
        _messageTableView.delegate=self;
        _messageTableView.showsVerticalScrollIndicator=NO;
        _messageTableView.tableFooterView=[[UIView alloc] init];
    }
    return _messageTableView;
}



@end
