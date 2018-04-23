//
//  KettleStartFunctionView.m
//  Product
//
//  Created by Feng on 16/3/19.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "KettleStartFunctionView.h"
#import "TimePickerView.h"

@interface KettleStartFunctionView ()<UIGestureRecognizerDelegate>
{
    UIView *backgroudView;
    UIView *superView;
    TimePickerView *pickerView;
}
@end


@implementation KettleStartFunctionView

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    backgroudView=[[UIView alloc]initWithFrame:[ UIScreen mainScreen ].bounds];
    [backgroudView setBackgroundColor:[UIColor blackColor]];
    [backgroudView setAlpha:0.3f];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [backgroudView addGestureRecognizer:gesture];
    
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    gesture1.numberOfTapsRequired = 1;
    gesture1.delegate = self;
    
    [self.bView addGestureRecognizer:gesture1];
    
    
}


-(void)showInView:(UIView*)view{
    
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.view setAlpha:1.0f];
    [self.view.layer addAnimation:animation forKey:@"DDLocateView"];
    self.view.frame = CGRectMake(0, view.frame.size.height - self.view.frame.size.height,SCREEN_WIDTH, self.view.frame.size.height);
    
    superView=view;
    
    [view addSubview:backgroudView];
    [view addSubview:self.view];
    
}



-(void)dismissView{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.view setAlpha:0.0f];
    [self.view.layer addAnimation:animation forKey:@"TSLocateView"];
    self.view.frame = CGRectMake(0,SCREEN_HEIGHT - self.view.frame.size.height, SCREEN_WIDTH, self.view.frame.size.height);
    
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3f];
    
    
}

-(void)updateUIwithFunctionIndex:(NSInteger)index{
    
    
    if (self.canSetchoiceMenu == YES) {
        
        self.setModeView.hidden=YES;
        self.setFoodView.hidden=NO;
        self.setChlorineView.hidden=YES;
        self.setTemView.hidden=YES;
        self.setFoodView.frame=self.setTemView.frame;
        
    }else{
        if (index==0) {
            self.setModeView.hidden=YES;
            self.setFoodView.hidden=YES;
            self.setChlorineView.hidden=NO;
            self.setTemView.hidden=YES;
            self.setChlorineView.frame=self.setTemView.frame;
            [self.chlorineSwitch setOn:[NSUserDefaultInfos getIntValueforKey:DEFAULT_CHLORINE]];
        }else{
            self.setModeView.hidden=NO;
            self.setFoodView.hidden=YES;
            self.setChlorineView.hidden=YES;
            self.setTemView.hidden=NO;
            self.setModeView.frame=self.setFoodView.frame;
            CGRect rect=self.setChlorineView.frame;
            rect.origin.y=0;
            self.setChlorineView.frame=rect;
            if ([self.modeValueLbl.text isEqualToString:@"自定义温度"]) {
                
                if ([NSUserDefaultInfos getIntValueforKey:DEFAULT_TEM]==0) {
                    [NSUserDefaultInfos putInt:DEFAULT_TEM andValue:80];
                }
                
                self.temValueLbl.text=[NSString stringWithFormat:@"%i℃",[NSUserDefaultInfos getIntValueforKey:DEFAULT_TEM]];
            }
        }
        
    }
}

