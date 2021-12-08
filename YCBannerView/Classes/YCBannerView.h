//
//  YCBannerView.h
//  YCBannerView_Example
//
//  Created by 任义春 on 2021/12/7.
//  Copyright © 2021 renyichun. All rights reserved.
// 轮播图视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YCBannerView,YCBannerCell;

/// 代理协议
@protocol YCBannerViewDelegate <NSObject>

@optional

/**
 轮播图点击事件
 @param bannerView 轮播图
 @param index 点击Cell对应的索引
 */
- (void)yc_bannerView:(YCBannerView *)bannerView didSelectedIndex:(NSUInteger)index;

/**
 轮播图当前显示Cell的索引,用于打点等操作
 @param bannerView 轮播图
 @param index Cell对应的索引
 */
- (void)yc_bannerView:(YCBannerView *)bannerView showCurCellIndex:(NSUInteger)index;

/**
 轮播图更新Cell
 @param bannerView 轮播图
 @param bannerCell 轮播图Cell
 @param index Cell对应的索引
 */
- (void)yc_bannerView:(YCBannerView *)bannerView updateDisplayCell:(YCBannerCell *)bannerCell cellForIndex:(NSUInteger)index;

/**
 轮播图滚动比例回调
 @param bannerView 轮播图
 @param offsetScale 轮播图滚动偏移量比例
 @param curIndex 当前索引
 @param isRight 是否向右方向
 */
- (void)yc_bannerView:(YCBannerView *)bannerView scrollOffsetScale:(CGFloat )offsetScale curIndex:(NSUInteger)curIndex scrollDirection:(BOOL )isRight;

@end


/// 数据源协议
@protocol YCBannerViewDataSource <NSObject>

@optional

/**
 *  一共有多少个cell
 */
- (NSInteger)yc_numberOfRowsInBannerView:(YCBannerView *)bannerView;

/**
 对应的Cell样式
 @param bannerView 轮播图
 */
- (YCBannerCell *)yc_createCellInBannerView:(YCBannerView *)bannerView;

@end


@interface YCBannerView : UIView

/// 代理属性
@property (nonatomic, weak) id<YCBannerViewDelegate> delegate;
/// 数据源代理
@property (nonatomic, weak) id<YCBannerViewDataSource> dataSource;
/// 设置指引器位置 : 默认 UIEdgeInsetsMake(0, 0, 10, 10)
@property (nonatomic, assign) UIEdgeInsets edgeInsetsPageCtrl;
/// 定时器间隔时间 : 默认 3.0f
@property (nonatomic, assign) CGFloat timeInterval;

/**
 初始化轮播图控件
 
 @param delegate 指定代理
 @param dataSource 指定数组源代理
 @param frame 指定初始化frame
 */
- (instancetype)initWithBannerViewDelegate:(id<YCBannerViewDelegate>)delegate
                               dataScource:(id<YCBannerViewDataSource>)dataSource
                                     frame:(CGRect)frame;

/// 刷新轮播图
- (void)reloadBannerView;
/// 更新pageCtrl配置项
- (void)updatePageCtrlConfig:(void(^)(UIPageControl *pageCtrl))pageCtrlConfigBlcok;

@end

NS_ASSUME_NONNULL_END
