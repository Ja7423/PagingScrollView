//
//  PageScrollView.m
//  PagingScrollView
//
//  Created by 家瑋 on 2019/6/27.
//  Copyright © 2019 家瑋. All rights reserved.
//

#import "PageScrollView.h"
#import <Masonry/Masonry.h>

@interface PageScrollView () <UIScrollViewDelegate, PageViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat contentOffsetX;

@property (nonatomic, strong) NSMutableArray *loopSubViews;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger loopCount;

@property (nonatomic, assign) BOOL needUpdateScrollView;

@end

@implementation PageScrollView

// 即使超出scrollview範圍也能夠滑動scrollview
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([view isEqual:self])
    {
        for (UIView *subview in self.scrollView.subviews)
        {
            CGPoint offset = CGPointMake(point.x - self.scrollView.frame.origin.x + self.scrollView.contentOffset.x - subview.frame.origin.x,
                                         point.y - self.scrollView.frame.origin.y + self.scrollView.contentOffset.y - subview.frame.origin.y);

            if ((view = [subview hitTest:offset withEvent:event]))
            {
                return view;
            }
        }
        
        return self.scrollView;
    }
    
    return view;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [self removeTimer];
}

- (instancetype)initWithConfig:(PageScrollViewConfig *)scrollConfig
{
    self = [super init];
    if (self) {
        self.scrollConfig = scrollConfig;
        self.needUpdateScrollView = YES;
        [self createScrollView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self addSubViewAtScrollView];
}

- (void)defaultSetting
{
    self.currentPageIndex = 0;
}

#pragma mark - Data

- (void)setDataCount:(NSInteger)dataCount
{
    _dataCount = dataCount;
    
    if (!dataCount) {
        self.loopCount = 0;
        return;
    }
    
    if (_dataCount < 2) {
        self.scrollConfig.loopEnable = NO;
    }
    
    self.loopCount = (self.scrollConfig.loopEnable) ? _dataCount + 2 : _dataCount;
}

#pragma mark - Calculate

- (NSInteger)originIndex:(NSInteger)index
{
    if (!self.scrollConfig.loopEnable) return index;
    
    NSInteger selectIdx = index;

    if (selectIdx == 0) {
        selectIdx = self.dataCount - 1;
    } else if (selectIdx == self.loopCount - 1) {
        selectIdx = 0;
    } else {
        selectIdx -= 1;
    }

    return selectIdx;
}

- (NSInteger)originIndexOfPageView:(PageView *)pageView
{
    for (NSInteger i = 0; i < self.scrollView.subviews.count; i++) {
        UIView *view = self.scrollView.subviews[i];
        if ([view isKindOfClass:[pageView class]] &&
            pageView == view) {
            return [self originIndex:i];
        }
    }
    
    return self.currentPageIndex;
}

#pragma mark - PageView config

- (CGFloat)pageWidth
{
    return self.scrollView.frame.size.width - self.scrollConfig.spacing;
}

- (CGFloat)minOffsetX
{
    // offset x的最小值
    return [self halfSpacing] + self.scrollConfig.inset;
}

- (CGFloat)maxOffsetX
{
    // offset x的最大值
    return [self xPositionFromIndex:self.loopCount - 1] - self.scrollConfig.inset;
}

- (CGFloat)halfSpacing
{
    return self.scrollConfig.spacing / 2.0;
}

- (CGFloat)xPositionFromIndex:(NSInteger)index
{
    return (2 * index + 1) * [self halfSpacing] + index * [self pageWidth];
}

#pragma mark - UIScrollView

- (void)createScrollView
{
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(self.scrollConfig.inset);
        make.right.equalTo(self).offset(-self.scrollConfig.inset);
    }];
    
    self.loopSubViews = [NSMutableArray array];
}

- (void)addSubViewAtScrollView
{
    if (!self.needUpdateScrollView) return;
    
    if (self.scrollView.subviews.count) {
        [self removeSubviewsFromScrollView];
    }
    
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat height = self.scrollView.frame.size.height;
    
    if (!width || !height) return;
    
    CGFloat spacing = self.scrollConfig.spacing;
    CGFloat pageWidth = width - spacing;
    
    for (NSInteger i = 0; i < self.loopCount; i++) {
        if ([self.dataSource respondsToSelector:@selector(pageViewAtIndex:)]) {
            CGFloat x = [self xPositionFromIndex:i];
            NSInteger originIndex = [self originIndex:i];
            PageView *pageView = [self.dataSource pageViewAtIndex:originIndex];
            pageView.frame = CGRectMake(x, 0, pageWidth, height);
            pageView.delegate = self;
            [self.scrollView addSubview:pageView];
        }
    }
    
    self.scrollView.contentSize = CGSizeMake((pageWidth + spacing) * self.loopCount, height);
    [self scrollToPageInContent:self.currentPageIndex animated:NO];
    
    self.needUpdateScrollView = NO;
    
    [self addAutoScrollTimer];
}

- (void)removeSubviewsFromScrollView
{
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)updatePageScrollViewDataCount:(NSInteger)updateCount
{
    [self removeTimer];
    
    self.dataCount = updateCount;
    
    self.needUpdateScrollView = YES;
    [self setNeedsLayout];
}

- (void)checkOffset
{
    if (!self.scrollConfig.loopEnable) return;
    
    // 3 1 2 3 1
    if(self.contentOffsetX <= [self minOffsetX]) {
        // 滑到第一張的時候要回到倒數第二張
        [self scrollToPageInContent:self.loopCount - 2 animated:NO];
    } else if (self.contentOffsetX >= [self maxOffsetX]) {
        // 滑到最後一張的時候要回到第二張
        [self scrollToPageInContent:1 animated:NO];
    }
}

// page是依照整個scrollView的subviews數量來算
- (void)scrollToPageInContent:(NSInteger)page animated:(BOOL)animated
{
    if (page >= self.loopCount) return;
    if (self.scrollConfig.loopEnable && page == 0) page = 1;
    
    CGPoint offset = CGPointMake([self xPositionFromIndex:page], 0);
    [self.scrollView setContentOffset:offset animated:animated];
}

- (CGFloat)contentOffsetX
{
    return self.scrollView.contentOffset.x;
}

- (NSInteger)currentIndex
{
    NSInteger index = self.contentOffsetX / self.scrollView.frame.size.width;
    return [self originIndex:index];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addAutoScrollTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self addAutoScrollTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.currentPageIndex = [self currentIndex];
    
    [self checkOffset];
}

#pragma mark - Timer

- (void)addAutoScrollTimer
{
    [self removeTimer];
    
    if (!self.scrollConfig.autoScrollEnable) {
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.scrollConfig.loopDuration
                                                  target:self
                                                selector:@selector(autoScrollHandler:)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)pauseAutoScroll
{
    [self removeTimer];
}

- (void)resumeAutoScroll
{
    if (self.timer || !self.scrollConfig.autoScrollEnable) {
        return;
    }
    
    [self addAutoScrollTimer];
}

- (void)autoScrollHandler:(NSTimer *)timer
{
    [self scrollToPageInContent:self.currentPageIndex + 1 animated:YES];
}

#pragma mark - PageViewDelegate
- (void)didSelectPageView:(PageView *)pageView
{
    NSInteger selectedIndex = [self originIndexOfPageView:pageView];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedPageViewAtIndex:)]) {
        [self.delegate didSelectedPageViewAtIndex:selectedIndex];
    }
}

@end
