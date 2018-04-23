//
//  UICityPicker.m
//  DDMates
//
//  Created by ShawnMa on 12/16/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//

#import "TimePickerView.h"
#import "SystemInfo.h"

#define kDuration 0.3

@implementation TimePickerView

@synthesize titleLabel;
@synthesize locatePicker;

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIActionSheetDelegate>*/)delegate
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"TimePickerView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
        self.titleLabel.text = title;
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
    
        NSString* phoneModel = [SystemInfo getDeviceVersion];//获取设备型号
        float version=[[phoneModel substringFromIndex:6]floatValue];
        if (version>7.2) {
            //6s要加这几句pickerview才能正常显示
                    CGRect rect=self.locatePicker.frame;
                    rect.size.width=[ UIScreen mainScreen ].bounds.size.width;
                    self.locatePicker.frame=rect;
        }
        self.backgroudView=[[UIView alloc]initWithFrame:[ UIScreen mainScreen ].bounds];
        [self.backgroudView setBackgroundColor:[UIColor blackColor]];
        [self.backgroudView setAlpha:0.3f];
        
    }
    return self;
}

- (void)showInView:(UIView *) view
{
    if (self.isOrderType&&self.pickerStyle==PickerStyle_Time) {
        self.spLbl.hidden=NO;
    }else{
        self.spLbl.hidden=YES;
    }
    
    if (self.isOrderType == NO &&
        self.isSetTime == YES &&
        self.pickerStyle==PickerStyle_Time)
    {
        // 表示是选择炖煮时间，添加个文本提示

        self.locatePicker.autoresizingMask = UIViewAutoresizingNone;
        self.locatePicker.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;

        self.height = self.height + 30;

        UILabel * lblTip = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.locatePicker.bottom, self.locatePicker.width,20.0f)];
        lblTip.text = @"此时间为锅内水开后的炖煮时间";
        lblTip.textAlignment = NSTextAlignmentCenter;
        lblTip.font = [UIFont systemFontOfSize:14];
        [self addSubview:lblTip];
    }
    
    
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"DDLocateView"];
    
