//
//  decompressionStartView.h
//  Product
//
//  Created by 梁家誌 on 2016/10/24.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"

@protocol decompressionStartFunctionDelegate <NSObject>

@required

-(void)showPreferenceDetail:(id)sender;

-(void)decompressionStartFunction:(id)sender;

-(void)decompressionOrderStartFunction:(id)sender;

-(void)changePreferenceFunction:(id)sender;

@end

@interface decompressionStartView : UIViewController

@property(nonatomic,strong) IBOutlet UILabel *titleLbl,*detailLbl,*startLbl,*orderLbl;

@property(nonatomic,strong)IBOutlet UIButton *startBtn,*orderBtn,*detailBtn,*changeBtn;

@property(nonatomic,strong)IBOutlet UIImageView *preferenceImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadActivity;

@property(nonatomic,strong)IBOutlet UIView *setPreferenceView;

@property (nonatomic,weak) id <decompressionStartFunctionDelegate> delegate;


-(IBAction)showPreferenceDetail:(id)sender;

-(IBAction)startFunction:(id)sender;

-(IBAction)orderStartFunction:(id)sender;

- (IBAction)changePreference:(UIButton *)sender;

-(void)showInView:(UIView*)view;

-(void)dismissView;

@property(nonatomic,strong)DeviceModel *model;
@property (strong, nonatomic) NSString *preference;

-(void)getPreferenceInfo:(NSData *)data;

@end
