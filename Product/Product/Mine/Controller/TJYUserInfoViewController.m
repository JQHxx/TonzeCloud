//
//  TJYUserInfoViewController.m
//  Product
//
//  Created by vision on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYUserInfoViewController.h"
#import "TJYLaborViewController.h"
#import "TimePickerView.h"
#import "DataPickerView.h"
#import "TJYUserModel.h"
#import "GetCodeViewController.h"


@interface TJYUserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DatePickerViewDelegate,TJYLaborViewControllerDelegate>{
    NSArray                 *titlesArray;
    UIImagePickerController *ImgPicker;
    TimePickerView          *Picker;
    UIAlertAction           *OkBtnEnabledAction;
    
    UIImageView             *headImage;
    
    TJYUserModel            *userModel;
}

@property (nonatomic,strong)UITableView *userInfoTableView;


@end

@implementation TJYUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle=@"个人信息";
    
    titlesArray=@[@[@"头像",@"昵称",@"手机号",@"修改密码"],@[@"性别",@"出生日期",@"身高",@"体重",@"劳动强度"]];
    
    [self.view addSubview:self.userInfoTableView];
    
    
    userModel=[TonzeHelpTool sharedTonzeHelpTool].user;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-02-01" type:1];
#endif
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#if !DEBUG
    [[NetworkTool sharedNetworkTool] pageCountEventWithTargetID:@"003-02-01" type:2];
#endif
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return titlesArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [titlesArray[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text=titlesArray[indexPath.section][indexPath.row];
    
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            headImage=[[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-100, 5, 60, 60)];
            headImage.layer.cornerRadius=30;
            headImage.clipsToBounds=YES;
            NSString *imgUrl=userModel.photo;
            [headImage sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"ic_m_head"]];
            [cell.contentView addSubview:headImage];
        }else if (indexPath.row==1){
            cell.detailTextLabel.text=kIsEmptyString(userModel.nick_name)?@"":userModel.nick_name;
        }else if (indexPath.row==2){
            cell.detailTextLabel.text=userModel.mobile;
            cell.accessoryType=UITableViewCellAccessoryNone;
        }else if (indexPath.row==3){
        
        }
    }else{
        if (indexPath.row==0) {
            if (userModel.sex>0&&userModel.sex<3) {
                cell.detailTextLabel.text=userModel.sex==1?@"男":@"女";
            }else{
                cell.detailTextLabel.text=@"请选择性别";
            }
        }else if (indexPath.row==1){
            cell.detailTextLabel.text=kIsEmptyString(userModel.birthday)?@"请选择出生日期":userModel.birthday;
        }else if (indexPath.row==2){
            NSInteger height=[userModel.height integerValue];
            cell.detailTextLabel.text=height>0?[NSString stringWithFormat:@"%ldcm",(long)height]:@"请选择身高";
        }else if (indexPath.row==3){
            double weight=[userModel.weight doubleValue];
            cell.detailTextLabel.text=weight>0.1?[NSString stringWithFormat:@"%.1fkg",weight]:@"请选择体重";
        }else if (indexPath.row==4){
            cell.detailTextLabel.text=kIsEmptyString(userModel.labour_intensity)?@"请选择劳动强度":userModel.labour_intensity;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            [self uploadUserImg];
        }else if (indexPath.row==1){
            [self changeUserName];
        }else if (indexPath.row == 3){
            GetCodeViewController *getCodeVC=[[GetCodeViewController alloc] init];
            getCodeVC.isChangePassword=YES;
            [self.navigationController pushViewController:getCodeVC animated:YES];
        }
    }else{
        if (indexPath.row==0) {
            Picker =[[TimePickerView alloc] initWithTitle:@"性别" delegate:self];
            Picker.pickerStyle=PickerStyle_Sex;
            [Picker.locatePicker selectRow:0 inComponent:0 animated:YES];
            [Picker showInView:self.view];
            [Picker pickerView:Picker.locatePicker didSelectRow:0 inComponent:0];
        }else if (indexPath.row==1){
            NSString *currentDateStr=kIsEmptyString(userModel.birthday)?@"1990-01-01":userModel.birthday;
            DataPickerView *datePickerView=[[DataPickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240) value:currentDateStr dateType:DateTypeDate pickerType:DatePickerViewTypeBirthday title:@"出生日期"];
            datePickerView.pickerDelegate=self;
            [datePickerView datePickerViewShowInView:self.view];
        }else if (indexPath.row==2){
            NSInteger height=[userModel.height integerValue];
            height = height < 30 ? 160:height;
            Picker =[[TimePickerView alloc] initWithTitle:@"身高" delegate:self];
            Picker.pickerStyle=PickerStyle_Height;
            [Picker.locatePicker selectRow:height-30 inComponent:0 animated:YES];
            [Picker showInView:self.view];
            [Picker pickerView:Picker.locatePicker didSelectRow:height-30 inComponent:0];
        }else if (indexPath.row==3){
            double weight=[userModel.weight doubleValue];
            NSInteger rowValue=0;
            NSInteger rowValue2=0;
            if (weight<10.0) {
                rowValue=60;
                rowValue2=0;
            }else{
                rowValue=(NSInteger)weight;
                rowValue2=(weight+0.01-rowValue)*10;
            }
            Picker =[[TimePickerView alloc] initWithTitle:@"体重" delegate:self];
            Picker.pickerStyle=PickerStyle_Weight;
            [Picker.locatePicker selectRow:rowValue-1 inComponent:0 animated:YES];
            [Picker.locatePicker selectRow:rowValue2 inComponent:2 animated:YES];
            [Picker showInView:self.view];
            [Picker pickerView:Picker.locatePicker didSelectRow:rowValue-1 inComponent:0];
            [Picker pickerView:Picker.locatePicker didSelectRow:rowValue2 inComponent:2];
            
        }else{
            TJYLaborViewController *laborVC=[[TJYLaborViewController alloc] init];
            laborVC.controllerDelegate=self;
            laborVC.laborIntensity=userModel.labour_intensity;
            [self.navigationController pushViewController:laborVC animated:YES];
        }
    }
   
    if (indexPath.section==0&&indexPath.row==2) {
        
    }else{
#if !DEBUG
        NSArray *array=@[@[@"003-02-02",@"003-02-03",@"",@"003-02-04"],@[@"003-02-05",@"003-02-06",@"003-02-07",@"003-02-08",@"003-02-09"]];
        NSString *targetID=array[indexPath.section][indexPath.row];
        [[NetworkTool sharedNetworkTool] clickOnEventWithTargetId:targetID];
#endif
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headSectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    headSectionView.backgroundColor = [UIColor bgColor_Gray];
    return headSectionView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0&&indexPath.row==0) {
        return 70;
    }else{
        return 44;
    }
}

