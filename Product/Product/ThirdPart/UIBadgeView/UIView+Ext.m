//
//  UIView+Ext.m
//  LoadNibViewDemo
//
//  Created by Haven on 7/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "UIView+Ext.h"
#import "UIBadgeView.h"
#define kTagBadgeView  1000
#define kTagRedPointView    1001
@implementation UIView (Ext)
+(id)loadFromNib {
    return [self loadFromNibNamed:NSStringFromClass(self)];
}

+(id)loadFromNibNamed:(NSString*) nibName {
    NSArray* views=[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    return views.firstObject;
}

+ (id)loadFromNibNoOwner {
    UIView *result = nil;
    NSArray* elements = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner: nil options: nil];
    for (id anObject in elements) {
        if ([anObject isKindOfClass:[self class]]) {
            result = anObject;
            break;
        }
    }
    return result;
}
- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}
- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size.width = size.width;
    frame.size.height = size.height;
    self.frame = frame;
}
- (void)addBadgeTip:(NSString *)badgeValue withCenterPosition:(CGPoint)center{
    if (!badgeValue || !badgeValue.length) {
        [self removeBadgeTips];
    }else{
        UIView *badgeV = [self viewWithTag:kTagBadgeView];
        if (badgeV && [badgeV isKindOfClass:[UIBadgeView class]]) {
            [(UIBadgeView *)badgeV setBadgeValue:badgeValue];
            badgeV.hidden = NO;
        }else{
            badgeV = [UIBadgeView viewWithBadgeTip:badgeValue];
            badgeV.tag = kTagBadgeView;
            [self addSubview:badgeV];
        }
        
        CGSize badgeSize = badgeV.frame.size;
        CGFloat offset = 0.0;
        [badgeV setCenter:CGPointMake(center.x + (offset+badgeSize.width/2),
                                      (center.y - offset + badgeSize.height/2))];
        
//        [badgeV setCenter:center];
    }
}
- (void)addBadgeTip:(NSString *)badgeValue{
    if (!badgeValue || !badgeValue.length) {
        [self removeBadgeTips];
    }else{
        UIView *badgeV = [self viewWithTag:kTagBadgeView];
        if (badgeV && [badgeV isKindOfClass:[UIBadgeView class]]) {
            [(UIBadgeView *)badgeV setBadgeValue:badgeValue];
            badgeV.hidden = NO;
        }else{
            badgeV = [UIBadgeView viewWithBadgeTip:badgeValue];
            badgeV.tag = kTagBadgeView;
            [self addSubview:badgeV];
        }
        CGSize badgeSize = badgeV.frame.size;
        CGSize selfSize = self.frame.size;
        CGFloat offset = 0.0;
        [badgeV setCenter:CGPointMake(selfSize.width- (offset+badgeSize.width/2),
                                      (offset +badgeSize.height/2))];
    }
}
- (void)removeBadgeTips{
    NSArray *subViews =[self subviews];
    if (subViews && [subViews count] > 0) {
        for (UIView *aView in subViews) {
            if (aView.tag == kTagBadgeView && [aView isKindOfClass:[UIBadgeView class]]) {
                aView.hidden = YES;
            }
        }
    }
}
-(void)addRedPoint{
    [self addRedPoint:2];
}
-(void)addRedPoint:(CGFloat)offset{
    UIView *badgeV = [self viewWithTag:kTagBadgeView];
    if (badgeV) {
        [badgeV setHidden:NO];
    }else{
        badgeV = [[UIView alloc] init];
        [badgeV setSize:CGSizeMake(12, 12)];
        badgeV.layer.cornerRadius= (badgeV.frame.size.width / 2.0f);
        [badgeV setBackgroundColor:[UIColor redColor]];
        badgeV.tag = kTagRedPointView;
        [self addSubview:badgeV];
    }
    CGSize badgeSize = badgeV.frame.size;
    CGSize selfSize = self.frame.size;
    [badgeV setCenter:CGPointMake(selfSize.width- (offset+badgeSize.width/2),
                                  (offset +badgeSize.height/2))];


//    [badgeV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self);
//        make.right.equalTo(self);
//        make.width.and.height.mas_equalTo(7);
//    }];
}
-(void)removeRedPoint{
    NSArray *subViews =[self subviews];
    if (subViews && [subViews count] > 0) {
        for (UIView *aView in subViews) {
            if (aView.tag == kTagRedPointView ) {
                aView.hidden = YES;
            }
        }
    }
}

@end
