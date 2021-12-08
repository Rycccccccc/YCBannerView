//
//  YCBannerView.m
//  YCBannerView_Example
//
//  Created by 任义春 on 2021/12/7.
//  Copyright © 2021 renyichun. All rights reserved.
//

#import "YCBannerView.h"
#import "YCBannerCell.h"
#import "Masonry.h"

#define kScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
/// 默认总的 image 个数
#define kDefaultTotalImgCount (3)
/// 轮播间隔
#define kLoopDuring (3.0f)
/// 索引默认显示位置
#define kPageCtrl_DefaultEdgeInsets (UIEdgeInsetsMake(0, 10, 10, 10))

#pragma mark -
#pragma mark - 定时器协议类
@interface YCProxy : NSProxy
@property (nonatomic, weak) id target;
+ (instancetype)proxyWithTarget:(id)target;
@end

@implementation YCProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}
+ (instancetype)proxyWithTarget:(id)target {
    YCProxy *proxy = [[YCProxy alloc] initWithTarget:target];
    return proxy;
}
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.target;
}

@end

#pragma mark -
#pragma mark - 轮播图类
@interface YCBannerView()<UIScrollViewDelegate>

/// 底部滚动视图
@property (nonatomic, strong) UIScrollView *scrollViewContent;
/// 指引器
@property (nonatomic, strong) UIPageControl *pageCtrlCircle;
/// 保存轮播图Cell的数组
@property (nonatomic, strong) NSMutableArray *mArrayCellViews;
/// 定时器
@property (nonatomic, strong) NSTimer *timer;
/// 为了第一次不走改变点点的方法 （做个标记）
@property (nonatomic, assign) BOOL isMoveCircle;


@end

@implementation YCBannerView

#pragma mark - 初始化


/**
 初始化轮播图控件
 
 @param delegate 指定代理
 @param dataSource 指定数组源代理
 @param frame 指定初始化frame
 */
- (instancetype)initWithBannerViewDelegate:(id<YCBannerViewDelegate>)delegate
                                dataScource:(id<YCBannerViewDataSource>)dataSource
                                      frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dataSource = dataSource;
        self.delegate = delegate;
        [self initFields];
        [self createViews];
        [self addViewConstraints];
    }
    return self;
}

- (void)dealloc {
    [self p_stopTimer];
}


/// 初始化变量
- (void)initFields {
    self.edgeInsetsPageCtrl = kPageCtrl_DefaultEdgeInsets;
}

/// 创建子视图
- (void)createViews {
    /// 初始化scrollView
    [self addSubview:self.scrollViewContent];

    /// 循环创建轮播图
    for (NSInteger i = 0; i < kDefaultTotalImgCount; i++) {
        YCBannerCell *cell = [self p_creatBannerCellWithIndex:i];
        [self.mArrayCellViews addObject:cell];
        [self.scrollViewContent addSubview:cell];

        /// 添加单击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(p_handleTap:)];
        [cell addGestureRecognizer:tap];

        /// 添加长按手势（手指放上去，计时停止，即页面不再滑动，手指离开，计时重新开始）
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(p_handleLongPress:)];
        [cell addGestureRecognizer:longPress];
    }

    /// 初始化指引器
    [self addSubview:self.pageCtrlCircle];
}

/// 添加约束
- (void)addViewConstraints {
    /// 滚动内容
    [self.scrollViewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.offset(0);
        make.width.equalTo(self.scrollViewContent.superview.mas_width);
        make.height.equalTo(self.scrollViewContent.superview.mas_height);
    }];


    /// 循环更新轮播图
    for (NSInteger i = 0; i < kDefaultTotalImgCount; i++)
    {
        YCBannerCell *cell = [self.mArrayCellViews objectAtIndex:i];
        CGFloat floatItemX = i * kScreenWidth;
        [cell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(floatItemX);
            make.top.equalTo(cell.superview.mas_top);
            make.width.equalTo(cell.superview.mas_width);
            make.height.equalTo(cell.superview.mas_height);
        }];
    }

    /// 指引器
    CGFloat floatBottom = self.edgeInsetsPageCtrl.bottom;
    CGFloat floatRight = self.edgeInsetsPageCtrl.right;
    CGFloat floatLeft = self.edgeInsetsPageCtrl.left;

    [self.pageCtrlCircle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.pageCtrlCircle.superview).with.offset(-floatBottom);
        make.right.mas_equalTo(self.pageCtrlCircle.superview).with.offset(-floatRight);
        make.left.mas_equalTo(self.pageCtrlCircle.superview).with.offset(floatLeft);
        make.height.mas_equalTo(10);
    }];
}