//    BOOL tabbarIsHidden=view.viewController.view.frame.size.height == [UIScreen mainScreen].bounds.size.height;
    //因为菜谱详情都是新建webview，无需空出下面的tabbar高度了
    BOOL tabbarIsHidden=YES;
    
    self.frame = CGRectMake(0,tabbarIsHidden? view.frame.size.height - self.frame.size.height:view.frame.size.height - self.frame.size.height-48,[UIScreen mainScreen ].bounds.size.width, self.frame.size.height);
    
    [view addSubview:self.backgroudView];
    [view addSubview:self];
}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    if (self.pickerStyle==PickerStyle_Place){
        return 3;
    }else if (self.pickerStyle==PickerStyle_Time){
        if (self.isSetTime) {
            if (self.timeDisplayIn24)
                return 2;  //24小时
            else
                return 3;  //12小时
        }else{
            return 1;
        }
        
    }else if(self.pickerStyle == PickerStyle_setRunTime){
        return 2;
    }else if(self.pickerStyle==PickerStyle_Weight){
        return 4;
    }else if(self.pickerStyle==PickerStyle_Humidity){
        return 1;
    }else if(self.pickerStyle==PickerStyle_Temperature){
        return 1;
    }else if(self.pickerStyle==PickerStyle_HumidityRice){
        return 2;
    }else if (self.pickerStyle==PickerStyle_Date){
        return 3;
    }
    else{
        return 1;
    }

}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.pickerStyle==PickerStyle_Time) {
        if (self.isSetTime) {
            
            switch (component) {
                case 0:
                {
                    NSInteger row=0;
                    row = self.isOrderType?24:self.maxHours.integerValue + 1-self.minHours.intValue;
                    return row;
                    break;
                }
                case 1:
                {
                   
                    if (isReloadComponent&&([self.locatePicker selectedRowInComponent:0]==0||[self.locatePicker selectedRowInComponent:0]==self.maxHours.integerValue-self.minHours.integerValue)) {
                        return rowNum;
                    }
                    NSInteger row=0;
                    row = self.isOrderType?12:60;
                    return row;
                    break;
                }
                default:
                    return 1;
                    break;
            }
        }else{
            return 3;
        }
    }else if (self.pickerStyle==PickerStyle_Weight){
        if (component==0) {
            return 200;
        }else if(component==1){
            return 1;
        }else if (component==2){
            return 10;
        }else{
            return 1;
        }
    }else if (self.pickerStyle==PickerStyle_Humidity){
        return 11;
    }else if (self.pickerStyle==PickerStyle_Temperature){
        return 8;
    }else if (self.pickerStyle==PickerStyle_HumidityRice){
        if (component==0) {
            return 1;
        }else{
            return 6;
        }
        
    }else if (self.pickerStyle==PickerStyle_Height){
        return 221;
    }else if (self.pickerStyle==PickerStyle_sportTime){
        return 300;
    }else if(self.pickerStyle==PickerStyle_DietTime){
        return self.valuesArray.count;
    }else if (self.pickerStyle==PickerStyle_Sex){
        return 2;
    }else if(self.pickerStyle==PickerStyle_Step){
        return 99;
    }else if (self.pickerStyle==PickerStyle_CookFood){
        return 12;
    }else if(self.pickerStyle==PickerStyle_Age){
        return 100;
    }else if(self.pickerStyle == PickerStyle_setRunTime){
        
        switch (component) {
            case 0:
            {
                NSInteger row=0;
                row = self.isOrderType?24:self.maxHours.integerValue + 1-self.minHours.intValue;
                return row;
                break;
            }
            case 1:
            {
                if (isReloadComponent&&([self.locatePicker selectedRowInComponent:0]==0||[self.locatePicker selectedRowInComponent:0]==self.maxHours.integerValue-self.minHours.integerValue)) {
                    return rowNum;
                }
                NSInteger row=0;
                row = self.isOrderType?12:60;
                return row;
                break;
            }
            default:
                return 1;
                break;
        }
    }else if (self.pickerStyle==PickerStyle_Mode){
        return 5;
    }else if (self.pickerStyle==PickerStyle_Tem){
        return 71;
    }else{
        return 0;
    }
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = view ? (UILabel *) view : [[UILabel alloc] initWithFrame:CGRectMake(50.0f, 0.0f, 90.0f, 30.0f)];
    
     if (self.pickerStyle==PickerStyle_Time) {
        if (self.isSetTime) {
            if (component == 0) {
                myView.text = [NSString stringWithFormat:@"%ld", (long)row+self.minHours.intValue];
                
            } else if (component == 1) {
                if (self.isOrderType) {
                    myView.text = [NSString stringWithFormat:row == 1 ? @"%ld" : @"%ld", (long)row*5];
                }else{
                    
                    if (self.minMinutes>0&&component==1&&[self.locatePicker selectedRowInComponent:0]==0) {
                          myView.text = [NSString stringWithFormat:@"%ld",(long)(row+self.minMinutes.integerValue)];
                    }
                     else{
                      myView.text = [NSString stringWithFormat:row == 1 ? @"%ld" : @"%ld", (long)row];
                    }

                }
                
            } else if(component==2){
                myView.text =self.isOrderType?@"": @"小时";
            }else{
                myView.text = self.isOrderType?@"": @"分钟";
            }
            
        }else{
            switch (row) {
                case 0:
                    myView.text = @"香韧";
                    break;
                case 1:
                    myView.text = @"标准";
                    break;
                case 2:
                    myView.text = @"香软";
                    break;
                default:
                    break;
            }
        }
     }else if (self.pickerStyle==PickerStyle_Weight){
         if (component==0) {
             myView.text=[NSString stringWithFormat:@"%ld",(long)row+1];
         }else if(component==1){
             myView.text=@".";
         }else if (component==2){
             myView.text=[NSString stringWithFormat:@"%ld",(long)row];
         }else{
             myView.text=@"kg";
         }
     }else if (self.pickerStyle==PickerStyle_Humidity){
        myView.text=[NSString stringWithFormat:@"%ld％",(long)row+50];
     }else if (self.pickerStyle==PickerStyle_Temperature){
        myView.text=[NSString stringWithFormat:@"%ld℃",(long)row+13];
     }else if (self.pickerStyle==PickerStyle_HumidityRice){
         if (component==0) {
             myView.text=@"出米量：";
         }else{
            myView.text=[NSString stringWithFormat:@"%ld杯",(long)row+1];
         }
     }else if (self.pickerStyle==PickerStyle_Sex){
         myView.text = row==0?@"男":@"女";
     }else if (self.pickerStyle==PickerStyle_Step){
         myView.text=[NSString stringWithFormat:@"%ld",(long)(row+1)*1000];
     }else if (self.pickerStyle==PickerStyle_Height){
        myView.text=[NSString stringWithFormat:@"%li",(long)(row+30)];
    
    }else if (self.pickerStyle==PickerStyle_sportTime){
        
        myView.text=[NSString stringWithFormat:@"%li",(long)row+1];
    }else if (self.pickerStyle==PickerStyle_DietTime){
        myView.text=self.valuesArray[row];
    }else if (self.pickerStyle==PickerStyle_Age){
    
        myView.text=[NSString stringWithFormat:@"%li",(long)row];
    }else if (self.pickerStyle == PickerStyle_setRunTime){
        if (self.isSetTime) {
            if (component == 0) {
                
                myView.text = [NSString stringWithFormat:@"%ld", (long)row+self.minHours.intValue];
                
            } else if (component == 1) {
                
                if (self.minMinutes>0&&component==1&&[self.locatePicker selectedRowInComponent:0]==0) {
                    myView.text = [NSString stringWithFormat:@"%ld",(long)(row+self.minMinutes.integerValue)];
                }
                else{
                    myView.text = [NSString stringWithFormat:row == 1 ? @"%ld" : @"%ld", (long)row];
                }

                
            } else if(component==2){
                myView.text =self.isOrderType?@"": @"小时";
            }else{
                myView.text = self.isOrderType?@"": @"分钟";
            }
            
        }
    }else if (self.pickerStyle==PickerStyle_Tem){
    
        myView.text=[NSString stringWithFormat:@"%li℃",100-row];
        
    } //    －－－－－－－－－－－－－－－－－－－－－－－－
    else if (self.pickerStyle==PickerStyle_CookFood){
        
        switch (row) {
            case 0:
                myView.text=@"三杯鸡";
                break;
            case 1:
                myView.text=@"黄焖鸡";
                break;
            case 2:
                myView.text=@"红烧鱼";
                break;
            case 3:
                myView.text=@"红焖排骨";
                break;
            case 4:
                myView.text=@"清炖鸡";
                break;
            case 5:
                myView.text=@"老火汤";
                break;
            case 6:
                myView.text=@"红烧肉";
                break;
            case 7:
                myView.text=@"东坡肘子";
                break;
            case 8:
                myView.text=@"口水鸡";
                break;
            case 9:
                myView.text=@"滑香鸡";
                break;
            case 10:
                myView.text=@"茄子煲";
                break;
            case 11:
                myView.text=@"梅菜扣肉";
                break;
            default:
                break;
        }
        
        
    }
    //    －－－－－－－－－－－－－－－－－－－－－－－
    
