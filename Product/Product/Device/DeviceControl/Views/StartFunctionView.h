//
//  StartFunctionView.h
//  Product
//
//  Created by Xlink on 16/1/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StartFunctionDelegate <NSObject>

@required

-(void)selectTime:(id)sender;

-(void)startFunction:(id)sender;

-(void)orderStartFunction:(id)sender;


@end


@interface StartFunctionView : UIViewController

@property(nonatomic,strong) IBOutlet UILabel *titleLbl,*timeLbl,*startLbl,*orderLbl;

@property(nonatomic,strong)IBOutlet UIButton *startBtn,*orderBtn,*timeBtn;

@property(nonatomic,strong)IBOutlet UIView *setTimeView;

@property (nonatomic,weak) id <StartFunctionDelegate> delegate;

@property (nonatomic)BOOL canSetWorkTime;//能否设置烹饪时长

-(IBAction)selectTime:(id)sender;

-(IBAction)startFunction:(id)sender;

-(IBAction)orderStartFunction:(id)sender;

-(void)showInView:(UIView*)view;

-(void)dismissView;

@end
