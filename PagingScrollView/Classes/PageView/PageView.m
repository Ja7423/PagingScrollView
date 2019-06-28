//
//  PageView.m
//  PagingScrollView
//
//  Created by 家瑋 on 2019/6/27.
//  Copyright © 2019 家瑋. All rights reserved.
//

#import "PageView.h"

@interface PageView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation PageView

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [self removeGesture];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        [self addGesture];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self addGesture];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.userInteractionEnabled = YES;
        [self addGesture];
    }
    return self;
}

#pragma mark - TapGesture
- (void)addGesture
{
    [self removeGesture];
    
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureHandler:)];
    self.tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:self.tapGesture];
}

- (void)removeGesture
{
    if (self.tapGesture) {
        [self removeGestureRecognizer:self.tapGesture];
        self.tapGesture = nil;
    }
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(didSelectPageView:)]) {
        [self.delegate didSelectPageView:self];
    }
}

@end
