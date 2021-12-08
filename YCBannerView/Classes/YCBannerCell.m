//
//  YCBannerCell.m
//  YCBannerView_Example
//
//  Created by 任义春 on 2021/12/7.
//  Copyright © 2021 renyichun. All rights reserved.
//

#import "YCBannerCell.h"
#import "Masonry.h"

@interface YCBannerCell()

// 标题
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation YCBannerCell

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initConfig];
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initConfig];
        [self setupUI];
    }
    return self;
}

- (void)initConfig {
   
}

- (void)setupUI {
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - 点击事件

#pragma mark - 代理方法


#pragma mark - 对外方法


/**
 cell 赋值
 */
- (void)setObject:(id)aObject {
    NSString *titleStr = (NSString *) aObject;
    self.titleLabel.text = titleStr;
}

/// 清除数据
- (void)clearData {
    self.titleLabel.text = @"";
}

#pragma mark - 私有方法

#pragma mark - set/get

// 标题
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor orangeColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark - 基类方法


@end
