//
//  ChoiceMenuView.h
//  Product
//
//  Created by 肖栋 on 16/10/19.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ChoiceMenuDelegate <NSObject>

@required

-(void)selectTime:(id)sender;

-(void)startFunction:(id)sender;

@end

@interface ChoiceMenuView : UIViewController

@property(nonatomic,strong) IBOutlet UILabel *titleLbl,*timeLbl,*startLbl,*orderLbl;

@property(nonatomic,strong)IBOutlet UIButton *startBtn,*orderBtn,*timeBtn;

@property (strong, nonatomic) IBOutlet UIView *setFireView;

@property (weak, nonatomic) IBOutlet UIView *backFireView;
@property (nonatomic,assign) id <ChoiceMenuDelegate> delegate;

-(IBAction)startFunction:(id)sender;

-(void)showInView:(UIView*)view;

-(void)dismissView;

-(IBAction)removeView:(id)sender;

@property (nonatomic,strong)UILabel *fireText;

@end
