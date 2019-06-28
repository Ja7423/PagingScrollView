//
//  PageScrollView.h
//  PagingScrollView
//
//  Created by 家瑋 on 2019/6/27.
//  Copyright © 2019 家瑋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageScrollViewConfig.h"
#import "PageView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PageScrollViewDataSource <NSObject>

- (PageView *)pageViewAtIndex:(NSInteger)index;

@end

@protocol PageScrollViewDelegate <NSObject>

- (void)didSelectedPageViewAtIndex:(NSInteger)index;

@end


@interface PageScrollView : UIView

@property (nonatomic, weak) id<PageScrollViewDataSource> dataSource;

@property (nonatomic, weak) id<PageScrollViewDelegate> delegate;

// 原始資料筆數
@property (nonatomic, assign) NSInteger dataCount;

// page index
@property (nonatomic, assign) NSInteger currentPageIndex;

// 設定
@property (nonatomic, strong) PageScrollViewConfig *scrollConfig;



- (instancetype)initWithConfig:(PageScrollViewConfig *)scrollConfig;

- (void)updatePageScrollViewDataCount:(NSInteger)updateCount;

- (void)pauseAutoScroll;

- (void)resumeAutoScroll;

@end

NS_ASSUME_NONNULL_END
