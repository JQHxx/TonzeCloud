//
// Created by zorro on 15/12/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TTGTextTagCollectionView;

@protocol TTGTextTagCollectionViewDelegate <NSObject>
@optional
- (void)textTagCollectionView:(TTGTextTagCollectionView *)textTagCollectionView didTapTag:(NSString *)tagText atIndex:(NSUInteger)index selected:(BOOL)selected;

- (void)textTagCollectionView:(TTGTextTagCollectionView *)textTagCollectionView updateContentHeight:(CGFloat)newContentHeight;
@end

@interface TTGTextTagCollectionView : UIView
@property (weak, nonatomic) id <TTGTextTagCollectionViewDelegate> delegate;
@property (assign, nonatomic) BOOL enableTagSelection;
/**
 *  是否单选
 */
@property (assign, nonatomic) BOOL radioTag;


// Text
@property (strong, nonatomic) UIFont *tagTextFont;
@property (strong, nonatomic) UIColor *tagTextColor;
@property (strong, nonatomic) UIColor *tagSelectedTextColor;

// Extra space
@property (assign, nonatomic) CGSize extraSpace;

// Background color
@property (strong, nonatomic) UIColor *tagBackgroundColor;
@property (strong, nonatomic) UIColor *tagSelectedBackgroundColor;

// Corner radius
@property (assign, nonatomic) CGFloat tagCornerRadius;
@property (assign, nonatomic) CGFloat tagSelectedCornerRadius;

// Border
@property (assign, nonatomic) CGFloat tagBorderWidth;
@property (assign, nonatomic) CGFloat tagSelectedBorderWidth;
@property (strong, nonatomic) UIColor *tagBorderColor;
@property (strong, nonatomic) UIColor *tagSelectedBorderColor;

// Space
@property (assign, nonatomic) CGFloat horizontalSpacing;
@property (assign, nonatomic) CGFloat verticalSpacing;

@property (assign, nonatomic) BOOL isLongPress;

// Content heigth
@property (assign, nonatomic, readonly) CGFloat contentHeight;

// 长按删除功能
//@property (copy, nonatomic)  ClickObjAction deleteAction;

- (void)reload;

- (void)addTag:(NSString *)tag;

- (void)addTags:(NSArray <NSString *> *)tags;

- (void)addObjTags:(NSMutableArray *)tags;

- (void)removeTag:(NSString *)tag;

- (void)removeTagAtIndex:(NSUInteger)index;

- (void)removeAllTags;

- (void)setTagAtIndex:(NSUInteger)index selected:(BOOL)selected;

/**
 *  重置样式
 */
- (void)resetAllTagStyle;

- (NSArray <NSString *> *)allTags;

- (NSArray <NSString *> *)allSelectedTags;

- (NSArray <NSString *> *)allNotSelectedTags;

@end