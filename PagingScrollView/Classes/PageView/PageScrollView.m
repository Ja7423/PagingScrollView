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

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger loopCount;

@property (nonatomic, assign) NSInteger _pageIndex;

@property (nonatomic, assign) BOOL needUpdateScrollView;

@property (nonatomic, assign) BOOL dragging;

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
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.scrollConfig = scrollConfig;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.scrollConfig = [PageScrollViewConfig new];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollConfig = [PageScrollViewConfig new];
    }
    return self;
}

- (void)setScrollConfig:(PageScrollViewConfig *)scrollConfig
{
    _scrollConfig = scrollConfig;
    [self initialize];
}

- (void)initialize
{
    self.dragging = NO;
    self.needUpdateScrollView = YES;
    self.clipsToBounds = YES;
    self.animationType = PageScrollViewTransformTypeNormal;
    [self createScrollView];
}

- (void)layoutSubviews
{
    CGRect oldFrame = self.scrollView.frame;
    [super layoutSubviews];
    
    if (self.needUpdateScrollView) {
        [self addSubViewAtScrollView];
    } else if (oldFrame.size.width != self.scrollView.frame.size.width) {
        [self scrollToPageInContent:self._pageIndex animated:NO];
    }
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

    if (selectIdx <= 0) {
        selectIdx = self.dataCount - 1;
    } else if (selectIdx >= self.loopCount - 1) {
        selectIdx = 0;
    } else {
        selectIdx -= 1;
    }

    return selectIdx;
}

- (NSInteger)originIndexOfPageView:(PageView *)pageView
{
//    for (NSInteger i = 0; i < self.scrollView.subviews.count; i++) {
//        UIView *view = self.scrollView.subviews[i];
//        if ([view isKindOfClass:[pageView class]] &&
//            pageView == view) {
//            return [self originIndex:i];
//        }
//    }
    
    return self.currentPageIndex;
}

- (CGPoint)contentCenter
{
    CGFloat x = self.scrollView.contentOffset.x + (self.scrollView.bounds.size.width / 2);
    CGFloat y = self.scrollView.bounds.size.height / 2;
    return CGPointMake(x, y);
}

- (CGFloat)scaleFromPoint:(CGPoint)point
{
    return 0;
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
    if (self.scrollView) {
        [self.scrollView removeFromSuperview];
        self.scrollView = nil;
    }
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(self.scrollConfig.inset);
        make.right.equalTo(self).offset(-self.scrollConfig.inset);
    }];
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
    
    self.needUpdateScrollView = NO;
    
    self.scrollView.contentSize = CGSizeMake((pageWidth + spacing) * self.loopCount, height);
    [self scrollToPageInContent:self._pageIndex animated:NO];
    
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
    
    CGFloat x = [self xPositionFromIndex:page] - [self halfSpacing];
    CGPoint offset = CGPointMake(x, 0);
    [self.scrollView setContentOffset:offset animated:animated];
}

- (CGFloat)contentOffsetX
{
    return self.scrollView.contentOffset.x;
}

- (NSInteger)currentIndex
{
    return self.contentOffsetX / self.scrollView.frame.size.width;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dragging = YES;
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.dragging = NO;
    [self addAutoScrollTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.dragging = NO;
    [self addAutoScrollTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self._pageIndex = [self currentIndex];
    
    if (!self.dragging) {
        self.currentPageIndex = [self originIndex:self._pageIndex];
    }
    
    [self checkOffset];
    [self startTransform];
}

#pragma mark - Transform
- (void)startTransform
{
    if (self.animationType == PageScrollViewTransformTypeNormal) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *visibleViews = [self visibleViews];
        CGFloat centerX = [self contentCenter].x;
        CGFloat scaleRatio = 1 - self.scrollConfig.minScale;
        for (UIView *visibleView in visibleViews) {
            CGFloat xDistance = visibleView.center.x - centerX;
            CGFloat scale = 1.0 - fabs((xDistance / self.scrollView.bounds.size.width) * scaleRatio);
            visibleView.layer.transform = CATransform3DMakeScale(1.0, scale, 1.0);
        }
    });
}

- (NSArray *)visibleViews
{
    NSMutableArray *views = [NSMutableArray array];
    for (UIView *subView in self.scrollView.subviews) {
        CGFloat maxX = CGRectGetMaxX(subView.frame);
        CGFloat maxY = CGRectGetMaxY(subView.frame);
        CGFloat minX = CGRectGetMinX(subView.frame);
        CGFloat minY = CGRectGetMinY(subView.frame);
        CGPoint maxPoint = [self.scrollView convertPoint:CGPointMake(maxX, maxY) toView:self];
        CGPoint minPoint = [self.scrollView convertPoint:CGPointMake(minX, minY) toView:self];

        if ((minPoint.x < self.frame.size.width && minPoint.x > 0) ||
            (maxPoint.x < self.frame.size.width && maxPoint.x > 0))
        {
            [views addObject:subView];
        }
    }
    
//    NSLog(@"visible views count(%ld)", (long)views.count);
    return views;
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
    [self scrollToPageInContent:self._pageIndex + 1 animated:YES];
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