-(void)viewRemoveFromSuperview{
    [backgroudView removeFromSuperview];
    [self.view removeFromSuperview];
}
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
-(IBAction)selectFood:(id)sender{
    
    pickerView=[[TimePickerView alloc]initWithTitle:@"菜谱选择" delegate:self];
    
    pickerView.pickerStyle=PickerStyle_CookFood;
    
    NSInteger selectRow = 0;
    
    if ([self.modeValueLbl.text isEqualToString:@"三杯鸡"]) {
        selectRow=0;
    }else  if ([self.modeValueLbl.text isEqualToString:@"黄焖鸡"]) {
        selectRow=1;
    }else if ([self.modeValueLbl.text isEqualToString:@"红烧鱼"]) {
        selectRow=2;
    }else if ([self.modeValueLbl.text isEqualToString:@"红焖排骨"]) {
        selectRow=3;
    }else if ([self.modeValueLbl.text isEqualToString:@"清炖鸡"]) {
        selectRow=4;
    }else  if ([self.modeValueLbl.text isEqualToString:@"老火汤"]) {
        selectRow=5;
    }else  if ([self.modeValueLbl.text isEqualToString:@"红烧肉"]) {
        selectRow=6;
    }else  if ([self.modeValueLbl.text isEqualToString:@"东坡肘子"]) {
        selectRow=7;
    }else  if ([self.modeValueLbl.text isEqualToString:@"口水鸡"]) {
        selectRow=8;
    }else  if ([self.modeValueLbl.text isEqualToString:@"滑香鸡"]) {
        selectRow=9;
    }else  if ([self.modeValueLbl.text isEqualToString:@"茄子煲"]) {
        selectRow=10;
    }else  if ([self.modeValueLbl.text isEqualToString:@"梅菜扣肉"]) {
        selectRow=11;
    }
    
    [pickerView.locatePicker selectRow:selectRow inComponent:0 animated:YES];
    
    [pickerView showInView:superView];
    
    [pickerView pickerView:pickerView.locatePicker didSelectRow:selectRow inComponent:0];
    
}
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－

-(IBAction)selectTem:(id)sender{

    pickerView=[[TimePickerView alloc]initWithTitle:@"保温温度" delegate:self];
    
    pickerView.pickerStyle=PickerStyle_Tem;
    
    NSInteger selectRow=100-self.temValueLbl.text.integerValue ;
    
    [pickerView.locatePicker selectRow:selectRow inComponent:0 animated:YES];
    
    [pickerView showInView:superView];
    
    [pickerView pickerView:pickerView.locatePicker didSelectRow:selectRow inComponent:0];
    
}

-(IBAction)selectMode:(id)sender{

    pickerView=[[TimePickerView alloc]initWithTitle:@"季节保温" delegate:self];
    
    pickerView.pickerStyle=PickerStyle_Mode;
    
    NSInteger selectRow = 0;
    
    if ([self.modeValueLbl.text isEqualToString:@"自定义保温"]) {
        selectRow=0;
    }else  if ([self.modeValueLbl.text isEqualToString:@"春"]) {
        selectRow=1;
    }else if ([self.modeValueLbl.text isEqualToString:@"夏"]) {
        selectRow=2;
    }else if ([self.modeValueLbl.text isEqualToString:@"秋"]) {
        selectRow=3;
    }else if ([self.modeValueLbl.text isEqualToString:@"冬"]) {
        selectRow=4;
    }
    
    
    [pickerView.locatePicker selectRow:selectRow inComponent:0 animated:YES];
    
    [pickerView showInView:superView];
    
    [pickerView pickerView:pickerView.locatePicker didSelectRow:selectRow inComponent:0];
    
}


-(IBAction)startFunction:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(startFunction:)]) {
        [self.delegate kettleStartFunction:sender];
    }
}

-(IBAction)orderStartFunction:(id)sender{
    
    pickerView=[[TimePickerView alloc]initWithTitle:@"选择时间" delegate:self];
    
    pickerView.pickerStyle=PickerStyle_Time;
    
    pickerView.isSetTime=YES;
    
    pickerView.timeDisplayIn24=YES;
    
    pickerView.isOrderType=YES;
    
    //获取当前时间
    NSString *time=[NSUserDefaultInfos getCurrentDate];
    
    int selectHour=[time substringWithRange:NSMakeRange(11, 2)].intValue;
    int selectMin=[time substringWithRange:NSMakeRange(14, 2)].intValue/5+1;
    
    //55分到59分处理
    if (selectMin==12) {
        selectHour++;
        selectMin=0;
    }
    
    
    [pickerView.locatePicker selectRow:selectHour inComponent:0 animated:YES];
    [pickerView.locatePicker selectRow:selectMin inComponent:1 animated:YES];
    
    
    
    [pickerView showInView:superView];
    
    
    [pickerView pickerView:pickerView.locatePicker didSelectRow:selectHour inComponent:0];
    [pickerView pickerView:pickerView.locatePicker didSelectRow:selectMin  inComponent:1];
  
    
}

