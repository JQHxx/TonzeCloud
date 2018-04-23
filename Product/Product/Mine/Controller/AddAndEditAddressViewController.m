//
//  AddAndEditAddressViewController.m
//  Product
//
//  Created by zhuqinlu on 2017/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddAndEditAddressViewController.h"
#import "AddressInfoCell.h"
#import "CityPickerView.h"
#import "QLAlertView.h"

@interface AddAndEditAddressViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSArray *_titleArray;    // 标题数据
    UITextField *_nameTF;
    UITextField *_phoneTF;
    UITextField *_addressTF;
    NSInteger  _isDefault;
    UISwitch *_defaultSwitch;
}
@property (nonatomic,strong) UITableView *addressInfoTab;
/// 标题数据
@property (nonatomic ,strong) NSArray *titleArray;;
/// 提示文字
@property (nonatomic ,strong) NSArray *placeholderArray;
///
@property (nonatomic ,strong) CityPickerView *cityPickerView;

@property (nonatomic ,strong) UITextField *areaTF;
/// 省市区信息
@property (nonatomic, copy) NSString *areaString ;
/// 地区数据
@property (nonatomic ,strong) NSArray *areaArray;

@end

@implementation AddAndEditAddressViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_addressType == EditAddress) {
        _nameTF.text = _addressModel.ship_name;
        _phoneTF.text = _addressModel.ship_mobile;
        _areaString = _addressModel.ship_area;
        NSString  *areaStr = [_addressModel.ship_area stringByReplacingOccurrencesOfString:@"/" withString:@""];
        NSString  *areaFromStr = [areaStr substringFromIndex:9];
        NSRange range = [areaFromStr rangeOfString:@":"];
        _areaTF.text  = [areaFromStr substringToIndex:range.location];
        _addressTF.text = _addressModel.ship_addr;
        _defaultSwitch.on = [_addressModel.is_default isEqualToString:@"true"] ?  YES : NO;
        _isDefault = [_addressModel.is_default isEqualToString:@"true"] ?  1 : 0;
    }else{
        _defaultSwitch.on = _isDefaultAdd ? YES : NO;
        _isDefault = _isDefaultAdd ? 1 : 0;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_addressType == AddAddress) {
            self.baseTitle = @"添加新地址";
    }else{
        self.baseTitle = @"编辑地址";
        self.rigthTitleName = @"删除";
    }
    _isDefault = 0;
    [self initAddAndEditAddress];
    [self requestAddAndEditAddressData];
}
#pragma mark ====== Bulid UI =======
- (void)initAddAndEditAddress{
    [self.view addSubview:self.addressInfoTab];
}
- (UIView *)tableFooterView{
    UIView *tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 90)];
    tableFooterView.backgroundColor = [UIColor bgColor_Gray];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(15, 50, kScreenWidth - 30, 40);
    saveBtn.backgroundColor = kSystemColor;
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    saveBtn.layer.cornerRadius = 5;
    [saveBtn setTitleColor:UIColorHex(0xffffff) forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveAddress) forControlEvents:UIControlEventTouchUpInside];
    [tableFooterView addSubview:saveBtn];
    
    return tableFooterView;
}
#pragma mark ====== Request Data =======
-(void)requestAddAndEditAddressData{
    NSString *memberId = [NSUserDefaultInfos getValueforKey:USER_ID];
    NSString *body = [NSString stringWithFormat:@"member_id=%@",memberId];
    kSelfWeak;
    [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KGetAllRegions body:body success:^(id json) {
        NSArray *data = [json objectForKey:@"result"];
        weakSelf.areaArray = data;
    } failure:^(NSString *errorStr) {
        [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
    }];
}
#pragma mark ====== Evetn  Response =======

- (void)leftButtonAction{
    [self.view endEditing:YES];
    
    NSString *defautlStr = _isDefault ?  @"true" : @"false";
    // 返回判断提醒
    if (_addressType == EditAddress) {
        if (![_nameTF.text isEqualToString:_addressModel.ship_name] || ![_phoneTF.text isEqualToString:_addressModel.ship_mobile]  || ![_addressTF.text isEqualToString:_addressModel.ship_addr]  || ![_areaString isEqualToString:_addressModel.ship_area] || ![_addressModel.is_default isEqualToString:defautlStr]) {
                [self showAlertView];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        if (!kIsEmptyString(_nameTF.text) ||!kIsEmptyString(_phoneTF.text) || !kIsEmptyString(_addressTF.text) || !kIsEmptyString(_areaString)) {
                [self showAlertView];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)showAlertView{
    
    QLAlertView *alertView = [[QLAlertView alloc]initWithTitle:@"" message:@"确定要放弃保存并返回吗？" sureBtn:@"取消" cancleBtn:@"确定"];
    alertView.resultIndex = ^(NSInteger index){
        [self.navigationController popViewControllerAnimated:YES];
    };
    [alertView showQLAlertView];
}
#pragma mark ======   删除地址 =======

- (void)rightButtonAction{

    QLAlertView *alertView = [[QLAlertView alloc]initWithTitle:@"" message:@"确定要删除该收货人信息吗？" sureBtn:@"取消" cancleBtn:@"确定"];
    kSelfWeak;
    alertView.resultIndex = ^(NSInteger index){
        // 删除收货信息
        NSString *memberIdStr = [NSUserDefaultInfos getValueforKey:USER_ID];
        NSString *body = [NSString stringWithFormat:@"member_id=%@&addr_id=%@",memberIdStr,_addressModel.ship_id];
        [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KDeleateAddress body:body success:^(id json) {
            [weakSelf.view makeToast:@"收货人已删除" duration:1.0 position:CSToastPositionCenter];
            [TJYHelper sharedTJYHelper].isAddressManagerReload = YES;
            [TJYHelper sharedTJYHelper].isAddressSelectedReload = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    };
    [alertView showQLAlertView];
}
- (void)switchAction:(UISwitch *)sender{
    // 默认地址开关
    if (sender.isOn) {
        _isDefault = 1;
    }else{
        _isDefault = 0;
    }
}
- (void)saveAddress{
    
    BOOL hasEmoji = [[TJYHelper sharedTJYHelper] strIsContainEmojiWithStr:_addressTF.text];
    // 保存地址
    if (kIsEmptyString(_nameTF.text)) {
        [self.view makeToast:@"请输入姓名" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if (kIsEmptyString(_phoneTF.text)){
        [self.view makeToast:@"请输入手机号码" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if (_phoneTF.text.length != 11){
        [self.view makeToast:@"请输入正确的手机号码" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if (![[_phoneTF.text substringToIndex:1] isEqualToString:@"1"]){
        [self.view makeToast:@"请输入正确的手机号码" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if (kIsEmptyString(_areaString)){
        [self.view makeToast:@"请选择所在地区" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if (kIsEmptyString(_addressTF.text)){
        [self.view makeToast:@"请填写详细地址" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if (hasEmoji){
        [self.view makeToast:@"详细地址中不能包含特殊符号" duration:0.5 position:CSToastPositionCenter];
        return;
    }else if ([[TJYHelper sharedTJYHelper] strIsContainEmojiWithStr:_nameTF.text]){
        [self.view makeToast:@"姓名中不能包含特殊符号" duration:0.5 position:CSToastPositionCenter];
        return;
    }else{// 保存收货信息
        
        NSString *memberId = [NSUserDefaultInfos getValueforKey:USER_ID];
        NSString *body;
        if (_addressType == AddAddress) {
            body= [NSString stringWithFormat:@"member_id=%@&ship_name=%@&ship_mobile=%@&ship_area=%@&ship_addr=%@&is_default=%ld",memberId,_nameTF.text,_phoneTF.text,_areaString,_addressTF.text,_isDefault];
        }else{
            body= [NSString stringWithFormat:@"ship_id=%@&member_id=%@&ship_name=%@&ship_mobile=%@&ship_area=%@&ship_addr=%@&is_default=%ld",_addressModel.ship_id,memberId,_nameTF.text,_phoneTF.text,_areaString,_addressTF.text,_isDefault];
        }
        
        kSelfWeak;
        [[NetworkTool sharedNetworkTool]postShopMethodWithURL:KSaveAddress body:body success:^(id json) {
            
            UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
            alertView.backgroundColor =  [[UIColor blackColor] colorWithAlphaComponent:0.8];
            alertView.layer.cornerRadius = 10;
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((150-30)/2, 15, 30, 30)];
            imgView.image = [UIImage imageNamed:@"pd_ic_add_finish"];
            [alertView addSubview:imgView];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom+10, 150, 20)];
            titleLabel.text = @"保存成功";
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            [alertView addSubview:titleLabel];
            
            [weakSelf.view showToast:alertView duration:1.0 position:CSToastPositionCenter];
            
            [TJYHelper sharedTJYHelper].isAddressManagerReload = YES;
            [TJYHelper sharedTJYHelper].isAddressSelectedReload = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        } failure:^(NSString *errorStr) {
            [weakSelf.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        }];
    }
}
- (void)tableViewTouchInSide{
    // 取消键盘
    [self.view endEditing:YES];
}
#pragma mark ====== UITextFieldDelegate =======

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    AddressInfoCell *cell = (AddressInfoCell *)[[textField superview] superview];
    NSIndexPath *indexPath = [_addressInfoTab indexPathForCell:cell];
    if (indexPath.row == 2) {
        [self.view endEditing:YES];
        
        if (kIsArray(_areaArray) && _areaArray.count > 0) {
            self.cityPickerView = [[CityPickerView alloc]init];
            self.cityPickerView.areaArray = self.areaArray;
            [self.view addSubview:self.cityPickerView];
            kSelfWeak;
            _cityPickerView.config = ^(NSString *province, NSString *city, NSString *town){
                NSString *provinceStr;
                NSString *cityStr;
                NSString *townStr;
                NSString *provinceString = province;
                NSRange provinceRang = [provinceString rangeOfString:@":"];
                provinceStr = [provinceString substringToIndex:provinceRang.location];
                
                if (!kIsEmptyString(town)) {
                    NSString *cityString = city;
                    NSRange cityRang = [cityString rangeOfString:@":"];
                    cityStr = [cityString substringToIndex:cityRang.location];
                    townStr = town;
                    NSString *addressTextStr = [NSString stringWithFormat:@"%@%@%@",provinceStr,cityStr,townStr];
                    weakSelf.areaTF.text =[addressTextStr substringToIndex:[addressTextStr rangeOfString:@":"].location];
                    weakSelf.areaString = [NSString stringWithFormat:@"mainland:%@/%@/%@",provinceStr,cityStr,townStr];
                }else{
                    cityStr = city;
                    NSString *addressTextStr = [NSString stringWithFormat:@"%@%@%@",provinceStr,cityStr,townStr];
                    weakSelf.areaTF.text =[addressTextStr substringToIndex:[addressTextStr rangeOfString:@":"].location];
                    weakSelf.areaString = [NSString stringWithFormat:@"mainland:%@/%@/%@",provinceStr,cityStr,townStr];
                }
            };
        }else{
            _areaArray  = [NSArray array];
            [self requestAddAndEditAddressData];
        }
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if (textField == _nameTF) {
        if (string.length == 0) return YES;
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 10){
            return NO;
        }
    }else if (textField == _phoneTF){
        if (string.length == 0) return YES;
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 11){
            return NO;
        }
    }
    // 禁止输入空格
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
    if (![string isEqualToString:tem]) {
        return NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}
#pragma mark ====== UITableViewDataSource =======
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
#pragma mark ====== UITableViewDelegate =======
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 58.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *sectionFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 58)];
    sectionFooterView.backgroundColor = [UIColor whiteColor];
    
    UILabel *lens = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    lens.backgroundColor = [UIColor bgColor_Gray];
    [sectionFooterView addSubview:lens];
    
    UILabel *defaultTipLab = [[UILabel alloc]initWithFrame:CGRectMake(15, lens.height +  (sectionFooterView.height - 10 - 20)/2, 150, 20)];
    defaultTipLab.text = @"设为默认地址";
    defaultTipLab.font = kFontSize(15);
    defaultTipLab.textColor = UIColorHex(0x313131);
    [sectionFooterView addSubview:defaultTipLab];
    
    _defaultSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(kScreenWidth - 75, (sectionFooterView.height - 10 - 25), 60, 25)];
    [_defaultSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [sectionFooterView addSubview:_defaultSwitch];
    
    return sectionFooterView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *addressInfoCellIdentifier = @"addressInfoCellIdentifier";
    AddressInfoCell *addressCell = [tableView dequeueReusableCellWithIdentifier:addressInfoCellIdentifier];
    if (!addressCell) {
        addressCell = [[AddressInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addressInfoCellIdentifier];
    }
    addressCell.titleLab.text = self.titleArray[indexPath.row];
    addressCell.contentTF.placeholder =self.placeholderArray[indexPath.row];
    addressCell.contentTF.delegate = self;
    addressCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case 0:
        {
            addressCell.arrowImg.hidden = YES;
            _nameTF = addressCell.contentTF;
        }break;
        case 1:
        {
            addressCell.arrowImg.hidden = YES;
            addressCell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
            _phoneTF = addressCell.contentTF;
        }break;
        case 2:
        {
            addressCell.arrowImg.hidden = NO;// 箭头
            _areaTF = addressCell.contentTF;
        }break;
        case 3:
        {
            addressCell.arrowImg.hidden = YES;
            _addressTF = addressCell.contentTF;
        }break;
        default:
            break;
    }
    return addressCell;
}

#pragma mark ====== Setter =======

- (UITableView *)addressInfoTab{
    if (!_addressInfoTab) {
        _addressInfoTab = [[UITableView alloc]initWithFrame:CGRectMake(0, kNewNavHeight, kScreenWidth, kBodyHeight) style:UITableViewStylePlain];
        _addressInfoTab.dataSource = self;
        _addressInfoTab.delegate = self;
        _addressInfoTab.backgroundColor = [UIColor bgColor_Gray];
        _addressInfoTab.tableFooterView = [self tableFooterView];
        _addressInfoTab.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _addressInfoTab.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;// 降落键盘
        
        UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTouchInSide)];
        tableViewGesture.numberOfTapsRequired = 1;
        tableViewGesture.cancelsTouchesInView = NO;//是否取消点击处的其他action
        [_addressInfoTab addGestureRecognizer:tableViewGesture];
    }
    return _addressInfoTab;
}
- (NSArray *)titleArray{
    if (!_titleArray) {
        _titleArray = @[@"姓名",@"手机号码",@"所在地区",@"详细地址"];
    }
    return _titleArray;
}
- (NSArray *)placeholderArray{
    if (!_placeholderArray) {
        _placeholderArray = @[@"输入收货人姓名",@"输入手机号码",@"选择所在省份、城市、区县",@"街道、门牌号等详细地址"];
    }
    return _placeholderArray;
}
- (NSArray *)areaArray{
    if (!_areaArray) {
        _areaArray = [NSArray array];
    }
    return _areaArray;
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
