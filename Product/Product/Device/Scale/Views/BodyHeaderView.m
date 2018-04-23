//
//  BodyHeaderView.m
//  Product
//
//  Created by vision on 17/5/4.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BodyHeaderView.h"
#import "BodySectionModel.h"
#import "ScaleHelper.h"

@interface BodyHeaderView ()

@property (nonatomic, strong) UIImageView *bodyImageView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *valueLabel;
@property (nonatomic, strong) UILabel     *standardLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;


@end

@implementation BodyHeaderView


-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor=[UIColor whiteColor];
        
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        
        self.bodyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add私享壶"]];
        self.bodyImageView.frame = CGRectMake(5, 5, 34, 34);
        [self.contentView addSubview:self.bodyImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 100, 44)];
        self.titleLabel.textColor=[UIColor colorWithHexString:@"#626262"];
        self.titleLabel.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.titleLabel];
        
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(w/2-40, 0, 80, 44)];
        self.valueLabel.textColor = [UIColor colorWithHexString:@"#626262"];
        self.valueLabel.textAlignment=NSTextAlignmentCenter;
        self.valueLabel.font=[UIFont systemFontOfSize:16];
        self.valueLabel.text=@"--";
        [self.contentView addSubview:self.valueLabel];
        
        self.standardLabel = [[UILabel alloc] initWithFrame:CGRectMake(w-80, 10, 40, 24)];
        self.standardLabel.textColor = [UIColor whiteColor];
        self.standardLabel.textAlignment=NSTextAlignmentCenter;
        self.standardLabel.font=[UIFont systemFontOfSize:14];
        self.standardLabel.layer.cornerRadius=10;
        self.standardLabel.clipsToBounds=YES;
        [self.contentView addSubview:self.standardLabel];
        self.standardLabel.hidden=YES;
        
        
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"expanded"]];
        self.arrowImageView.frame = CGRectMake(w-25, (44 - 8) / 2, 15,8);
        [self.contentView addSubview:self.arrowImageView];
        self.arrowImageView.hidden=YES;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(onExpand:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, w, 44);
        [self.contentView addSubview:button];
        
    }
    return self;
}

-(void)setSectionModel:(BodySectionModel *)sectionModel{
    if (_sectionModel != sectionModel) {
        _sectionModel = sectionModel;
    }
    
    self.bodyImageView.image=[UIImage imageNamed:sectionModel.imageName];
    self.titleLabel.text = sectionModel.sectionTitle;
    self.valueLabel.text = sectionModel.value;
    if ([sectionModel.value isEqualToString:@"--"]) {
        self.standardLabel.hidden=YES;
        self.arrowImageView.hidden=YES;
    }else{
        self.standardLabel.hidden=NO;
        self.arrowImageView.hidden=NO;
        
        self.standardLabel.text = sectionModel.standard;
        
        CGFloat stanrdW=[self.standardLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 24) withTextFont:self.standardLabel.font].width;
        self.standardLabel.frame=CGRectMake(kScreenWidth-stanrdW-50, 10, stanrdW+10, 24);
        
        self.standardLabel.backgroundColor=[[ScaleHelper sharedScaleHelper] getResultColorWithResult:sectionModel.standard key:sectionModel.keyStr];
        if (self.sectionModel.isExpanded) {
            self.arrowImageView.transform = CGAffineTransformIdentity;
        } else {
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }
}

- (void)onExpand:(UIButton *)sender {
    self.sectionModel.isExpanded = !self.sectionModel.isExpanded;
    
    [UIView animateWithDuration:0.25 animations:^{
        if (self.sectionModel.isExpanded) {
            self.arrowImageView.transform = CGAffineTransformIdentity;
        } else {
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }];
    
    if (self.expandCallback) {
        self.expandCallback(self.sectionModel.isExpanded);
    }
}

@end
