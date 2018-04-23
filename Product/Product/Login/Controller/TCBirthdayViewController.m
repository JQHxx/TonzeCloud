//
//  TCBirthdayViewController.m
//  TonzeCloud
//
//  Created by vision on 17/3/31.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import "TCBirthdayViewController.h"
#import "TCHeightViewController.h"
#import "TCUserTool.h"
#import "BirthdayPickView.h"

@interface TCBirthdayViewController ()<birthdayPickerViewDelegate>{
   
    UILabel *ageLabel;
    NSString *birthdayStr;
}
@end

@implementation TCBirthdayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"年龄";
    
    NSString *yearStr =[[TJYHelper sharedTJYHelper] getLastYearDate:27];
    NSString *time =[yearStr substringToIndex:4];
    birthdayStr=[NSString stringWithFormat:@"%@-01-01",time];
    
    
    [self initAgeView];
}
#pragma mark --TCDatePickerViewDelegate
-(void)birthdayPickerView:(BirthdayPickView *)pickerView didSelectDate:(NSString *)dateStr{
    birthdayStr = dateStr;
    NSCalendar *calendar = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *birthDay = [dateFormatter dateFromString:dateStr];
    //用来得到详细的时差
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *date = [calendar components:unitFlags fromDate:birthDay toDate:nowDate options:0];
    
    if([date year] >0){
        ageLabel.text=[NSString stringWithFormat:@"%ld岁",(long)[date year]];
    }
}
#pragma mark -- Event Response
#pragma mark -- 下一步
- (void)nextButton{
    MyLog(@"birthday:%@",birthdayStr);
    
    [[TCUserTool sharedTCUserTool] insertValue:birthdayStr forKey:@"birthday"];
    TCHeightViewController *heightVC = [[TCHeightViewController alloc] init];
    [self.navigationController pushViewController:heightVC animated:YES];
}

#pragma mark --Private methods
#pragma mark -- 初始化界面
- (void)initAgeView{
    UIImageView *birthdayImg = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2,kNavigationHeight+50, 80, 80)];
    birthdayImg.image = [UIImage imageNamed:@"ic_login_birthday"];
    [self.view addSubview:birthdayImg];
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, birthdayImg.bottom+20, kScreenWidth, 30)];
    promptLabel.text = @"您的年龄？";
    promptLabel.font = [UIFont systemFontOfSize:20];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:promptLabel];
    
    ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, promptLabel.bottom+10, kScreenWidth, 20)];
    ageLabel.text = @"27";
    ageLabel.textAlignment = NSTextAlignmentCenter;
    ageLabel.font = [UIFont boldSystemFontOfSize:20];
    ageLabel.textColor = [UIColor blackColor];
    [self.view addSubview:ageLabel];
    
    BirthdayPickView *datePickerView = [[BirthdayPickView alloc] initWithFrame:CGRectMake(0, ageLabel.bottom, kScreenWidth, 200) birthdayValue:birthdayStr dateType:birthdayTypeDate pickerType:birthdayPickerViewTypeBirthday];
    datePickerView.birthdayPickerViewDelegate=self;
    [self.view addSubview:datePickerView];
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, kScreenHeight-60, 150, 40)];
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor colorWithHexString:@"0xff9d38"] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){255.0/256, 157.0/256, 56.0/256,1 });
    [nextButton.layer setBorderColor:colorref];//边框颜色
    [nextButton addTarget:self action:@selector(nextButton) forControlEvents:UIControlEventTouchUpInside];
    nextButton.layer.cornerRadius = 5;
    nextButton.layer.borderWidth = 1;
    
    [self.view addSubview:nextButton];

}
@end
