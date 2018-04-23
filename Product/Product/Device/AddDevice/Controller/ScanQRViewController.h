//
//  ScanQRViewController.h
//  Product
//
//  Created by Xlink on 15/12/8.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"



@interface ScanQRViewController : BaseViewController{
    IBOutlet UILabel *lineLbl;
    IBOutlet UIView *upView,*downView;
}
@property (weak, nonatomic) IBOutlet UIButton *flashlightButton;

@property (nonatomic, copy) NSString * m_strSN;
@property (nonatomic, copy) NSString * strVerifyCode;
@property (nonatomic, copy) NSString * strModel;
@property (nonatomic, copy) NSString * m_strAESVersion;
@property (nonatomic, copy) NSString * m_strDetectorSubType;

@property int View_Type;
- (IBAction)flashlightAction:(id)sender;

@end
