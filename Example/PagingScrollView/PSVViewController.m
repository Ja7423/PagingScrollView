//
//  PSVViewController.m
//  PagingScrollView
//
//  Created by Ja7423 on 06/28/2019.
//  Copyright (c) 2019 Ja7423. All rights reserved.
//

#import "PSVViewController.h"
#import "CustomPageView.h"

#import <PagingScrollView/PagingScrollView.h>

@interface PSVViewController () <PageScrollViewDataSource, PageScrollViewDelegate>


@property (nonatomic, strong) PageScrollView *pageScrollView;

@property (nonatomic, strong) NSMutableArray *testImages;

@end

@implementation PSVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testImages = @[@"0", @"1", @"3"].mutableCopy;
    
    PageScrollViewConfig *config = [PageScrollViewConfig new];
    config.autoScrollEnable = NO;
    config.loopEnable = YES;
    
    self.pageScrollView = [[PageScrollView alloc] initWithConfig:config];
    self.pageScrollView.frame = CGRectMake(0, 100, self.view.frame.size.width, 150);
    self.pageScrollView.dataSource = self;
    self.pageScrollView.delegate = self;
    [self.view addSubview:self.pageScrollView];
    
    self.pageScrollView.dataCount = self.testImages.count;
}

- (PageView *)pageViewAtIndex:(NSInteger)index
{
    NSLog(@"%s %ld", __func__, (long)index);
    CustomPageView *pageView = [[CustomPageView alloc] init];
    [pageView loadImageAtIndex:[self.testImages[index] integerValue]];
    return pageView;
}

- (void)didSelectedPageViewAtIndex:(NSInteger)index
{
    NSLog(@"%s %ld", __func__, (long)index);
}

- (IBAction)insert:(UIButton *)sender {
    
    [self.testImages insertObject:@"2" atIndex:1];
    
    [self.pageScrollView updatePageScrollViewDataCount:self.testImages.count];
}

@end
