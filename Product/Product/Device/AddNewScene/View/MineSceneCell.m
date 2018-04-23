
//
//  MineSceneCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "MineSceneCell.h"

@interface MineSceneCell ()
/// 图片滑动
@property (nonatomic, strong) UIScrollView *imgSrcollView;

@end
@implementation MineSceneCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setMineSceneCell];
    }
    return self;
}
#pragma mark ====== Set UI =======

- (void)setMineSceneCell{
    
    _sceneNameLab = InsertLabel(self.contentView, CGRectMake( 20, (96/2 - 20)/2, kScreenWidth  - 120, 20), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
    
   _deviceNumberLab = InsertLabel(self.contentView, CGRectMake( kScreenWidth - 120, (96/2 - 20)/2, 80, 20), NSTextAlignmentRight, @"", kFontSize(14), KSysOrangeColor, NO);
    InsertImageView(self.contentView, CGRectMake(kScreenWidth - 35, (48 - 15)/2 , 15, 15), [UIImage imageNamed:@"ic_pub_arrow_nor"]);
    
    // 横向
    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(0, 96/2, kScreenWidth , 0.5)];
    len.backgroundColor = UIColorHex(0xEEEEEE);
    [self.contentView addSubview:len];
    
    _imgSrcollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, len.bottom, kScreenWidth, 90)];
    _imgSrcollView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:_imgSrcollView];
    
    UILabel *bottonLen = [[UILabel alloc]initWithFrame:CGRectMake(0, 276/2, kScreenWidth, 15)];
    bottonLen.backgroundColor = [UIColor bgColor_Gray];
    [self.contentView addSubview:bottonLen];
}
#pragma mark ====== Set Data =======

- (void)cellWithMineSceneMode:(MineSceneModel *)model{
    _sceneNameLab.text = model.scene_name;
    _deviceNumberLab.text = [NSString stringWithFormat:@"%@个设备",model.device_num];
}

- (void)setDeviceProductIdArray:(NSArray *)deviceProductIdArray{
    // 移除之前绘制的设备图标
    for(UIImageView *imgView in [self.imgSrcollView subviews])
    {
        if ([imgView isKindOfClass:[UIImageView class]]) {
            [imgView removeFromSuperview];
        }
    }
    for (NSInteger i = 0; i < deviceProductIdArray.count;  i++) {
        UIImageView *iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(20 + (i * (16 + 65)), 25/2, 65, 65)];
        NSDictionary *dict=deviceProductIdArray[i];
        iconImg.image = [self setIconImageWithDeviceProductId:dict[@"product_id"]];
        [_imgSrcollView addSubview:iconImg];
        if (iconImg.right + 20 > kScreenWidth) {
            _imgSrcollView.contentSize = CGSizeMake(iconImg.right + 30, 90);
        }
    }
}
// 根据设备的产品ID设置图片
- (UIImage *)setIconImageWithDeviceProductId:(NSString *)productId{

    if ([productId isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]) {
        ///云智能IH电饭煲
        return [UIImage imageNamed:@"gray_eq03"];
    }else if ([productId isEqualToString:CLOUD_COOKER_PRODUCT_ID]){
        ///云智能电炖锅
        return [UIImage imageNamed:@"gray_eq04"];
    }else if ([productId isEqualToString:WATER_COOKER_PRODUCT_ID]){
        ///云智能隔水炖
        return [UIImage imageNamed:@"gray_eq01"];
    }else if ([productId isEqualToString:CLOUD_KETTLE_PRODUCT_ID]){
        ///云智能私享壶
        return [UIImage imageNamed:@"gray_eq05"];
    }else if ([productId isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]){
        ///云智能隔水炖16AIG
        return [UIImage imageNamed:@"gray_eq02"];
    }else if ([productId isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]){
        ///云智能健康大厨
        return [UIImage imageNamed:@"gray_eq06"];
    }
    return nil;
}

@end
