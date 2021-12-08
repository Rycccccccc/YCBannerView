//
//  YCHomeBannerCell.m
//  YCBannerView_Example
//
//  Created by 任义春 on 2021/12/8.
//  Copyright © 2021 renyichun. All rights reserved.
//

#import "YCHomeBannerCell.h"
#import <Masonry.h>

@interface YCHomeBannerCell()

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation YCHomeBannerCell


#pragma mark - 初始化

- (void)setupUI {
    [self addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.clipsToBounds = YES;
}

#pragma mark - 点击事件

#pragma mark - 代理方法

#pragma mark - 对外方法


- (void)setObject:(id)aObject {
    NSString *imgName = (NSString *) aObject;
    self.imgView.image = [UIImage imageNamed:imgName];
}

#pragma mark - 私有方法

#pragma mark - set/get

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imgView;
}

#pragma mark - 基类方法


@end
