//
//  LiuXSlider.m
//  LJSlider
//
//  Created by 刘鑫 on 16/3/24.
//  Copyright © 2016年 com.anjubao. All rights reserved.
//

//  git地址：https://github.com/xinge1/LiuXSlider
//



#define SelectViewBgColor   [UIColor colorWithRed:9/255.0 green:170/255.0 blue:238/255.0 alpha:1]
#define defaultViewBgColor  [UIColor lightGrayColor]

#define LiuXSlideWidth      (self.bounds.size.width)
#define LiuXSliderHight     (self.bounds.size.height)

#define LiuXSliderTitle_H   (LiuXSliderHight*.3)

#define CenterImage_W       26.0

#define LiuXSliderLine_W    (LiuXSlideWidth-CenterImage_W)
#define LiuXSLiderLine_H    10.0
#define LiuXSliderLine_Y    (LiuXSliderHight-LiuXSliderTitle_H)


#define CenterImage_Y       (LiuXSliderLine_Y+(LiuXSLiderLine_H/2))


#import "LiuXSlider.h"

@interface LiuXSlider()
{

    CGFloat _sectionLength;//根据数组分段后一段的长度
    UILabel *_selectLab;
}
/**
 *  必传，范围（0到(array.count-1)）
 */
@property (nonatomic,assign)CGFloat defaultIndx;

/**
 *  必传，传入节点数组
 */
@property (nonatomic,strong)NSArray *titleArray;

/**
 *  首，末位置的title
 */
@property (nonatomic,strong)NSArray *firstAndLastTitles;
/**
 *  传入图片
 */
@property (nonatomic,strong)UIImage *sliderImage;

@property (strong,nonatomic)UIImageView *selectView;
@property (strong,nonatomic)UIImageView *defaultView;
@property (strong,nonatomic)UIImageView *centerImage;
@end

@implementation LiuXSlider


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    [super drawRect:rect];
//}

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titleArray firstAndLastTitles:(NSArray *)firstAndLastTitles defaultIndex:(CGFloat)defaultIndex sliderImage:(UIImage *)sliderImage bgImage:(UIImage *)bgImage coverImage:(UIImage *)coverImage
{
    if (self  = [super initWithFrame:frame]) {
        _pointX=0;
        _sectionIndex=0;
        
//        self.backgroundColor=[UIColor colorWithWhite:.6 alpha:.1];
        self.backgroundColor=[UIColor clearColor];
        
        //userInteractionEnabled=YES;代表当前视图可交互，该视图不响应父视图手势
        //UIView的userInteractionEnabled默认是YES，UIImageView默认是NO
        _defaultView=[[UIImageView alloc] initWithFrame:CGRectMake(CenterImage_W/2, LiuXSliderLine_Y, LiuXSlideWidth-CenterImage_W, LiuXSLiderLine_H)];
        _defaultView.backgroundColor = [UIColor colorWithPatternImage:bgImage];
        _defaultView.layer.cornerRadius=LiuXSLiderLine_H/2;
        _defaultView.userInteractionEnabled=NO;
        [self addSubview:_defaultView];
    //修改视图
        
        _selectView=[[UIImageView alloc] initWithFrame:CGRectMake(CenterImage_W/2, LiuXSliderLine_Y, LiuXSlideWidth-CenterImage_W, LiuXSLiderLine_H)];
        _selectView.backgroundColor = [UIColor colorWithPatternImage:coverImage];
        _selectView.layer.cornerRadius=LiuXSLiderLine_H/2;
        _selectView.userInteractionEnabled=NO;
        [self addSubview:_selectView];
        
        _centerImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CenterImage_W*.7, CenterImage_W*.7)];
        _centerImage.center=CGPointMake(0, CenterImage_Y);
        _centerImage.userInteractionEnabled=NO;
        _centerImage.alpha=.5;
        [self addSubview:_centerImage];
        
        _selectLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
        _selectLab.textColor=[UIColor blackColor];
        _selectLab.font=[UIFont systemFontOfSize:14];
        _selectLab.textAlignment=1;
        [self addSubview:_selectLab];
        
        self.titleArray=titleArray;
        self.defaultIndx=defaultIndex;
        self.firstAndLastTitles=firstAndLastTitles;
        self.sliderImage=sliderImage;
    }
    return self;
}


