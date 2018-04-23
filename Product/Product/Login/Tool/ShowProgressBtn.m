//
//  ShowProgressBtn.m
//  Product
//
//  Created by Xlink on 15/11/30.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "ShowProgressBtn.h"

@implementation ShowProgressBtn{
    UIActivityIndicatorView *actIV;
}

-(void)showIndicator{
        if (!actIV) {
            actIV=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-7, self.frame.size.height/2-7, 15, 15)];
            [super addSubview:actIV];
        }
        
        [self setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        self.enabled=NO;
        
        [actIV startAnimating];

}

-(void)hideIndicator{
        if (actIV&&actIV.isAnimating) {
            [actIV stopAnimating];
            [actIV removeFromSuperview];
            actIV=nil;
        }
    
        self.enabled=YES;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}




@end
