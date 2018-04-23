//
//  PersonListViewController.m
//  Product
//
//  Created by 梁家誌 on 16/8/21.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "PersonListViewController.h"
#import "PersonCell.h"
#import "Product-Swift.h"

@interface PersonListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    IBOutlet UITableView *personTableView;
    
}

@end

@implementation PersonListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor bgColor_Gray];
    self.baseTitle=@"设备记录";
    
    [personTableView registerNib:[UINib nibWithNibName:@"PersonCell" bundle:nil] forCellReuseIdentifier:@"PersonCell"];

}

#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"PersonCell";
    PersonCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    cell.personLabel.text = indexPath.row == 0?@"爸爸":@"妈妈";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BPMeter" bundle:nil];
    BPMRecordViewController *view = [storyboard instantiateViewControllerWithIdentifier:@"BPMRecordViewController"];
    view.personString = indexPath.row == 0?@"爸爸":@"妈妈";
    view.BPDevice = self.bpDevice;
    [self.navigationController pushViewController:view animated:YES];
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
