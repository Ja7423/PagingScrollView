//
//  CustomPageView.m
//  PagingScrollView
//
//  Created by 家瑋 on 2019/6/27.
//  Copyright © 2019 家瑋. All rights reserved.
//

#import "CustomPageView.h"
#import <Masonry/Masonry.h>

@interface CustomPageView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CustomPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.imageView = [[UIImageView alloc] init];
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self);
    }];
    
    self.backgroundColor = [UIColor redColor];
    
    NSLog(@"class: %@", self.class);
}

- (void)loadImageAtIndex:(NSInteger)index
{
    NSString *imageName = [NSString stringWithFormat:@"DrHouse%ld.jpg", (long)index];
    self.imageView.image = [UIImage imageNamed:imageName];
}

@end
