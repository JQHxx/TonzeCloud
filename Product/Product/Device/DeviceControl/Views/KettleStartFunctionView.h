//
//  KettleStartFunctionView.h
//  Product
//
//  Created by Feng on 16/3/19.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KettleStartFunctionDelegate <NSObject>

@required

-(void)kettleStartFunction:(id)sender;

-(void)kettleOrderStartFunction:(id)sender;


@end

@interface KettleStartFunctionView : UIViewController

@property(nonatomic,strong) IBOutlet UILabel *chlorineLbl,*modeValueLbl,*FoodValueLbl,*temValueLbl,*startLbl,*orderLbl,*temLbl,*CookFoodValueLbl;

@property(nonatomic,strong)IBOutlet UIButton *startBtn,*orderBtn,*temBtn,*modeBtn,*cookBtn;

@property(nonatomic,strong)IBOutlet UIView *setTemView;

@property(nonatomic,strong)IBOutlet UIView *setModeView;

@property(nonatomic,strong)IBOutlet UIView *setChlorineView;

@property(nonatomic,strong)IBOutlet UIView *bView;

@property(nonatomic,strong)IBOutlet UISwitch *chlorineSwitch;

@property (nonatomic,assign) id <KettleStartFunctionDelegate> delegate;

-(void)updateUIwithFunctionIndex:(NSInteger)index;

-(IBAction)selectTem:(id)sender;

-(IBAction)selectMode:(id)sender;


-(IBAction)startFunction:(id)sender;

-(IBAction)orderStartFunction:(id)sender;

-(void)showInView:(UIView*)view;

-(void)dismissView;
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
@property (weak, nonatomic) IBOutlet UILabel *foodValueLbl;

-(IBAction)selectFood:(id)sender;

@property(nonatomic,strong)IBOutlet UIView *setFoodView;

@property (nonatomic)BOOL canSetchoiceMenu;//是否进入菜谱选择
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
@end