-(void)setDefaultIndx:(CGFloat)defaultIndx{
    CGFloat withPress=defaultIndx/(_titleArray.count-1);
    //设置默认位置
    CGRect rect=[_selectView frame];
    rect.size.width = withPress*LiuXSliderLine_W;
    _selectView.frame=rect;
    
    _pointX=withPress*LiuXSliderLine_W;
    _sectionIndex=defaultIndx;
}

-(void)setTitleArray:(NSArray *)titleArray{
    _titleArray=titleArray;
    _sectionLength=(LiuXSliderLine_W/(titleArray.count-1));
    //NSLog(@"(%lu),(%f),(%f)",(unsigned long)titleArray.count,LiuXSliderLine_W,_sectionLength);
}

-(void)setFirstAndLastTitles:(NSArray *)firstAndLastTitles{
    _leftImage=[[UIImageView alloc] initWithFrame:CGRectMake(-22, 12, 40, 40)];
    _leftImage.image = [UIImage imageNamed:@"ic_fire_lite"];
    [self addSubview:_leftImage];
    
    _rightImage=[[UIImageView alloc] initWithFrame:CGRectMake(LiuXSlideWidth-11, 12, 40, 40)];
    _rightImage.image = [UIImage imageNamed:@"ic_fire_big"];
    [self addSubview:_rightImage];
    
    _leftLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 42, 40, 20)];
    _leftLabel.text = firstAndLastTitles[0];
    _leftLabel.font = [UIFont systemFontOfSize:13];
    _leftLabel.hidden = YES;
    [self addSubview:_leftLabel];
    
    _rightLabel=[[UILabel alloc] initWithFrame:CGRectMake(LiuXSlideWidth-30, 42, 40, 20)];
    _rightLabel.text = firstAndLastTitles[1];
    _rightLabel.font = [UIFont systemFontOfSize:13];
    _rightLabel.hidden = YES;
    [self addSubview:_rightLabel];
}

-(void)setSliderImage:(UIImage *)sliderImage{
    _centerImage.image=sliderImage;
    [self refreshSlider];
}


#pragma mark ---UIColor Touchu
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self changePointX:touch];
    _pointX=_sectionIndex*(_sectionLength);
    [self refreshSlider];
    [self labelEnlargeAnimation];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self changePointX:touch];
    [self refreshSlider];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self changePointX:touch];
    _pointX=_sectionIndex*(_sectionLength);
    if (self.block) {
        self.block((int)_sectionIndex);
    }
    [self refreshSlider];
    [self labelLessenAnimation];
    
}

-(void)changePointX:(UITouch *)touch{
    CGPoint point = [touch locationInView:self];
    _pointX=point.x;
    if (point.x<0) {
        _pointX=CenterImage_W/2;
    }else if (point.x>LiuXSliderLine_W){
        _pointX=LiuXSliderLine_W+CenterImage_W/2;
    }
    //四舍五入计算选择的节点
    _sectionIndex=(int)roundf(_pointX/_sectionLength);
   
}

-(void)refreshSlider{
    _pointX=_pointX+CenterImage_W/2;
    _centerImage.center=CGPointMake(_pointX, CenterImage_Y);
    CGRect rect = [_selectView frame];
    rect.size.width=_pointX-CenterImage_W/2;
    _selectView.frame=rect;
    _selectLab.text=[NSString stringWithFormat:@"%@",_titleArray[_sectionIndex]];
    _selectLab.frame = CGRectMake(LiuXSlideWidth/2-50, 0, 100, 20);
    
}

-(void)labelEnlargeAnimation{
    [UIView animateWithDuration:.1 animations:^{
        [_selectLab.layer setValue:@(1.4) forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)labelLessenAnimation{
    [UIView animateWithDuration:.1 animations:^{
        [_selectLab.layer setValue:@(1.0) forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        
    }];
}

@end