#pragma mark pickerview回调
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==0) {
        
        
        
        return;
        
        
    }else{
        
        if (pickerView.pickerStyle==PickerStyle_Tem) {
            
            self.temValueLbl.text=[NSString stringWithFormat:@"%li℃",100-[pickerView.locatePicker selectedRowInComponent:0]];
        }
        //        －－－－－－－－－－－－－－－－－－－－－－－
        else if (pickerView.pickerStyle == PickerStyle_CookFood){
            
            switch ([pickerView.locatePicker selectedRowInComponent:0]) {
                case 0:
                    self.FoodValueLbl.text=@"三杯鸡";
                    break;
                case 1:
                    self.FoodValueLbl.text=@"黄焖鸡";
                    break;
                case 2:
                    self.FoodValueLbl.text=@"红烧鱼";
                    break;
                case 3:
                    self.FoodValueLbl.text=@"红焖排骨";
                    break;
                case 4:
                    self.FoodValueLbl.text=@"清炖鸡";
                    break;
                case 5:
                    self.FoodValueLbl.text=@"老火汤";
                    break;
                case 6:
                    self.FoodValueLbl.text=@"红烧肉";
                    break;
                case 7:
                    self.FoodValueLbl.text=@"东坡肘子";
                    break;
                case 8:
                    self.FoodValueLbl.text=@"口水鸡";
                    break;
                case 9:
                    self.FoodValueLbl.text=@"滑香鸡";
                    break;
                case 10:
                    self.FoodValueLbl.text=@"茄子煲";
                    break;
                case 11:
                    self.FoodValueLbl.text=@"梅菜扣肉";
                    break;
                default:
                    break;
            }
            //            －－－－－－－－－－－－－－－－－－－－－－－－－
        }else if (pickerView.pickerStyle==PickerStyle_Mode){
            switch ([pickerView.locatePicker selectedRowInComponent:0]) {
                case 0:
                    self.modeValueLbl.text=@"自定义温度";
                    break;
                case 1:
                    self.modeValueLbl.text=@"春";
                    self.temValueLbl.text=@"43℃";
                    break;
                case 2:
                    self.modeValueLbl.text=@"夏";
                    self.temValueLbl.text=@"40℃";
                    break;
                case 3:
                    self.modeValueLbl.text=@"秋";
                    self.temValueLbl.text=@"45℃";
                    break;
                case 4:
                    self.modeValueLbl.text=@"冬";
                    self.temValueLbl.text=@"55℃";
                    break;
                default:
                    break;
            }
            [self updateSelectTemView];
        }else if(pickerView.pickerStyle==PickerStyle_Time){
            if (self.delegate && [self.delegate respondsToSelector:@selector(orderStartFunction:)]) {
                [self.delegate kettleOrderStartFunction:pickerView];
            }
        }
        
    }
    
}

#pragma mark 当不是自定义温度时不能选择温度
-(void)updateSelectTemView{

    if ([self.modeValueLbl.text isEqualToString:@"自定义温度"]) {
//        self.temBtn.enabled=YES;
////        [self.temBtn setBackgroundColor:[UIColor whiteColor]];
//        self.temValueLbl.textColor=[UIColor darkGrayColor];
//         self.temLbl.textColor=[UIColor blackColor];
        
        self.setTemView.hidden=NO;
 
        CGRect rect=self.setModeView.frame;
        rect.origin.y=self.setChlorineView.frame.size.height+51;
             self.setModeView.frame=rect;
        
        self.temValueLbl.text=[NSString stringWithFormat:@"%i℃",[NSUserDefaultInfos getIntValueforKey:DEFAULT_TEM]];
    
    }else{
//        self.temBtn.enabled=NO;
//        self.temValueLbl.textColor=[UIColor lightGrayColor];
//        self.temLbl.textColor=[UIColor lightGrayColor];
        self.setTemView.hidden=YES;
       self.setModeView.frame=self.setTemView.frame;
   
    }
}
@end
