
//
//  RecommendedSceneView.m
//  Product
//
//  Created by zhuqinlu on 2017/6/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecommendedSceneView.h"
#import "RecommendedSceneAfterView.h"

@interface RecommendedSceneView ()

@property (nonatomic, strong) UIScrollView *rootView;

@end
@implementation RecommendedSceneView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setRecommendedSceneView];
    }
    return self;
}
#pragma mark ====== Set UI =======

- (void)setRecommendedSceneView{
    
    _rootView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kBodyHeight - 44)];
    _rootView.backgroundColor = [UIColor bgColor_Gray];
    [self addSubview:_rootView];
    // -- 无场景
    UIView *unSceneHeadView = InsertView(_rootView, CGRectMake(0, 0, kScreenWidth, 350/2), [UIColor whiteColor]);
    
    UIImageView *unSceneImg = InsertImageView(unSceneHeadView, CGRectMake((kScreenWidth - 170/2)/2, 61/2, 170/2, 170/2), [UIImage imageNamed:@"no_equipment"]);
    
    UILabel *unSceneTextLab = [[UILabel alloc]initWithFrame:CGRectMake(0, unSceneImg.bottom + 11 ,kScreenWidth, 20)];
    unSceneTextLab.text = @"您目前暂无场景";
    unSceneTextLab.textAlignment = NSTextAlignmentCenter;
    unSceneTextLab.textColor = UIColorHex(0x959595);
    unSceneTextLab.font = kFontSize(15);
    [unSceneHeadView addSubview:unSceneTextLab];
    
    UILabel *recommendTextLab =[[UILabel alloc]initWithFrame:CGRectMake(20, unSceneHeadView.bottom + 15,kScreenWidth, 20)];
    recommendTextLab.text = @"推荐场景";
    recommendTextLab.textColor = UIColorHex(0x313131);
    recommendTextLab.font = kFontSize(15);
    [_rootView addSubview:recommendTextLab];
    
    // -- 推荐场景
    UIView *sceneView = [[UIView alloc]initWithFrame:CGRectMake(0, 450/2, kScreenWidth, 446/2)];
    sceneView.backgroundColor = [UIColor whiteColor];
    [_rootView addSubview:sceneView];
    
    UILabel *sceneTextLab =[[UILabel alloc]initWithFrame:CGRectMake(20, (95/2 - 20)/2,kScreenWidth, 20)];
    sceneTextLab.text = @"智能厨房";
    sceneTextLab.textColor = UIColorHex(0x313131);
    sceneTextLab.font = kFontSize(15);
    [sceneView addSubview:sceneTextLab];
    
    UILabel *deviceNumLab =[[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 115 , sceneTextLab.top ,100, 20)];
    deviceNumLab.text = @"3个设备";
    deviceNumLab.textColor = KSysOrangeColor;
    deviceNumLab.font = kFontSize(14);
    deviceNumLab.textAlignment = NSTextAlignmentRight;
    [sceneView addSubview:deviceNumLab];

    UILabel *len1 =[[UILabel alloc]initWithFrame:CGRectMake(0, 96/2, kScreenWidth,0.5)];
    len1.backgroundColor = [UIColor bgColor_Gray];
    [sceneView addSubview:len1];
    
    NSArray *deviceImgArray = @[@"gray_eq02",@"gray_eq03",@"gray_eq04"];
    for (NSInteger i = 0; i < 3; i++) {
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake( 20 + i * (130/2 + 16), len1.bottom + 25/2 ,130/2, 130/2)];
        img.image = [UIImage imageNamed:deviceImgArray[i]];
        [sceneView addSubview:img];
    }
    
    UILabel *len2 =[[UILabel alloc]initWithFrame:CGRectMake(0, len1.bottom + 90, kScreenWidth,0.5)];
    len2.backgroundColor = [UIColor bgColor_Gray];
    [sceneView addSubview:len2];
    
    UILabel *tipLab = InsertLabel(sceneView, CGRectMake(20, len2.bottom + 15, kScreenWidth - 40, 15), NSTextAlignmentLeft, @"场景介绍:", kFontSize(13), UIColorHex(0x959595), YES);
    InsertLabel(sceneView, CGRectMake(tipLab.right, len2.bottom + 15, kScreenWidth - tipLab.right - 20, 60), NSTextAlignmentLeft, @"下班途中，执行场景，隔水炖煲汤、电饭煲煮饭、电炖锅蒸菜，当您到家，无需等待即可品尝美味佳肴", kFontSize(13), UIColorHex(0x959595), YES);
    
    // 竖线
    UILabel *vLen = [[UILabel alloc]initWithFrame:CGRectMake( 15 + 11, sceneView.bottom + 15, 2, 468)];
    vLen.backgroundColor = UIColorHex(0xe3e6e6);
    [_rootView addSubview:vLen];
    
    UIImageView *startIcom = InsertImageView(_rootView, CGRectMake( 15, sceneView.bottom + 13, 24, 24), [UIImage imageNamed:@"RecommendedScene_start_ic"]);
    
    InsertImageView(_rootView, CGRectMake(15, vLen.bottom, 24, 24), [UIImage imageNamed:@"RecommendedScene_finsh_ic"]);
    
    InsertLabel(sceneView, CGRectMake(startIcom.right + 12, sceneView.top + 15 , 200, 20), NSTextAlignmentLeft, @"执行智能厨房场景", kFontSize(15), UIColorHex(0x313131), YES);

    NSArray *deviceNameArray = @[@"云智能电炖锅",@"云智能IH电饭煲",@"云智能隔水炖"];
    NSArray *titleArray = @[@"炖煮：1小时",@"精华煮",@"云菜谱：虫草花乌鸡汤"];
    NSArray *deviceImgArr = @[@"orange_eq02",@"orange_eq03",@"orange_eq04"];
    // -- 场景执行过程
    for (NSInteger i = 0; i < 3; i++) {
        if (i == 2) {
            RecommendedSceneAfterView *sceneAfterView = [[RecommendedSceneAfterView alloc]initWithFrame:CGRectMake(15 + 26 ,sceneView.bottom + 50 - 30 + i * (116 + 50) , kScreenWidth - 54 , 116)];
            [_rootView addSubview:sceneAfterView];
            sceneAfterView.deviceImg.image = [UIImage imageNamed:deviceImgArr[i]];
            sceneAfterView.deviceNameLab.text = deviceNameArray[i];
            sceneAfterView.cookingMethodLab.text = titleArray[i];
            InsertImageView(_rootView, CGRectMake(21, sceneView.bottom + 50 - 18 + i * (116 + 50), 12, 12), [UIImage imageNamed:@"RecommendedScene_normal_ic"]);
        }else{
            RecommendedSceneAfterView *sceneAfterView = [[RecommendedSceneAfterView alloc]initWithFrame:CGRectMake(15 + 26 ,sceneView.bottom + 50 + i * (116 + 50) , kScreenWidth - 54 , 116)];
            [_rootView addSubview:sceneAfterView];
            sceneAfterView.deviceImg.image = [UIImage imageNamed:deviceImgArr[i]];
            sceneAfterView.deviceNameLab.text = deviceNameArray[i];
            sceneAfterView.cookingMethodLab.text = titleArray[i];
            InsertImageView(_rootView, CGRectMake(21, sceneView.bottom + 50 + 12 + i * (116 + 50), 12, 12), [UIImage imageNamed:@"RecommendedScene_normal_ic"]);
        }
    }
    // 间隔时间
    UIImageView *timeIcon = InsertImageView(_rootView, CGRectMake(42/2, sceneView.bottom + 185, 13, 13), [UIImage imageNamed:@"RecommendedScene_time_ic"]);
    
    InsertLabel(_rootView, CGRectMake(timeIcon.right + 15, timeIcon.top - 2 , 200 , 20), NSTextAlignmentLeft, @"间隔时间30分钟", kFontSize(14), UIColorHex(0x959595), NO);
    
    _rootView.contentSize = CGSizeMake(kScreenWidth, 870 + 122);
}

@end
