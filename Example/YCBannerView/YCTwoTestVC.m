//
//  YCTwoTestVC.m
//  YCBannerView_Example
//
//  Created by 任义春 on 2021/12/8.
//  Copyright © 2021 renyichun. All rights reserved.
//

#import "YCTwoTestVC.h"

#import "YCBannerView.h"
#import "YCBannerCell.h"
#import <Masonry.h>

#define kColor_RGB_A(rgb, a) [UIColor colorWithRed:((float) ((rgb & 0xFF0000) >> 16)) / 255.0 \
                                               green:((float) ((rgb & 0xFF00) >> 8)) / 255.0    \
                                                blue:((float) (rgb & 0xFF)) / 255.0             \
                                               alpha:(a) / 1.0]
#define kColor_RGB(rgb) kColor_RGB_A(rgb,1.0)

#define kDefaultColor (kColor_RGB(0xFFC848))


@interface YCTwoTestVC ()<YCBannerViewDelegate,YCBannerViewDataSource>

@property (nonatomic, strong) YCBannerView *bannerView;
@property (nonatomic, strong) NSMutableArray *mArrayData;
@property (nonatomic, strong) NSMutableArray *mArrayColor;

@end

@implementation YCTwoTestVC

#pragma mark - 初始化

- (void)dealloc {
    NSLog(@"-----%s",__func__);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultColor;
    // 添加子视图和数据
    [self addSubViews];
    [self addTestData];
    // 刷新
    [self.bannerView reloadBannerView];
   
}

- (void)addSubViews {
    [self.view addSubview:self.bannerView];
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(100);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(300);
    }];
}

