//
//  CharacterTeaView.h
//  Product
//
//  Created by 肖栋 on 17/1/13.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CharacterTeaDelegate <NSObject>

@required

-(void)fruitTeaFunction:(id)sender;

-(void)scentedTeaStartFunction:(id)sender;


@end
@interface CharacterTeaView : UIViewController
@property (nonatomic,assign) id <CharacterTeaDelegate> delegate;

-(IBAction)fruitTeaFunction:(id)sender;

-(IBAction)scentedTeaStartFunction:(id)sender;

-(void)showInView:(UIView*)view;

-(void)dismissView;

@end


