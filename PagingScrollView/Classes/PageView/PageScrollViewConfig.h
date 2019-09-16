//
//  PageScrollViewConfig.h
//  PagingScrollView
//
//  Created by 家瑋 on 2019/6/27.
//  Copyright © 2019 家瑋. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PageScrollViewConfig : NSObject

// cell之間的間距， default is 8.0
@property (nonatomic, assign) NSInteger spacing;

// 左右顯示的大小， default is 20.0
@property (nonatomic, assign) NSInteger inset;

// 每個cell停留時間， default is 3.0
@property (nonatomic, assign) NSTimeInterval loopDuration;

// minimum scale， default is 0.8
@property (nonatomic, assign) NSTimeInterval minScale;

// 是否自動滑動， default is YES
@property (nonatomic, assign) BOOL autoScrollEnable;

// 是否循環， default is YES
@property (nonatomic, assign) BOOL loopEnable;

@end

NS_ASSUME_NONNULL_END
