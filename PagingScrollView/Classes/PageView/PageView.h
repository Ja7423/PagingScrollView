//
//  PageView.h
//  PagingScrollView
//
//  Created by 家瑋 on 2019/6/27.
//  Copyright © 2019 家瑋. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PageView;
@protocol PageViewDelegate <NSObject>

- (void)didSelectPageView:(PageView *)pageView;

@end

@interface PageView : UIView

@property (nonatomic, weak) id<PageViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
