//
//  DrinkRemindViewController.m
//  Product
//
//  Created by Feng on 16/3/21.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DrinkRemindViewController.h"
#import "YTKKeyValueStore.h"
#import "Transform.h"
#import "DrinkRemindCell.h"
#import "AddRemindViewController.h"
#import "DrinkPlanViewController.h"
#import "NotificationHandler.h"
#import "DeviceHelper.h"


@interface DrinkRemindViewController ()<UITextFieldDelegate,UIAlertViewDelegate>{

    YTKKeyValueStore *YTKHelper;
    
    NSMutableArray *remindArr;//提醒数组，从本地获取
    
    NSMutableArray *switchArr;  //开关数组
    
    
    UIAlertAction *OkBtnEnabledAction;
    
    BOOL allIsOn;
}

@end

@implementation DrinkRemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor bgColor_Gray];
    self.baseTitle=@"饮水提醒";
    
    switchArr=[[NSMutableArray alloc]init];
    remindArr=[[NSMutableArray alloc]init];
    
    if (!YTKHelper) {
        YTKHelper = [[YTKKeyValueStore alloc] initDBWithName:@"TJProduct.db"];
    }
    
    drinkValueLbl.text=[NSString stringWithFormat:@"%dml",1600];
    
    [self getAllRecord];
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NotificationHandler shareHendler]setNextRemindNoti];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateUIafterAddRemind{

   [[NotificationHandler shareHendler]setNextRemindNoti];
    
    [self getAllRecord];

    
}

-(IBAction)smartDistribute:(id)sender{
    return;
}

-(IBAction)editRemind:(id)sender{

    editRemindBtn.selected=!editRemindBtn.selected;
    
    [remindTB reloadData];
    
    
}

-(IBAction)addRemind:(id)sender{

     [self performSegueWithIdentifier:@"toRemindView" sender:sender];
}


-(IBAction)setTotalValue:(id)sender{

    [self showAddRecordAlertController];
}


#pragma mark AlertController
-(void)showAddRecordAlertController{
    NSString *title = NSLocalizedString(@"喝水量", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        //        [textField setBorderStyle:UITextBorderStyleRoundedRect];
        [textField setPlaceholder:@"1600 ml"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setKeyboardType:UIKeyboardTypeNumberPad]; //只能输入数字
        
        
        [textField becomeFirstResponder];
        
        textField.delegate=self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
        
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [alertController.textFields.firstObject resignFirstResponder];
        alertController.textFields.firstObject.text = [alertController.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (alertController.textFields.firstObject.text.length>6||alertController.textFields.firstObject.text.length<1) {
//            [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.7f];
            [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:YES];

        }else{
            
            drinkValueLbl.text=[NSString stringWithFormat:@"%@ml",alertController.textFields.firstObject.text];
            
            [NSUserDefaultInfos putInt:DRINK_VALUE andValue:alertController.textFields.firstObject.text.intValue];
            
            
            NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
            
            DrinkPlanViewController *planVC=[self.navigationController.viewControllers objectAtIndex:index-1];
            
            [planVC updateDrankView];
            
        }
    }];
    
    otherAction.enabled = NO;
    OkBtnEnabledAction = otherAction;//定义一个全局变量来存储
    
    
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    alertController.view.layer.cornerRadius = 20;
    alertController.view.layer.masksToBounds = YES;
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

//当用户输入一个字符以上时，才能点击确定按钮
- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    OkBtnEnabledAction.enabled = textField.text.length >= 1;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.text.length>6||textField.text.length<1) {
        
        [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.7f];
        
    }
    return YES;
}

-(void)showAlert{
    [self showAlertWithTitle:@"提示" Message:@"仅支持1-6个字符"];
}

- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message {
    
    NSString *otherButtonTitle = NSLocalizedString(@"好的", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
    }];
    
    // Add the actions.
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark Database

