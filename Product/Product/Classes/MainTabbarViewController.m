//
//  MainTabbarViewController.m
//  Product
//
//  Created by Xlink on 15/12/1.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "MainTabbarViewController.h"
#import "AutoLoginManager.h"
#import "DeviceViewController.h"
#import "MineViewController.h"

@interface MainTabbarViewController ()

@end

@implementation MainTabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    //必须要在这里自定义选中图片
    NSArray *items = self.tabBar.items;
    
    UITabBarItem *Item0 = items[0];
    Item0.image = [[UIImage imageNamed:@"ic_tab_01_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    Item0.selectedImage = [[UIImage imageNamed:@"ic_tab_01_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [Item0 setTitleTextAttributes:[NSDictionary
                                   dictionaryWithObjectsAndKeys: UIColorFromRGB(0x727272),
                                   NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [Item0 setTitleTextAttributes:[NSDictionary
                                   dictionaryWithObjectsAndKeys: UIColorFromRGB(0xff8314),
                                   NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    UITabBarItem *Item1 = items[1];
    Item1.image = [[UIImage imageNamed:@"ic_tab_02_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    Item1.selectedImage = [[UIImage imageNamed:@"ic_tab_02_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [Item1 setTitleTextAttributes:[NSDictionary
                                  dictionaryWithObjectsAndKeys: UIColorFromRGB(0x727272),
                                  NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [Item1 setTitleTextAttributes:[NSDictionary
                                   dictionaryWithObjectsAndKeys: UIColorFromRGB(0xff8314),
                                   NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    UITabBarItem *Item2 = items[2];
    Item2.image = [[UIImage imageNamed:@"ic_tab_03_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    Item2.selectedImage = [[UIImage imageNamed:@"ic_tab_03_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [Item2 setTitleTextAttributes:[NSDictionary
                                   dictionaryWithObjectsAndKeys: UIColorFromRGB(0x727272),
                                   NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [Item2 setTitleTextAttributes:[NSDictionary
                                   dictionaryWithObjectsAndKeys: UIColorFromRGB(0xff8314),
                                   NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    UITabBarItem *Item3 = items[3];
    Item3.image = [[UIImage imageNamed:@"ic_tab_04_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    Item3.selectedImage = [[UIImage imageNamed:@"ic_tab_04_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [Item3 setTitleTextAttributes:[NSDictionary
                                   dictionaryWithObjectsAndKeys: UIColorFromRGB(0x727272),
                                   NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [Item3 setTitleTextAttributes:[NSDictionary
                                   dictionaryWithObjectsAndKeys: UIColorFromRGB(0xff8314),
                                   NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    UITabBarItem *Item4 = items[4];
    Item4.image = [[UIImage imageNamed:@"ic_tab_05_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    Item4.selectedImage = [[UIImage imageNamed:@"ic_tab_05_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [Item4 setTitleTextAttributes:[NSDictionary
                                   dictionaryWithObjectsAndKeys: UIColorFromRGB(0x727272),
                                   NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [Item4 setTitleTextAttributes:[NSDictionary
                                   dictionaryWithObjectsAndKeys: UIColorFromRGB(0xff8314),
                                   NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 49)];
    backView.backgroundColor =[UIColor whiteColor];
    [self.tabBar insertSubview:backView atIndex:0];
    self.tabBar.opaque = YES;
    
}


@end
