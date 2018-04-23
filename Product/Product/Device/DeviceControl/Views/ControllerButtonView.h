//
//  ControllerButtonView.h
//  Product
//
//  Created by Xlink on 16/1/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FunctionDelegate <NSObject>

@required
-(void)selectFunction:(id)sender;
@end


@interface ControllerButtonView : UIViewController

@property(nonatomic,strong)IBOutlet UIButton *functionBtn;

@property(nonatomic,strong)IBOutlet UILabel *functionLbl;

@property (nonatomic,weak) id <FunctionDelegate> delegate;

-(IBAction)selectFunction:(id)sender;

@end
