//
//  YCOneTestVC.m
//  YCBannerView_Example
//
//  Created by 任义春 on 2021/12/8.
//  Copyright © 2021 renyichun. All rights reserved.
//

#import "YCOneTestVC.h"

#import "YCBannerView.h"
#import "YCHomeBannerCell.h"

#import <Masonry.h>

@interface YCOneTestVC ()<YCBannerViewDelegate,YCBannerViewDataSource>

@property (nonatomic, strong) YCBannerView *bannerView;
@property (nonatomic, strong) NSMutableArray *mArrayData;

@end

@implementation YCOneTestVC

#pragma mark - 初始化

- (void)dealloc {
    NSLog(@"-----%s",__func__);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 添加子视图和数据
    [self addSubViews];
    [self addTestData];
    // 刷新
    [self.bannerView reloadBannerView];
   
}

- (void)addSubViews {
    [self.view addSubview:self.bannerView];
}

- (void)addTestData {
    [self.mArrayData removeAllObjects];
    for (NSInteger i = 0; i < 7; i++) {
        NSString *str = [NSString stringWithFormat:@"img_00%@",@(i+1)];
        [self.mArrayData addObject:str];
    }

}

#pragma mark - 点击事件


#pragma mark - 代理方法

#pragma mark - YCBannerViewDelegate

/**
 轮播图更新Cell
 @param bannerView 轮播图
 @param bannerCell 轮播图Cell
 @param index Cell对应的索引
 */
- (void)yc_bannerView:(YCBannerView *)bannerView updateDisplayCell:(YCBannerCell *)bannerCell cellForIndex:(NSUInteger)index {
    if (index >= self.mArrayData.count) {
        return;
    }
    [bannerCell setObject:self.mArrayData[index]];
}

/**
 轮播图点击事件
 @param bannerView 轮播图
 @param index 点击Cell对应的索引
 */
- (void)yc_bannerView:(YCBannerView *)bannerView didSelectedIndex:(NSUInteger)index {
    NSLog(@"Ryc_____ 点击了第%@个",@(index));
}

#pragma mark - YCBannerViewDataSource

/**
 *  一共有多少个cell
 */
- (NSInteger)yc_numberOfRowsInBannerView:(YCBannerView *)bannerView {
    return self.mArrayData.count;
}

/**
 对应的Cell样式
 @param bannerView 轮播图
 */
- (YCBannerCell *)yc_createCellInBannerView:(YCBannerView *)bannerView {
    YCHomeBannerCell *cell = [[YCHomeBannerCell alloc] init];
    cell.backgroundColor = [self p_randomColor];
    return cell;
}

#pragma mark - 对外方法

#pragma mark - 私有方法

// 随机颜色
- (UIColor *)p_randomColor {
    NSInteger aRedValue = arc4random() % 255;
    NSInteger aGreenValue = arc4random() % 255;
    NSInteger aBlueValue = arc4random() % 255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue / 255.0f green:aGreenValue / 255.0f blue:aBlueValue / 255.0f alpha:1.0f];
    return randColor;
}

#pragma mark - set/get

#pragma mark - 基类方法

- (NSMutableArray *)mArrayData {
    if (!_mArrayData) {
        _mArrayData = [NSMutableArray array];
    }
    return _mArrayData;
}

- (YCBannerView *)bannerView {
    if (!_bannerView) {
        _bannerView = [[YCBannerView alloc] initWithBannerViewDelegate:self dataScource:self frame:CGRectMake(0, 100, self.view.bounds.size.width, 300)];
        _bannerView.backgroundColor = [UIColor cyanColor];
        
        [_bannerView updatePageCtrlConfig:^(UIPageControl * _Nonnull pageCtrl) {
            pageCtrl.currentPageIndicatorTintColor = UIColor.redColor;
            pageCtrl.pageIndicatorTintColor = UIColor.cyanColor;
        }];
    }
    return _bannerView;
}


@end
