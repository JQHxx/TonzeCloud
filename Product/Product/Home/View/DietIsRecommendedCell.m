//
//  DietIsRecommendedCell.m
//  Product
//
//  Created by zhuqinlu on 2018/3/21.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import "DietIsRecommendedCell.h"
#import "TJYFoodRecommendModel.h"

@interface DietIsRecommendedCell ()
{
    UIImageView     *_firstImgView;
    UIImageView     *_secondImgView;
    UIImageView     *_threeImgView;
    
    UILabel         *_firstNameLab;
    UILabel         *_secondNameLab;
    UILabel         *_threeNameLab;
}
@end

@implementation DietIsRecommendedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _firstImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, (kScreenWidth - 30)/3 ,(kScreenWidth - 30)/3)];
        _firstImgView.image = [UIImage imageNamed:@"img_h_caipu"];
        _firstImgView.layer.cornerRadius = 5;
        _firstImgView.contentMode = UIViewContentModeScaleAspectFill;
        _firstImgView.layer.masksToBounds = YES;
        _firstImgView.userInteractionEnabled = YES;
        [self addSubview:_firstImgView];
        
        
        CGFloat lineHight = 25 *kScreenWidth/375;
        
        UILabel *firstLen = [[UILabel alloc]initWithFrame:CGRectMake(0, _firstImgView.height - lineHight, _firstImgView.width, lineHight)];
        firstLen.backgroundColor = UIColorHex_Alpha(0x000000, 0.4);
        [_firstImgView addSubview:firstLen];
        
        _firstNameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, firstLen.top, firstLen.width,lineHight)];
        _firstNameLab.textAlignment = NSTextAlignmentCenter;
        _firstNameLab.font = kFontSize(12);
        _firstNameLab.textColor = UIColorHex(0xffffff);
        [_firstImgView addSubview:_firstNameLab];
        
        _secondImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_firstImgView.right + 5, 0, (kScreenWidth - 30)/3 ,(kScreenWidth - 30)/3)];
        _secondImgView.image = [UIImage imageNamed:@"img_h_caipu"];
        _secondImgView.layer.cornerRadius = 5;
        _secondImgView.contentMode = UIViewContentModeScaleAspectFill;
        _secondImgView.layer.masksToBounds = YES;
        _secondImgView.userInteractionEnabled = YES;
        [self addSubview:_secondImgView];
        
        UILabel *secondLen = [[UILabel alloc]initWithFrame:CGRectMake(0, firstLen.top, _firstImgView.width, firstLen.height)];
        secondLen.backgroundColor = UIColorHex_Alpha(0x000000, 0.4);
        [_secondImgView addSubview:secondLen];

        _secondNameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, _firstNameLab.top, _firstNameLab.width , _firstNameLab.height)];
        _secondNameLab.textAlignment = NSTextAlignmentCenter;
        _secondNameLab.font = kFontSize(12);
        _secondNameLab.textColor = UIColorHex(0xffffff);
        [_secondImgView addSubview:_secondNameLab];
        
        _threeImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_secondImgView.right + 5, 0,  (kScreenWidth - 30)/3 ,(kScreenWidth - 30)/3)];
        _threeImgView.image = [UIImage imageNamed:@"img_h_caipu"];
        _threeImgView.layer.cornerRadius = 5;
        _threeImgView.contentMode = UIViewContentModeScaleAspectFill;
        _threeImgView.layer.masksToBounds = YES;
        _threeImgView.userInteractionEnabled = YES;
        [self addSubview:_threeImgView];
        
        UILabel *threeLen = [[UILabel alloc]initWithFrame:CGRectMake(0, firstLen.top, _firstImgView.width, firstLen.height)];
        threeLen.backgroundColor = UIColorHex_Alpha(0x000000, 0.4);
        [_threeImgView addSubview:threeLen];
        
        _threeNameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, _firstNameLab.top, _firstNameLab.width , _firstNameLab.height)];
        _threeNameLab.textAlignment = NSTextAlignmentCenter;
        _threeNameLab.font = kFontSize(12);
        _threeNameLab.textColor = UIColorHex(0xffffff);
        [_threeImgView addSubview:_threeNameLab];
        
        
        for (NSInteger i = 0; i < 3; i++) {
            UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            menuBtn.frame = CGRectMake(10 + (kScreenWidth - 30)/3 * i , 0 , (kScreenWidth - 30)/3,(kScreenWidth - 30)/3);
            menuBtn.backgroundColor = [UIColor clearColor];
            menuBtn.tag = 1000 + i;
            [menuBtn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:menuBtn];
        }
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipArticleTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipGestureRight];
    }
    return self;
}
#pragma mark ------  Action  ----

