//
//  UIView+Ext.h
//  LoadNibViewDemo
//
//  Created by Haven on 7/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Ext)
+ (id)loadFromNib;
+ (id)loadFromNibNamed:(NSString*) nibName;
+ (id)loadFromNibNoOwner;
- (void)setY:(CGFloat)y;
- (void)setX:(CGFloat)x;
- (void)setOrigin:(CGPoint)origin;
- (void)setHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width;
- (void)setSize:(CGSize)size;
- (void)addBadgeTip:(NSString *)badgeValue withCenterPosition:(CGPoint)center;
- (void)addBadgeTip:(NSString *)badgeValue;
- (void)removeBadgeTips;
-(void)addRedPoint;
-(void)addRedPoint:(CGFloat)offset;
-(void)removeRedPoint;
@end
