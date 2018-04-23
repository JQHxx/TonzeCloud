//
//  ControllerButtonView.m
//  Product
//
//  Created by Xlink on 16/1/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "ControllerButtonView.h"

@interface ControllerButtonView ()

@end

@implementation ControllerButtonView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)selectFunction:(id)sender{
    
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(selectFunction:)]) {
        [self.delegate selectFunction:sender];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