#pragma mark - 点击事件

#pragma mark - 代理方法

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /// 当轮播图个数超过1时，执行下面的操作。
    NSInteger intTotalCount = [self p_getBannerCellCount];

    /// 当轮播图Cell数量大于1时，才处理滚动和背景渐变
    if (intTotalCount > 1) {
        CGFloat scrollViewW = scrollView.bounds.size.width;
        if (scrollView.contentOffset.x >= 2 * kScreenWidth) {
            [self p_goRight];
        } else if (scrollView.contentOffset.x <= 0) {
            [self p_goLeft];
        }
        /// 当前滚动的x偏移量
        CGFloat offsetX = scrollView.contentOffset.x;
        /// 滚动偏移量占据当前界面的比例
        CGFloat offsetScale = 0;

        BOOL isRight = NO;
        if (offsetX <= scrollViewW) {
            /// 向右滑动
            offsetScale = (scrollViewW - scrollView.contentOffset.x) / scrollViewW * 1.0;
            isRight = YES;
        } else {
            isRight = NO;
            /// 向左滑动
            offsetScale = (scrollView.contentOffset.x - scrollViewW) / scrollViewW * 1.0;
        }
        
        /// 发送代理方法
        [self p_sendDelegateScrollOffsetScale:offsetScale curIndex:self.pageCtrlCircle.currentPage scrollDirection:isRight];
    }
}

/// 手指滑动时，关闭timer
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self p_stopTimer];
}

/// 手指滑动结束后，重新启动timer
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self p_startTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    /// 修复在滑动过程中切换到别的目标，导致画面一半一半的问题。
    if (self.scrollViewContent.contentOffset.x == 0) {
        return;
    }

    NSString *string = [NSString stringWithFormat:@"%@", @(self.scrollViewContent.contentOffset.x / kScreenWidth)];
    if (string.length != 1) {
        [self.scrollViewContent setContentOffset:CGPointMake(kScreenWidth, 0)
                                        animated:YES];
    }
}


#pragma mark - 对外方法

/// 刷新轮播图控件
- (void)reloadBannerView {
    /// 清除之前的显示数据
    [self p_clearData];
    /// 更新外界的显示的轮播图的显示内容
    NSInteger intTotalCount = [self p_getBannerCellCount];

    /// 轮播图只有一张的时候
    if (intTotalCount < 2) {
        /// 停止定时器
        [self p_stopTimer];

        /// 只有一个的时候
        self.pageCtrlCircle.numberOfPages = 0;
        /// 设置当前页为 0
        self.pageCtrlCircle.currentPage = 0;

        /// 只有一张图，就不要滚动了
        self.scrollViewContent.scrollEnabled = NO;
        
        /// 默认向左移动，显示当前的的图片
        [self p_goLeft];
        /// 发送代理方法
        [self p_sendDelegateScrollOffsetScale:0 curIndex:self.pageCtrlCircle.currentPage scrollDirection:NO];
    } else {
        
        self.pageCtrlCircle.currentPage = 0;
        self.pageCtrlCircle.numberOfPages = intTotalCount;

        /// 求出，索引圆点的右侧和下方的间距
        CGFloat floatBottom = self.edgeInsetsPageCtrl.bottom;
        CGFloat floatRight = self.edgeInsetsPageCtrl.right;
        CGFloat floatLeft = self.edgeInsetsPageCtrl.left;

        [self.pageCtrlCircle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.pageCtrlCircle.superview).with.offset(-floatBottom);
            make.right.mas_equalTo(self.pageCtrlCircle.superview).with.offset(-floatRight);
            make.left.mas_equalTo(self.pageCtrlCircle.superview).with.offset(floatLeft);
            make.height.mas_equalTo(10);
        }];
        
        /// 设置轮播图可以滚动
        self.scrollViewContent.scrollEnabled = YES;
        /// 给点点纪录状态使用
        _isMoveCircle = NO;
        
        [self p_goLeft];
        [self p_startTimer];
        
        /// 发送代理方法
        [self p_sendDelegateScrollOffsetScale:0 curIndex:self.pageCtrlCircle.currentPage scrollDirection:NO];
    }
}

