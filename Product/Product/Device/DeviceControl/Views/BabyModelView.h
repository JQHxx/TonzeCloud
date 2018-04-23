//
//  BabyModelView.h
//  Product
//
//  Created by 肖栋 on 17/1/13.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BabyStartFunctionDelegate <NSObject>

@required

-(void)startFunction:(id)sender;

@end
@interface BabyModelView : UIViewController{

    __weak IBOutlet UIButton *startBabyModelBtn;
}
@property (nonatomic,assign) id <BabyStartFunctionDelegate> delegate;
-(IBAction)startFunction:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *choiceModel;
@property (weak, nonatomic) IBOutlet UILabel            *remindLabel;
@property (weak, nonatomic) IBOutlet UILabel            *pormptLabel;
@property (strong, nonatomic) IBOutlet UIView           *backFireView;
@property (nonatomic,assign)NSInteger                    temperature;
@property (nonatomic, strong) NSString                  *preserveHeatValue;   //冲奶粉温度
@property (nonatomic, strong) NSString                  *heatValue;          //温母乳温度
@property (nonatomic, strong) NSString                  *heatModel;          //加热模式
-(void)showInView:(UIView*)view;
-(void)dismissView;
@end
