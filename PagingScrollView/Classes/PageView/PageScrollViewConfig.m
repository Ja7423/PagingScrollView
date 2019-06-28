//
//  PageScrollViewConfig.m
//  PagingScrollView
//
//  Created by 家瑋 on 2019/6/27.
//  Copyright © 2019 家瑋. All rights reserved.
//

#import "PageScrollViewConfig.h"

@implementation PageScrollViewConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultSetting];
    }
    return self;
}

- (void)defaultSetting
{
    self.loopEnable = YES;
    self.autoScrollEnable = YES;
    self.loopDuration = 3.0;
    self.inset = 20.0;
    self.spacing = 8.0;
}

@end