- (void)addTestData {
    [self.mArrayData removeAllObjects];
    [self.mArrayColor removeAllObjects];
    NSArray *arrayColor = @[@"#FFCB00",
                            @"#CCFFFF",
                            @"#CCFF33",
                            @"#CC9900",
                            @"#CC3366",
                            @"#CC0000"];
    for (NSInteger i = 0; i < arrayColor.count; i++) {
        NSString *str = [NSString stringWithFormat:@"第%@个",@(i)];
        [self.mArrayData addObject:str];
        [self.mArrayColor addObject:arrayColor[i]];
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
    
    bannerCell.backgroundColor = UIColor.cyanColor;
}

/**
 轮播图点击事件
 @param bannerView 轮播图
 @param index 点击Cell对应的索引
 */
- (void)yc_bannerView:(YCBannerView *)bannerView didSelectedIndex:(NSUInteger)index {
    NSLog(@"Ryc_____ 点击了第%@个",@(index));
}

/**
 轮播图滚动比例回调
 @param bannerView 轮播图
 @param offsetScale 轮播图滚动偏移量比例
 @param curIndex 当前索引
 @param isRight 是否向右方向
 */
- (void)yc_bannerView:(YCBannerView *)bannerView scrollOffsetScale:(CGFloat )offsetScale curIndex:(NSUInteger)curIndex scrollDirection:(BOOL )isRight {
        
    // 如果没有数据，直接返回
    if (self.mArrayData.count <= 0) {
        return;
    }
    
    UIColor *backgroundColor = [self p_getBackgroundColorWithScrollOffsetScale:offsetScale curIndex:curIndex scrollDirection:isRight];
    self.view.backgroundColor = backgroundColor;
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
    YCBannerCell *cell = [[YCBannerCell alloc] init];
    cell.backgroundColor = [self p_randomColor];
    return cell;
}

#pragma mark - 对外方法

#pragma mark - 私有方法



/// 根据已知条件，获取背景色
- (UIColor *)p_getBackgroundColorWithScrollOffsetScale:(CGFloat )offsetScale curIndex:(NSUInteger)curIndex scrollDirection:(BOOL )isRight {
    
    /// 背景色，分界变化临界值
    CGFloat floatBoundary = 0.3;
    UIColor *colorBg = kDefaultColor;
    /// 显示新的背景色
    if (offsetScale >= floatBoundary)
    {
        // 临时索引位置：向右滑动的时候，应该取上一个的颜色位置，向左移动时候，取后一个
        NSInteger intTemIndex = [self p_getTemporaryIndexWithRightDirection:isRight
                                                               currentIndex:curIndex];
        
        /// 十六进制颜色
        NSString *stringColor = [self p_getShowColorStringWithIndex:intTemIndex];
        if (stringColor.length > 0)
        {
            /// 颜色有值，才去设置
            CGFloat floatTemAlpha = 0.1;
            floatTemAlpha = floatTemAlpha + offsetScale;
            colorBg = [self p_colorWithHexString:stringColor
                                               colorAlpha:floatTemAlpha];
        }
    }
    else if (offsetScale < floatBoundary && offsetScale > 0)
    {
        /// 显示旧的背景色
        /// 刚开始移动时，使自己本来的颜色，变浅色
        NSString *stringColor = [self p_getShowColorStringWithIndex:curIndex];

        if (stringColor.length > 0)
        {
            /// 颜色有值，才去设置
            CGFloat floatTemAlpha = 0.9;
            floatTemAlpha = floatTemAlpha - offsetScale;
            colorBg = [self p_colorWithHexString:stringColor
                                               colorAlpha:floatTemAlpha];
            
        }
    }
    else
    {
        /// 设置停止滚动时，正常的颜色值
        NSString *stringColor = [self p_getShowColorStringWithIndex:curIndex];
        if (stringColor.length > 0)
        {
            /// 颜色有值，才去设置
            colorBg = [self p_colorWithHexString:stringColor
                                               colorAlpha:1];
        }
    }
    return colorBg;
}

/// 根据轮播图的滑动方向确认，取对应的上一个，或下一个轮播图索引，目的是为了做颜色渐变
- (NSInteger)p_getTemporaryIndexWithRightDirection:(BOOL)isRight
                                      currentIndex:(NSInteger)curIndex
{
    NSInteger intTemIndex = 0;
    if (isRight) {
        /// 当前向右滑动，应该取上一个颜色值
        if (curIndex == 0) {
            /// 当为第一个时，取最后一个
            intTemIndex = (self.mArrayColor.count - 1);
        }
        else {
            /// 正常取值
            intTemIndex = curIndex - 1;
        }
    }
    else {
        /// 当前向左滑动，应该取下一个颜色值
        if (curIndex == (self.mArrayColor.count - 1)) {
            /// 当等于最后一个，应该取第一个
            intTemIndex = 0;
        }
        else {
            /// 正常取值
            intTemIndex = curIndex + 1;
        }
    }
    return intTemIndex;
}

/// 根据索引位置，取相应的颜色
- (NSString *)p_getShowColorStringWithIndex:(NSInteger)index
{
    NSString *stringColor = @"";
    if (self.mArrayColor.count > 0) {
        stringColor = [self.mArrayColor objectAtIndex:index];
        /// 去除空格
        stringColor = [stringColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return stringColor;
}


#pragma mark - 颜色相关
// 随机颜色
- (UIColor *)p_randomColor {
    NSInteger aRedValue = arc4random() % 255;
    NSInteger aGreenValue = arc4random() % 255;
    NSInteger aBlueValue = arc4random() % 255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue / 255.0f green:aGreenValue / 255.0f blue:aBlueValue / 255.0f alpha:1.0f];
    return randColor;
}

/// 十六进制设置颜色 ：
- (UIColor *)p_colorWithHexString:(NSString *)aStringRGB
                       colorAlpha:(CGFloat)aFloatAlpha
{
    if (aStringRGB.length <= 0)
    {
        /// 默认返回 默认值黄色
        return kDefaultColor;
    }

    /// 去掉空格，并全改为大写形式，便于下面的计算
    NSString *stringColor = [[aStringRGB stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString];

    /// 字符串必须大于6位，否则默认返回默认黄色
    if ([stringColor length] < 6)
    {
        return kDefaultColor;
    }

    ///  strip 0X if it appears
    if ([stringColor hasPrefix:@"0X"])
    {
        stringColor = [stringColor substringFromIndex:2];
    }
    else if ([stringColor hasPrefix:@"#"])
    {
        stringColor = [stringColor substringFromIndex:1];
    }

    /// 剩下的位数一定是6位，否则默认返回默认黄色
    if ([stringColor length] != 6)
    {
        return kDefaultColor;
    }

    /// 正则检测颜色值是否有效
    BOOL isValid = [self p_cheackHexColor:stringColor];

    if (!isValid)
    {
        return kDefaultColor;
    }

    /// 分别获取R、G、B的值
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *stringR = [stringColor substringWithRange:range];

    range.location = 2;
    NSString *stringG = [stringColor substringWithRange:range];

    range.location = 4;
    NSString *stringB = [stringColor substringWithRange:range];

    /// Scan values
    unsigned int uIntR;
    unsigned int uIntG;
    unsigned int uIntB;
    [[NSScanner scannerWithString:stringR] scanHexInt:&uIntR];
    [[NSScanner scannerWithString:stringG] scanHexInt:&uIntG];
    [[NSScanner scannerWithString:stringB] scanHexInt:&uIntB];

    return [UIColor colorWithRed:((float) uIntR / 255.0f)
                           green:((float) uIntG / 255.0f)
                            blue:((float) uIntB / 255.0f)
                           alpha:aFloatAlpha];
}

/// 检测颜色是否符合
- (BOOL)p_cheackHexColor:(NSString *)aStringHex
{
    NSString *stringHexRegex = @"^[0-9A-F]{6}$";
    NSPredicate *predicateHex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringHexRegex];
    return [predicateHex evaluateWithObject:aStringHex];
}

#pragma mark - set/get

#pragma mark - 基类方法

- (NSMutableArray *)mArrayData {
    if (!_mArrayData) {
        _mArrayData = [NSMutableArray array];
    }
    return _mArrayData;
}

- (NSMutableArray *)mArrayColor {
    if (!_mArrayColor) {
        _mArrayColor = [NSMutableArray array];
    }
    return _mArrayColor;
}

- (YCBannerView *)bannerView {
    if (!_bannerView) {
        _bannerView = [[YCBannerView alloc] initWithBannerViewDelegate:self dataScource:self frame:CGRectMake(0, 100, self.view.bounds.size.width, 300)];
        _bannerView.backgroundColor = [UIColor cyanColor];
    }
    return _bannerView;
}

@end
