//
//  HorizontalFlowLayout.m
//  Product
//
//  Created by vision on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "HorizontalFlowLayout.h"

static  CGFloat const MyItemWH = 60;

@implementation HorizontalFlowLayout

-(instancetype)init{
    self=[super init];
    if (self) {
        
    }
    return self;
}

/**
 *  只要显示的边界发生改变就重新布局:
 内部会重新调用prepareLayout和layoutAttributesForElementsInRect方法获得所有cell的布局属性
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    
    
    CGRect oldBounds = self.collectionView.bounds;
    
    if (CGRectGetHeight(newBounds) == CGRectGetHeight(oldBounds)) {
        
        return YES;
        
    }
    
    return NO;
    
}

/**
 *  用来设置collectionView停止滚动那一刻的位置
 *
 *  @param proposedContentOffset 原本collectionView停止滚动那一刻的位置
 *  @param velocity              滚动速度
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    
    
    // 1.计算出scrollView最后会停留的范围
    CGRect lastRect;
    lastRect.origin = proposedContentOffset;
    lastRect.size = self.collectionView.frame.size;
    
    // 计算屏幕最中间的x
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    // 2.取出这个范围内的所有属性
    NSArray *array = [self layoutAttributesForElementsInRect:lastRect];
    
    // 3.遍历所有属性
    CGFloat adjustOffsetX = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (ABS(attrs.center.x - centerX) < ABS(adjustOffsetX)) {
            adjustOffsetX = attrs.center.x - centerX;
        }
    }
    if (proposedContentOffset.x + adjustOffsetX<0) {
        return CGPointMake(0, proposedContentOffset.y);
    }
    
    return CGPointMake(proposedContentOffset.x + adjustOffsetX, proposedContentOffset.y);
    
    
}



//初始化
-(void)prepareLayout
{
    
    [super prepareLayout];
    self.itemSize=CGSizeMake(SCREEN_WIDTH/320.0* MyItemWH,SCREEN_WIDTH/320.0* MyItemWH);
    CGFloat inset = (self.collectionView.frame.size.width - SCREEN_WIDTH/320.0*MyItemWH) * 0.5;
    self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
    // 设置水平滚动
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = SCREEN_WIDTH/320.0*MyItemWH * 0.7;
    
    // 每一个cell(item)都有自己的UICollectionViewLayoutAttributes
    // 每一个indexPath都有自己的UICollectionViewLayoutAttributes
    
}


/** 有效距离:当item的中间x距离屏幕的中间x在HMActiveDistance以内,才会开始放大, 其它情况都是缩小 */
static CGFloat const MyActiveDistance = 180;
/** 缩放因素: 值越大, item就会越大 */
static CGFloat const MyScaleFactor = 0.6;

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    // 0.计算可见的矩形框
    CGRect visiableRect;
    visiableRect.size = self.collectionView.frame.size;
    visiableRect.origin = self.collectionView.contentOffset;
    
    // 1.取得默认的cell的UICollectionViewLayoutAttributes
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    // 计算屏幕最中间的x
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    float activeDistance=SCREEN_WIDTH/320.0*MyActiveDistance;
    float scaleFatctor=SCREEN_WIDTH/320.0*MyScaleFactor;
    
    // 2.遍历所有的布局属性
    for (UICollectionViewLayoutAttributes *attrs in array) {
        // 如果不在屏幕上,直接跳过
        if (!CGRectIntersectsRect(visiableRect, attrs.frame)) continue;
        
        // 每一个item的中点x
        CGFloat itemCenterX = attrs.center.x;
        
        // 差距越小, 缩放比例越大
        // 根据跟屏幕最中间的距离计算缩放比例
        CGFloat scale = 1 + scaleFatctor * (1 - (ABS(itemCenterX - centerX) / activeDistance));
        attrs.transform = CGAffineTransformMakeScale(scale, scale);
        
        //改变透明度
        CGFloat resetAlpha=scaleFatctor * (1 - (ABS(itemCenterX - centerX) / activeDistance))*1.66;
        attrs.alpha=resetAlpha;
        
    }
    
    return array;
}

@end
