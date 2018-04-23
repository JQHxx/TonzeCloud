//
//  KettleTemView.m
//  Product
//
//  Created by 肖栋 on 16/12/14.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "KettleTemView.h"
#import "KettleTemCell.h"

@interface KettleTemView ()<UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    UIView *backgroudView;
    NSArray *imgArray;
    NSArray *temNameArray;
    NSArray *temlbArray ;
}


@end

@implementation KettleTemView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    backgroudView=[[UIView alloc]initWithFrame:[ UIScreen mainScreen ].bounds];
    [backgroudView setBackgroundColor:[UIColor blackColor]];
    [backgroudView setAlpha:0.3f];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [backgroudView addGestureRecognizer:gesture];
    
    imgArray = [NSArray arrayWithObjects:@"img_tea_红茶",@"img_tea_白豪银针",@"img_tea_白牡丹",@"img_tea_贡眉",@"img_tea_寿眉",@"img_tea_黑茶",@"img_tea_黄茶",@"img_tea_绿茶",@"img_tea_乌龙茶",@"img_tea_普洱茶",@"img_tea_沱茶",@"img_tea_铁观音",@"img_tea_武夷岩茶",@"img_tea_砖茶",nil];
    temNameArray = [NSArray arrayWithObjects:@"红茶",@"白豪银针",@"白牡丹",@"贡眉",@"寿眉",@"黑茶",@"黄茶",@"绿茶",@"乌龙茶",@"普洱茶",@"沱茶",@"铁观音",@"武夷岩茶",@"砖茶",nil];
    temlbArray = [NSArray arrayWithObjects:@"95°",@"90°",@"90°",@"100°",@"100°",@"100°",@"75°",@"85°",@"100°",@"100°",@"100°",@"95°",@"95°",@"100°",nil];
    _KettleTabView.dataSource= self;
    _KettleTabView.delegate = self;
    _KettleTabView.layer.masksToBounds=YES;
    _KettleTabView.layer.cornerRadius=10.0f;
    [_KettleTabView registerNib:[UINib nibWithNibName:@"KettleTemCell" bundle:nil] forCellReuseIdentifier:@"KettleTemCell"];

}
-(void)showInView:(UIView*)view{
    
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.view setAlpha:1.0f];
    [self.view.layer addAnimation:animation forKey:@"DDLocateView"];
    self.view.frame = CGRectMake(0, view.frame.size.height - self.view.frame.size.height,SCREEN_WIDTH, self.view.frame.size.height);
    
    [view addSubview:backgroudView];
    [view addSubview:self.view];
    
}

-(IBAction)removeView:(id)sender{
    
    
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.view setAlpha:0.0f];
    [self.view.layer addAnimation:animation forKey:@"TSLocateView"];
    self.view.frame = CGRectMake(0,SCREEN_HEIGHT - self.view.frame.size.height, SCREEN_WIDTH, self.view.frame.size.height);
    
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3f];
    
}
-(void)dismissView{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.view setAlpha:0.0f];
    [self.view.layer addAnimation:animation forKey:@"TSLocateView"];
    self.view.frame = CGRectMake(0,SCREEN_HEIGHT - self.view.frame.size.height, SCREEN_WIDTH, self.view.frame.size.height);
    
    [self performSelector:@selector(viewRemoveFromSuperview) withObject:nil afterDelay:0.3f];
    
    
}

-(void)viewRemoveFromSuperview{
    [backgroudView removeFromSuperview];
    [self.view removeFromSuperview];
}
#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return temlbArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    KettleTemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KettleTemCell" forIndexPath:indexPath];
    
    cell.temName.text = temNameArray[indexPath.row];
    cell.tempLB.text = temlbArray[indexPath.row];
    cell.teaImgView.image =[UIImage imageNamed:imgArray[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"%ld",(long)indexPath.row);
    
//        [self.model.State setObject:temlbArray[indexPath.row] forKey:@"tem"];
        [self.model.State setObject:temNameArray[indexPath.row] forKey:@"state"];
        [self.model.State setObject:@"00" forKey:@"orderHour"];
        [self.model.State setObject:@"00" forKey:@"orderMin"];
        [[ControllerHelper shareHelper]controllDevice:self.model];

}


@end