#pragma mark 获取所有记录
-(void)getAllRecord{
    
    remindArr=[[NSMutableArray alloc]init];
    switchArr=[[NSMutableArray alloc]init];

    [switchArr addObject:[[UISwitch alloc]init] ];//总开关
    
    //排序条件
    NSDictionary *orderDic=[[NSDictionary alloc]initWithObjectsAndKeys:@"asc",@"time", nil];
    
    //查询条件
    NSDictionary *queryDic=@{@"deviceid":@{@"$in":@[self.model.mac]}};
    
    NSDictionary *sqlDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",orderDic,@"order",queryDic,@"query", nil];
    
    NSDictionary *resultDic=[YTKHelper queryDataWithJSON:[Transform DataToJsonString:sqlDic]];
    
    remindArr=[resultDic objectForKey:@"list"];
    
    allIsOn=NO;
    for (NSMutableDictionary *dic in remindArr) {
        
        [switchArr addObject:[[UISwitch alloc]init]];
        
        if ([[dic objectForKey:@"isOn"] integerValue]==1) {
            allIsOn=YES;
        }
    }
    
    if (remindArr.count<10) {
        addRemindBtn.enabled=YES;
    }else{
        addRemindBtn.enabled=NO;
        
    }

    [remindTB performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
}


-(void)changeRemind:(id)sender{

    UISwitch *tapSwitch=sender;
    
    NSInteger remindID=tapSwitch.tag; //remind ID 为用户点击tableview 时的indexPath.raw
    
    if (remindID==0) {
        //总开关
        allIsOn=tapSwitch.isOn;
        
        
        [self handleAllRemind:tapSwitch.on];
        
        for (NSMutableDictionary *dic in remindArr) {
            [dic setObject:tapSwitch.isOn?@"1":@"0" forKey:@"isOn"];

        }
        [remindTB reloadData];

        
    }else{
        
         NSMutableDictionary *dic=[remindArr objectAtIndex:remindID-1];
        [dic setObject:tapSwitch.isOn?@"1":@"0" forKey:@"isOn"];
        
        UISwitch *allControllSwitch=[switchArr objectAtIndex:0];
        
        [allControllSwitch setOn:NO];
         allIsOn=NO;
        
        for (UISwitch *Rswitch in switchArr) {
            
            
            
            if (Rswitch.isOn&&!allControllSwitch.isOn) {
                
                [allControllSwitch setOn:YES];
                allIsOn=YES;
                break;
            }
        }
//        [self handleEachRemind:[[dic objectForKey:@"_id"] integerValue] IsOn:tapSwitch.on];
        //by liang
        [self handleEachRemind:[[dic objectForKey:@"id"] integerValue] IsOn:tapSwitch.on];
        
          [remindTB reloadData];
    }
    
    
    [[NotificationHandler shareHendler]setNextRemindNoti];
    
    
}

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    
    return 1;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 下面这几行代码是用来设置cell的上下行线的位置
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    //控制分割线不缩进
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [remindArr count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.row==0) {
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.textLabel.text=@"饮水提醒";
        
        
        UISwitch *remindSwitch=[switchArr objectAtIndex:0];
        
        remindSwitch.frame=CGRectMake(SCREEN_WIDTH-remindSwitch.frame.size.width-20, 10, remindSwitch.frame.size.width, remindSwitch.frame.size.height);
        
        [remindSwitch setOn:allIsOn];
        
        remindSwitch.tag=indexPath.row;
        
        [remindSwitch addTarget:self action:@selector(changeRemind:) forControlEvents:UIControlEventValueChanged];
        
        
        [cell addSubview:remindSwitch];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        return cell;
    }else{
    
        NSDictionary *dic=[remindArr objectAtIndex:indexPath.row-1];
        
        if (editRemindBtn.isSelected) {
            //编辑模式
            {
                static NSString *CellIdentifier = @"Cell";
                UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                
                cell.textLabel.text=[dic objectForKey:@"time"];
                
                cell.detailTextLabel.text=[dic objectForKey:@"value"];
                
           
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator ;
                cell.selectionStyle=UITableViewCellSelectionStyleNone;

                
                return cell;
            }
            
        }
        else{
            
            
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            

            cell.textLabel.text=[dic objectForKey:@"time"];
            
            cell.detailTextLabel.text=[dic objectForKey:@"value"];
            
            UISwitch *remindSwitch=[switchArr objectAtIndex:indexPath.row];
            
            if ([[dic objectForKey:@"isOn"] integerValue]==0) {
                [remindSwitch setOn:NO];
                
            }else{
                [remindSwitch setOn:YES];
            }
            
             remindSwitch.tag=indexPath.row;
            
            [remindSwitch addTarget:self action:@selector(changeRemind:) forControlEvents:UIControlEventValueChanged];
              remindSwitch.frame=CGRectMake(SCREEN_WIDTH-remindSwitch.frame.size.width-20, 10, remindSwitch.frame.size.width, remindSwitch.frame.size.height);
            
            [cell addSubview:remindSwitch];
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            return cell;
        }
        
    }

}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row!=0&&editRemindBtn.selected) {
      //不是总开关并且是在编辑模式时才能删除
        return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleNone;
    }
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
   [self showDelectAlertController:indexPath];
    
}
-(void)showDelectAlertController:(NSIndexPath *)indexPath{
    
    
    NSString *title = NSLocalizedString(@"删除提示", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    
    NSString *text=[NSString stringWithFormat:@"确定删除当前提醒？"];
    NSString *okButtonTitle = NSLocalizedString(@"删除", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
       NSDictionary *dic=[remindArr objectAtIndex:indexPath.row-1];
        
        [remindArr removeObject:dic];
        
//        [self removeRemind:[[dic objectForKey:@"_id"] integerValue]];
        //by liang
        [self removeRemind:[[dic objectForKey:@"id"] integerValue]];
        
        [switchArr removeObjectAtIndex:indexPath.row];
        
        
        
        if (remindArr.count<10) {
            addRemindBtn.enabled=YES;
        }else{
            addRemindBtn.enabled=NO;
            
        }
        
        [[NotificationHandler shareHendler]setNextRemindNoti];
        
        [remindTB performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    alertController.view.layer.cornerRadius = 20;
    alertController.view.layer.masksToBounds = YES;
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row==0) {
        
    }
    else{
    
        if (editRemindBtn.isSelected) {
            
            [self performSegueWithIdentifier:@"toRemindView" sender:indexPath];
            
        }else{
            return;
            
        }
    }

}

#pragma mark 总开关
-(void)handleAllRemind:(BOOL)on{

    [switchArr enumerateObjectsUsingBlock:^(UISwitch  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setOn:on];
    }];
    
    //数据库
    NSDictionary *dataDic=@{@"isOn":[NSString stringWithFormat:@"%i",on]};
    
    NSDictionary *sqlDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data", nil];
    
    [YTKHelper updateData:[Transform DataToJsonString:sqlDic]];
    
}

#pragma mark 处理单个
-(void)handleEachRemind:(NSInteger )remindID IsOn:(BOOL)on{
    
    //数据库
    NSDictionary *dataDic=@{@"isOn":[NSString stringWithFormat:@"%i",on]};
    
    //查询条件
//    NSDictionary *queryDic=@{@"deviceid":@{@"$in":@[[NSString stringWithFormat:@"%@",self.model.mac]]},@"_id":@{@"$in":@[[NSString stringWithFormat:@"%li",(long)remindID]]}};
    //by liang
    NSDictionary *queryDic=@{@"deviceid":@{@"$in":@[[NSString stringWithFormat:@"%@",self.model.mac]]},@"id":@{@"$in":@[[NSString stringWithFormat:@"%li",(long)remindID]]}};

    
    NSDictionary *sqlDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",dataDic,@"data",queryDic,@"query", nil];
    
    [YTKHelper updateData:[Transform DataToJsonString:sqlDic]];
    
}

#pragma mark 移除单个
-(void)removeRemind:(NSInteger )remindID{
    
    //查询条件
//    NSDictionary *queryDic=@{@"deviceid":@{@"$in":@[[NSString stringWithFormat:@"%@",self.model.mac]]},@"_id":@{@"$in":@[[NSString stringWithFormat:@"%li",(long)remindID]]}};
    //by liang
    NSDictionary *queryDic=@{@"deviceid":@{@"$in":@[[NSString stringWithFormat:@"%@",self.model.mac]]},@"id":@{@"$in":@[[NSString stringWithFormat:@"%li",(long)remindID]]}};
    
    
    NSDictionary *sqlDic=[[NSDictionary alloc]initWithObjectsAndKeys:DRINK_REMIND_TABLE,@"table",queryDic,@"query", nil];
    
    [YTKHelper removeData:[Transform DataToJsonString:sqlDic]];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"toRemindView"]) {
        AddRemindViewController *remindView=[segue destinationViewController];
        
        if (sender==addRemindBtn) {
            remindView.isUpdateRemind=NO;
            remindView.model=self.model;
            remindView.remindDics = [NSMutableArray arrayWithArray:remindArr];//传入所以饮水计划
        }else{
            remindView.isUpdateRemind=YES;
            remindView.model=self.model;
            NSIndexPath *index=sender;
            remindView.remindDic=[remindArr objectAtIndex:index.row-1];
            NSMutableArray *tem = [NSMutableArray arrayWithArray:remindArr];
            [tem removeObjectAtIndex:index.row-1];
            remindView.remindDics = tem;//传入非己的所以饮水计划
        }
    }
    
}

@end