#pragma mark -- Custom Delegate
#pragma mark DatePickerViewDelegate
-(void)datePickerView:(DatePickerView *)pickerView didSelectDate:(NSString *)dateStr{
    userModel.birthday=dateStr;
    [self saveUserBaseInfoWithBody:[NSString stringWithFormat:@"birthday=%@&doSubmit=1",userModel.birthday]];
}

#pragma mark TimePickerViewDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSString *body=nil;
         if (Picker.pickerStyle==PickerStyle_Height){
            NSInteger heigh=[Picker.locatePicker selectedRowInComponent:0]+30;
            userModel.height=[NSString stringWithFormat:@"%li",(long)heigh];
             body=[NSString stringWithFormat:@"height=%@&doSubmit=1",userModel.height];
        }else if (Picker.pickerStyle==PickerStyle_Sex){
            userModel.sex=[Picker.locatePicker selectedRowInComponent:0]+1;
            body=[NSString stringWithFormat:@"sex=%ld&doSubmit=1",(long)userModel.sex];
        }else if (Picker.pickerStyle==PickerStyle_Weight){
            NSInteger row1=[Picker.locatePicker selectedRowInComponent:0]+1;
            NSInteger row2=[Picker.locatePicker selectedRowInComponent:2];
            double  weight=row1+row2/10.0;
            userModel.weight=[NSString stringWithFormat:@"%.1f",weight];
            body=[NSString stringWithFormat:@"weight=%@&doSubmit=1",userModel.weight];
        }
        [self saveHomeUserBaseInfoWithBody:body];
    }
}

#pragma mark  TJYLaborViewControllerDelegate
-(void)laborVCDidSelectLabor:(NSString *)selLabor{
    userModel.labour_intensity=selLabor;
    [self saveUserBaseInfoWithBody:[NSString stringWithFormat:@"labour_intensity=%@&doSubmit=1",userModel.labour_intensity]];
}

