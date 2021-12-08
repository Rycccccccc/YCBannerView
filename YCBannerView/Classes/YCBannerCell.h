//
//  YCBannerCell.h
//  YCBannerView_Example
//
//  Created by 任义春 on 2021/12/7.
//  Copyright © 2021 renyichun. All rights reserved.
//  轮播图cell

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCBannerCell : UIView

/// 初始化配置
- (void)initConfig;
/// 设置UI
- (void)setupUI;
/// cell 赋值
- (void)setObject:(id)aObject;
/// 清除数据
- (void)clearData;

@end

NS_ASSUME_NONNULL_END