else if (self.pickerStyle==PickerStyle_Mode){
        switch (row) {
            case 0:
                myView.text=@"自定义温度";
                break;
            case 1:
                myView.text=@"春";
                break;
            case 2:
                myView.text=@"夏";
                break;
            case 3:
                myView.text=@"秋";
                break;
            case 4:
                myView.text=@"冬";
                break;
                
            default:
                break;
        }
    }
    
     myView.textAlignment = NSTextAlignmentCenter;

    myView.font = [UIFont fontWithName:@"EurostileExtended-Roman-DTC" size:22.0];
    
    myView.backgroundColor = [UIColor clearColor];
    

    
    return myView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if (self.pickerStyle==PickerStyle_Place) {
        if (component == 0) {
            [self.locatePicker reloadComponent:1];
            [self.locatePicker reloadComponent:2];
        }else if (component == 1){
            [self.locatePicker reloadComponent:2];
        }
    }else if (!self.isOrderType && self.isSetTime) {
        if (component==0) {
            //处理最小时间
            if ([self.locatePicker selectedRowInComponent:0]+self.minHours.integerValue ==self.minHours.integerValue) {
                
                isReloadComponent=YES;
                rowNum=60-self.minMinutes.intValue;
                [self.locatePicker reloadComponent:1];
            
            }
            //处理最大时间
            else if ([self.locatePicker selectedRowInComponent:0]+self.minHours.integerValue == self.maxHours.integerValue) {
                if (self.maxHours.integerValue == 23) {
                    isReloadComponent=NO;
                    [self.locatePicker reloadComponent:1];

                } else {
                    isReloadComponent=YES;
                    rowNum=1;
                    [self.locatePicker reloadComponent:1];

                }
            }else if([self.locatePicker numberOfRowsInComponent:1]!=60){
                isReloadComponent=NO;
                [self.locatePicker reloadComponent:1];
            }

        }
 
    }
    
    UILabel *label;
    label=(UILabel *)[pickerView viewForRow:row forComponent:component];
    [label setTextColor:UIColorFromRGB(0xff8314)];
    
    if (self.pickerStyle==PickerStyle_Time||self.pickerStyle==PickerStyle_setRunTime) {
        if (self.isSetTime) {
            if (component==0) {
                label.text=self.isOrderType?[NSString stringWithFormat:@"%li",label.text.integerValue]:[NSString stringWithFormat:@"%li小时",label.text.integerValue];
            }else{
                label.text=self.isOrderType?[NSString stringWithFormat:@"%li",label.text.integerValue]:[NSString stringWithFormat:@"%li分钟",label.text.integerValue];
            }
        }
        
    }else if (self.pickerStyle==PickerStyle_Weight){
        if (component==0) {
            label.text=[NSString stringWithFormat:@"%ld",(long)[label.text integerValue]];
        }else if(component==1){
            label.text=@".";
        }else if (component==2){
            label.text=[NSString stringWithFormat:@"%ld",(long)[label.text integerValue]];
        }else{
            label.text=@"kg";
        }
    }else if (self.pickerStyle==PickerStyle_Humidity){
       label.text=[NSString stringWithFormat:@"%ld％",(long)[label.text integerValue]];
    }else if (self.pickerStyle==PickerStyle_Temperature){
        label.text=[NSString stringWithFormat:@"%ld℃",(long)[label.text integerValue]];
    }else if (self.pickerStyle==PickerStyle_HumidityRice){
        label.text=[NSString stringWithFormat:@"%ld杯",(long)[label.text integerValue]];
    }else if (self.pickerStyle==PickerStyle_sportTime){
        label.text=[NSString stringWithFormat:@"%li分钟",(long)label.text.integerValue];
    }else if (self.pickerStyle==PickerStyle_DietTime){
        label.frame=CGRectMake(20, 0, kScreenWidth-40, 30);
        label.textAlignment=NSTextAlignmentCenter;
    }else if (self.pickerStyle==PickerStyle_Height){
        label.text=[NSString stringWithFormat:@"%licm",label.text.integerValue];
    }

}

- (void)changeLabelStateWithRow:(NSInteger)row component:(NSInteger)component pockerView:(UIPickerView *)pickerView{
    UILabel *label;
    label=(UILabel *)[pickerView viewForRow:row forComponent:component];
    [label setTextColor:UIColorFromRGB(0xff8314)];
    
    if (component==0) {
        label.text=[NSString stringWithFormat:@"%li小时",label.text.integerValue];
    }else{
        label.text=[NSString stringWithFormat:@"%li分钟",label.text.integerValue];
    }
    
}



#pragma mark - Button lifecycle

- (IBAction)cancel:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:kDuration];
//    if(self.delegate) {
//        [self.delegate actionSheet:self clickedButtonAtIndex:0];
//    }
}

- (IBAction)locate:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:kDuration];
    if(self.delegate) {
        if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
            [self.delegate actionSheet:self clickedButtonAtIndex:1];
    }
    
}
#pragma mark -- Setters and Getters
-(void)setValuesArray:(NSArray *)valuesArray{
    _valuesArray=valuesArray;
}
-(void)viewRemoveFromSuperview{
    [self.backgroudView removeFromSuperview];
    [self removeFromSuperview];
}


@end