#pragma mark--Delegate
#pragma mark UIImagePickerController
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [ImgPicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [ImgPicker dismissViewControllerAnimated:YES completion:nil];
    UIImage* curImage=[info objectForKey:UIImagePickerControllerEditedImage];
    curImage=[self thumbnailWithImageWithoutScale:curImage size:CGSizeMake(160, 160)];
    NSData *imageData = UIImagePNGRepresentation(curImage);
    //将图片数据转化为64为加密字符串
    NSString *encodeResult = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *body=[NSString stringWithFormat:@"photo=%@",encodeResult];
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kUserUploadPhoto body:body success:^(id json) {
        NSDictionary *result=[json objectForKey:@"result"];
        if (kIsDictionary(result)&&result.count) {
            [self.view makeToast:@"图片上传成功" duration:1.0 position:CSToastPositionCenter];
            NSString *imgUrl=[result valueForKey:@"image_url"];
            userModel.photo=imgUrl;
            [TJYHelper sharedTJYHelper].isReloadUserInfo=YES;
            [self.userInfoTableView reloadData];
            
            NSString *token = [[NSUserDefaultInfos getDicValueforKey:USER_DIC] objectForKey:@"access_token"];
            if (!kIsEmptyString(token)) {
                NSData *imageContent = UIImagePNGRepresentation(curImage);
                [HttpRequest saveUserAvatarWithAccessToken:token avatarContent:imageContent didLoadData:^(id result, NSError *err) {
                    
                }];
            }
            
            
        }
    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark --Private Methods
#pragma mark 上传头像
-(void)uploadUserImg{
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *cameraButtonTitle = NSLocalizedString(@"拍照", nil);
    NSString *photoButtonTitle = NSLocalizedString(@"手机相册", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:cameraButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ImgPicker=[[UIImagePickerController alloc]init];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) //判断设备相机是否可用
        {
            ImgPicker=[[UIImagePickerController alloc]init];
            ImgPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            ImgPicker.delegate=self;
            ImgPicker.allowsEditing=YES;
            if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
                self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            }
            [self presentViewController:ImgPicker animated:YES completion:nil];
        }
        else{
            UIAlertView *alert2=[[UIAlertView alloc]initWithTitle:@"提示" message:@"你的相机不可用!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alert2 show];
        }
        
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:photoButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ImgPicker=[[UIImagePickerController alloc]init];
        ImgPicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        ImgPicker.delegate=self;
        ImgPicker.allowsEditing=YES;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:ImgPicker animated:YES completion:nil];
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:cameraAction];
    [alertController addAction:photoAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 修改昵称
-(void)changeUserName{
    NSString *title = NSLocalizedString(@"修改昵称", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"请输入新的昵称"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        textField.delegate=self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController.textFields.firstObject resignFirstResponder];
        alertController.textFields.firstObject.text = [alertController.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (alertController.textFields.firstObject.text.length>16||alertController.textFields.firstObject.text.length<1) {
            [self showAlertWithTitle:@"提示" Message:@"昵称仅支持1-16个字符"];
        }else{
            userModel.nick_name=alertController.textFields.firstObject.text;
            [[NetworkTool sharedNetworkTool] postMethodWithURL:kChangeNickName body:[NSString stringWithFormat:@"nickname=%@",userModel.nick_name] success:^(id json) {
                NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
                NSString *access_token=[userDic objectForKey:@"access_token"];
                NSNumber *user_id=[userDic objectForKey:@"user_id"];
                
                [NSUserDefaultInfos putKey:USER_NAME andValue:userModel.nick_name];
                
                [HttpRequest modifyAccountNickname:userModel.nick_name withUserID:user_id withAccessToken:access_token didLoadData:^(id result, NSError *err) {
                
                }];
                [TJYHelper sharedTJYHelper].isReloadUserInfo=YES;
                [self.userInfoTableView reloadData];
            } failure:^(NSString *errorStr) {
                [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            }];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
        }
    }];
    otherAction.enabled = NO;
    OkBtnEnabledAction = otherAction;//定义一个全局变量来存储
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

#pragma mark 保存个人信息
-(void)saveUserBaseInfoWithBody:(NSString *)body{
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kSetUserInfo body:body success:^(id json) {
        [TJYHelper sharedTJYHelper].isReloadUserInfo=YES;
        [self.userInfoTableView reloadData];

        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            TJYUserModel *userModeldetail=[[TJYUserModel alloc] init];
            [userModeldetail setValues:result];
            [TonzeHelpTool sharedTonzeHelpTool].user=userModeldetail;
        }

    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark 保存个人信息
-(void)saveHomeUserBaseInfoWithBody:(NSString *)body{
    [[NetworkTool sharedNetworkTool] postMethodWithURL:kSetUserInfo body:body success:^(id json) {
        [TJYHelper sharedTJYHelper].isRecordReload=YES;
        [TJYHelper sharedTJYHelper].isReloadHome=YES;
        [self.userInfoTableView reloadData];
        
        NSDictionary *result = [json objectForKey:@"result"];
        if (kIsDictionary(result)) {
            TJYUserModel *userModeldetail=[[TJYUserModel alloc] init];
            [userModeldetail setValues:result];
            [TonzeHelpTool sharedTonzeHelpTool].user=userModeldetail;
        }

    } failure:^(NSString *errorStr) {
        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark -- Setters
#pragma mark 个人信息列表
-(UITableView *)userInfoTableView{
    if (!_userInfoTableView) {
        _userInfoTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kBodyHeight) style:UITableViewStyleGrouped];
        _userInfoTableView.backgroundColor=[UIColor bgColor_Gray];
        _userInfoTableView.dataSource=self;
        _userInfoTableView.delegate=self;
    }
    return _userInfoTableView;
}
#pragma mark 生成缩略图
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

@end