-(void)swipArticleTableView:(UISwipeGestureRecognizer *)gesture{

    if ([self.delegate respondsToSelector:@selector(swipMealTime:)]) {
        [self.delegate swipMealTime:gesture];
    }
}

- (void)menuBtnClick:(UIButton *)sender{
    
    if ([self.delegate respondsToSelector:@selector(menuClickIndexRow:)]) {
        [self.delegate menuClickIndexRow:sender.tag];
    }
}

#pragma mark ====== Setter =======
- (void)setRecommendDietData:(NSArray *)recommendDietData{
    
    if (kIsArray(recommendDietData)&& recommendDietData.count == 3) {
        for (NSInteger i = 0; i < recommendDietData.count; i++) {
            
            TJYFoodRecommendModel *recommendModel = [[TJYFoodRecommendModel alloc]init];
            recommendModel = recommendDietData[i];
            switch (i) {
                case 0:
                {
                    [_firstImgView sd_setImageWithURL:[NSURL URLWithString:recommendModel.image_url] placeholderImage:[UIImage imageNamed:@"img_h_caipu"]];
                    _firstNameLab.text = recommendModel.food_name;
                }
                    break;
                case 1:
                {
                    [_secondImgView sd_setImageWithURL:[NSURL URLWithString:recommendModel.image_url] placeholderImage:[UIImage imageNamed:@"img_h_caipu"]];
                    _secondNameLab.text = recommendModel.food_name;
                }
                    break;
                case 2:
                {
                    [_threeImgView sd_setImageWithURL:[NSURL URLWithString:recommendModel.image_url] placeholderImage:[UIImage imageNamed:@"img_h_caipu"]];
                    _threeNameLab.text = recommendModel.food_name;
                }
                    break;
                default:
                    break;
            }
        }
    }else if (kIsArray(recommendDietData)&& recommendDietData.count == 2){
        
        for (NSInteger i = 0; i < recommendDietData.count; i++) {
            
            TJYFoodRecommendModel *recommendModel = [[TJYFoodRecommendModel alloc]init];
            recommendModel = recommendDietData[i];
            switch (i) {
                case 0:
                {
                    [_firstImgView sd_setImageWithURL:[NSURL URLWithString:recommendModel.image_url] placeholderImage:[UIImage imageNamed:@"img_h_caipu"]];
                    _firstNameLab.text = recommendModel.food_name;
                }
                    break;
                case 1:
                {
                    [_secondImgView sd_setImageWithURL:[NSURL URLWithString:recommendModel.image_url] placeholderImage:[UIImage imageNamed:@"img_h_caipu"]];
                    _secondNameLab.text = recommendModel.food_name;
                }
                    break;
                default:
                    break;
            }
        }
    }else if (kIsArray(recommendDietData)&& recommendDietData.count == 1){
        
            TJYFoodRecommendModel *recommendModel = [[TJYFoodRecommendModel alloc]init];
            recommendModel = recommendDietData[0];
            
            [_firstImgView sd_setImageWithURL:[NSURL URLWithString:recommendModel.image_url] placeholderImage:[UIImage imageNamed:@"img_h_caipu"]];
            _firstNameLab.text = recommendModel.food_name;
            
            _secondImgView.image = [UIImage imageNamed:@"img_h_caipu"];
            _secondNameLab.text = @"";

            _threeImgView.image = [UIImage imageNamed:@"img_h_caipu"];
            _threeNameLab.text = @"";
    }else{
        _firstImgView.image = [UIImage imageNamed:@"img_h_caipu"];
        _firstNameLab.text = @"";
    
        _secondImgView.image = [UIImage imageNamed:@"img_h_caipu"];
        _secondNameLab.text = @"";
    
        _threeImgView.image = [UIImage imageNamed:@"img_h_caipu"];
        _threeNameLab.text = @"";
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
