//
//  DiningDatePickerView.m
//  Product
//
//  Created by Wzy on 1/9/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "DiningDatePickerView.h"

@interface DiningDatePickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIView       * rootView;
    NSString     * strDate;
    NSString     * strType;
    NSArray      * arrayType;
    
    DiningDateBlock dateBlock;
}

@end

@implementation DiningDatePickerView

-(instancetype)initWithFrame:(CGRect)frame value:(NSString *)dateValue title:(NSString *)title dateBlock:(DiningDateBlock)block;
{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        arrayType = [NSArray arrayWithObjects:@"早餐",@"午餐",@"晚餐",@"加餐", nil];
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/4, 10, kScreenWidth/2, 20)];
        timeLabel.text =title;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:timeLabel];
        
        UIButton *cancelbtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelbtn setFrame:CGRectMake(0.0, 0.0, 80.0, 40.0)];
        [cancelbtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        cancelbtn.titleLabel.font=[UIFont systemFontOfSize:16.0f];
        [cancelbtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelbtn addTarget:self action:@selector(cancelSelectPickView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelbtn];
        
        UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [doneBtn setFrame:CGRectMake(kScreenWidth-80, 0.0, 80.0, 40.0)];
        [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        doneBtn.titleLabel.font=[UIFont systemFontOfSize:16.0f];
        [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(didSelectPickView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneBtn];
        
        UILabel *lineLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 1)];
        lineLabel.backgroundColor=kLineColor;
        [self addSubview:lineLabel];
        
        
        UIDatePicker  *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,40,kScreenWidth * 0.7,200)];
        // 设置时区，中国在东八区
        picker.datePickerMode = UIDatePickerModeDate;
        [picker addTarget:self action:@selector(seletedDate:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:picker];
        
        UIPickerView * typePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(picker.right, picker.top, kScreenWidth * 0.3, 200)];
        typePicker.dataSource = self;
        typePicker.delegate = self;
        [self addSubview:typePicker];
        
        
        rootView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        rootView.backgroundColor=[UIColor blackColor];
        rootView.alpha=0.3;
        
        /**
         *  处理数据
         */
        dateBlock = block;
        NSArray * array = [dateValue componentsSeparatedByString:@" "];
        strDate = array[0];
        strType = array[1];
        
        //设置当前时间
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSDate *date=[dateFormatter dateFromString:strDate];
        [picker setDate:date animated:YES];
        
        //设置最大时间和最小时间
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *currentDate=[NSDate date];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        
        NSDate *maxDate;
        NSDate *minDate;
        
        maxDate=currentDate;
        [comps setYear:-10];
        minDate=[calendar dateByAddingComponents:comps toDate:currentDate options:0];
        
        [picker setMaximumDate:maxDate];
        [picker setMinimumDate:minDate];
        
        [typePicker selectRow:[self returnPickerRow:strType] inComponent:0 animated:YES];
        [self pickerView:typePicker didSelectRow:[self returnPickerRow:strType] inComponent:0];
    }
    return self;
}


#pragma mark -
#pragma mark ==== UIPickerView ====
#pragma mark -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arrayType.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 32.0f;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel * lblContent = view ? (UILabel *) view : [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH * 0.3, 30.0f)];

    lblContent.textAlignment = NSTextAlignmentCenter;
    lblContent.font = [UIFont fontWithName:@"EurostileExtended-Roman-DTC" size:30.0];
    lblContent.backgroundColor = [UIColor clearColor];
    lblContent.text = arrayType[row];
    
    return lblContent;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel *label;
    label=(UILabel *)[pickerView viewForRow:row forComponent:component];
//    [label setTextColor:UIColorFromRGB(0xff8314)];
    
    strType = arrayType[row];
}



#pragma mark -
#pragma mark ==== Action ====
#pragma mark -

-(NSInteger)returnPickerRow:(NSString *)type
{
    NSInteger row;
    
    for (int i = 0; i < arrayType.count; i ++) {
        if ([type isEqualToString:arrayType[i]])
        {
            row = i;
            break;
        }
    }
    
    return row;
}

-(void)datePickerViewShowInView:(UIView *)view{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"datePickerView"];
    
    self.frame=CGRectMake(0,kAllHeight-self.height, kScreenWidth, self.height);
    [view addSubview:rootView];
    [view addSubview:self];
}


-(void)cancelSelectPickView:(UIButton *)sender{
    [self dismissAction];
}

-(void)viewRemoveFromSuperview{
    [rootView removeFromSuperview];
    [self removeFromSuperview];
}

-(void)dismissAction{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"datePickerView"];
    
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3];
}

#pragma mark -
#pragma mark ==== onBtnAction ====
#pragma mark -

-(void)didSelectPickView:(UIButton *)sender{
    [self dismissAction];
    if (!kIsEmptyString(strDate) && !kIsEmptyString(strType))
    {
        if (dateBlock)
        {
            NSString * content = [NSString stringWithFormat:@"%@ %@",strDate,strType];
            dateBlock(content);
        }
    }
}

-(void)seletedDate:(UIDatePicker *)datePicker{
    NSDate *currentDate=datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat=@"yyyy-MM-dd";
    strDate = [formatter stringFromDate:currentDate];
}


@end