/// 更新pageCtrl配置项
- (void)updatePageCtrlConfig:(void(^)(UIPageControl *pageCtrl))pageCtrlConfigBlcok {
    if (pageCtrlConfigBlcok) {
        pageCtrlConfigBlcok(self.pageCtrlCircle);
    }
}

#pragma mark - 私有方法

/// 刷新轮播图Cell
- (void)p_reloadCell {
    self.scrollViewContent.contentOffset = CGPointMake(kScreenWidth, 0);

    /**
     轮播图索引:因为轮播图有三个Cell, 每次刷新，都是三个一起刷.
     所以，计算出每次对应item的位置告诉外界去更新数据源
     */
    NSInteger intTotalCount = [self p_getBannerCellCount];
    NSInteger intCurrentIndex = self.pageCtrlCircle.currentPage;
    NSInteger intLeftIndex = 0;
    NSInteger intRightIndex = 0;

    if (intCurrentIndex == 0) {
        /// 当前显示的是第一张
        intLeftIndex = intTotalCount - 1;
        intRightIndex = intCurrentIndex + 1;
    } else if (intCurrentIndex == (intTotalCount - 1)) {
        /// 当前显示的是最后一张
        intLeftIndex = intCurrentIndex - 1;
        intRightIndex = 0;
    } else {
        intLeftIndex = intCurrentIndex - 1;
        intRightIndex = intCurrentIndex + 1;
    }

    /// 更新左侧，中间，右侧的数据
    YCBannerCell *leftCell = [self.mArrayCellViews objectAtIndex:0];
    [self p_updateBannerCell:leftCell cellforIndex:intLeftIndex];

    YCBannerCell *rightCell = [self.mArrayCellViews objectAtIndex:2];
    [self p_updateBannerCell:rightCell cellforIndex:intRightIndex];

    YCBannerCell *curCell = [self.mArrayCellViews objectAtIndex:1];
    [self p_updateBannerCell:curCell cellforIndex:intCurrentIndex];

    /// 通知代理对象，intCurrentIndex 指定的item显示了
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(yc_bannerView:showCurCellIndex:)]) {
        [self.delegate yc_bannerView:self showCurCellIndex:intCurrentIndex];
    }
}

/// 更新轮播图索引对应的Cell
- (void)p_updateBannerCell:(YCBannerCell *)cell cellforIndex:(NSInteger)index {
    if (cell == nil) {
        /// 不存在item，不刷新
        return;
    }

    /// 获取轮播图的总个数
    NSInteger intTotalCount = [self p_getBannerCellCount];
    if (index < 0 || index > (intTotalCount - 1)) {
        /// 索引有问题，直接返回，不刷新外界
        return;
    }

    if (self.delegate
        && [self.delegate respondsToSelector:@selector(yc_bannerView:updateDisplayCell:cellForIndex:)]) {
        [self.delegate
               yc_bannerView:self updateDisplayCell:cell cellForIndex:index];
    }
}

/// 清除轮播图数据
- (void)p_clearData {
    for (NSInteger i = 0; i < kDefaultTotalImgCount; i++) {
        YCBannerCell *cell = [self.mArrayCellViews objectAtIndex:i];
        [cell clearData];
    }
}

/**
 轮播图滚动比例回调
 @param offsetScale 轮播图滚动偏移量比例
 @param curIndex 当前索引
 @param isRight 是否向右方向
 */
- (void)p_sendDelegateScrollOffsetScale:(CGFloat )offsetScale curIndex:(NSUInteger)curIndex scrollDirection:(BOOL )isRight {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yc_bannerView:scrollOffsetScale:curIndex:scrollDirection:)]) {
        [self.delegate yc_bannerView:self scrollOffsetScale:offsetScale curIndex:curIndex scrollDirection:isRight];
    }
}


#pragma mark - 移动数据
- (void)p_goRight
{
    NSInteger intTotalCount = [self p_getBannerCellCount];
    /// 判断是否移动点点
    self.pageCtrlCircle.currentPage = _pageCtrlCircle.currentPage == (intTotalCount - 1) ? (0) : (_pageCtrlCircle.currentPage + 1);
    /// 刷新轮播图cell
    [self p_reloadCell];
}

- (void)p_goLeft
{
    NSInteger intTotalCount = [self p_getBannerCellCount];
    
    /// 判断是否移动点点
    if (_isMoveCircle) {
        /// 改变点点位置
        _pageCtrlCircle.currentPage = _pageCtrlCircle.currentPage == 0 ? (intTotalCount - 1) : _pageCtrlCircle.currentPage - 1;
    } else {
        _isMoveCircle = YES;
    }
    
    /// 刷新轮播图cell
    [self p_reloadCell];
}


#pragma mark - 手势相关

/// 处理单击手势
- (void)p_handleTap:(UITapGestureRecognizer *)tap {

    NSInteger intCurrentIndex = self.pageCtrlCircle.currentPage;
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(yc_bannerView:didSelectedIndex:)]) {
        [self.delegate yc_bannerView:self didSelectedIndex:intCurrentIndex];
    }
}

/// 处理长按手势（手指放在上面，停止计时，手指离开，重新计时）
- (void)p_handleLongPress:(UILongPressGestureRecognizer *)longGesture {
    
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        [self p_stopTimer];
    } else if (longGesture.state == UIGestureRecognizerStateEnded) {
        [self p_startTimer];
    }
}


#pragma mark 计时器相关
/// 开始计时器
- (void)p_startTimer {
    
    [self p_stopTimer];
    
    CGFloat timerInterval = [self p_getTimerInterval];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval
                                                  target:[YCProxy proxyWithTarget:self]
                                                selector:@selector(p_handleTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/// 停止计时器
- (void)p_stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

/// 获取计时器间隔时间
- (CGFloat)p_getTimerInterval {
    return self.timeInterval > 0 ? self.timeInterval : kLoopDuring;
}

/// 计时器处理
- (void)p_handleTimer:(NSTimer *)sender {
    if (self.scrollViewContent) {
        [self.scrollViewContent setContentOffset:CGPointMake(self.scrollViewContent.contentOffset.x + kScreenWidth, 0) animated:YES];
    }
}

/// 获取轮播图Cell
- (YCBannerCell *)p_creatBannerCellWithIndex:(NSInteger)index {
    YCBannerCell *cell = [[YCBannerCell alloc] init];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(yc_createCellInBannerView:)]) {
        cell = [self.dataSource yc_createCellInBannerView:self];
    }
    return cell;
}

/// 获取轮播图的Cell的个数
- (NSInteger)p_getBannerCellCount {
    NSInteger intTotalCount = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(yc_numberOfRowsInBannerView:)]) {
        intTotalCount = [self.dataSource yc_numberOfRowsInBannerView:self];
    }
    return intTotalCount;
}


#pragma mark - set/get

/// 指引器
- (UIPageControl *)pageCtrlCircle {
    if (!_pageCtrlCircle) {
        _pageCtrlCircle = [[UIPageControl alloc] init];
        _pageCtrlCircle.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.4];
        _pageCtrlCircle.currentPageIndicatorTintColor = UIColor.whiteColor;
        _pageCtrlCircle.userInteractionEnabled = NO;
        _pageCtrlCircle.currentPage = 0;
    }
    return _pageCtrlCircle;
}

/// 滚动内容视图
- (UIScrollView *)scrollViewContent {
    if (!_scrollViewContent) {
        _scrollViewContent = [[UIScrollView alloc] init];
        _scrollViewContent.delegate = self;
        _scrollViewContent.pagingEnabled = YES;
        _scrollViewContent.scrollsToTop = NO;
        _scrollViewContent.showsHorizontalScrollIndicator = NO;
        _scrollViewContent.showsVerticalScrollIndicator = NO;
        _scrollViewContent.contentSize = CGSizeMake(kScreenWidth * kDefaultTotalImgCount, self.bounds.size.height);
    }
    return _scrollViewContent;
}

/// 保存轮播图Cell的数组
- (NSMutableArray *)mArrayCellViews {
    if (!_mArrayCellViews) {
        _mArrayCellViews = [NSMutableArray array];
    }
    return _mArrayCellViews;
}


#pragma mark - 基类方法

@end
