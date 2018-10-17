//
//  CahierHeader.m
//  Cahier
//
//  Created by Hanno ten Hoor on 17/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "BrowserHeader.h"


#import "Filter.h"


@implementation BrowserHeader

- (instancetype)init {
    self = [super init];
    
    _titleLabel = [NSTextField labelWithString:@"Title"];
    _titleLabel.font = [NSFont systemFontOfSize:22 weight:NSFontWeightMedium];
    [self addSubview:_titleLabel];
    
    _filterStackView = [[NSStackView alloc] init];
    [self addSubview:_filterStackView];
    
    _divider = [View horizontalDivider];
    [self addSubview:_divider];
    
    self.backgroundColor = [NSColor browserBackgroundColor];
    
    // Autolayout
    CGFloat inset = 24;
    
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:inset];
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:inset];
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:inset];

    [_filterStackView autoSetDimension:ALDimensionHeight toSize:22];
    [_filterStackView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:inset];
    [_filterStackView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:inset];
    
    [_filterStackView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleLabel withOffset:-16];

    [_divider autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_filterStackView withOffset:16];
    [_divider pinToBottomOfView:self];    
    
    return self;
}

@end


@implementation BrowserHeaderController

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection {
    self = [super init];
    
    _assetCollection = assetCollection;
    [_assetCollection addDelegate:self];
    
    return self;
}

- (void)loadView {
    self.browserHeaderView = [[BrowserHeader alloc] init];
    
    self.view = self.browserHeaderView;
}

- (void)reloadFilters {
//    [self.browserHeaderView.filterStack ]
    NSArray *subviews = [self.browserHeaderView.filterStackView.subviews copy];
    
    for (NSView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    NSArray *activeFilters = self.assetCollection.activeFilters;
    
    for (Filter *filter in self.assetCollection.matchedFilters) {
        Button *button = [[Button alloc] init];
        button.titleLabel.stringValue = filter.title;
        button.target = self;
        button.action = @selector(filterSelected:);
        
        for (Filter *activeFilter in activeFilters) {
            if([activeFilter.title isEqualToString:filter.title]) {
                [button setSelected:YES animated:NO];
            }
        }
        
        [self.browserHeaderView.filterStackView addView:button inGravity:NSStackViewGravityLeading];
    }
}

- (void)filterSelected:(Button *)sender {
    NSArray *subviews = [self.browserHeaderView.filterStackView.subviews copy];
    
    for (Button *button in subviews) {
        [button setSelected:NO animated:NO];
    }

    [sender setSelected:YES animated:NO];
    
    NSString *filterTitle = sender.titleLabel.stringValue;
    
    for (Filter *filter in self.assetCollection.matchedFilters) {
        if([filter.title isEqualToString:filterTitle]) {
            [self.assetCollection replaceFilter:filter];
        }
    }
}

- (void)assetCollectionDidUpdate:(AssetCollection *)assetCollection {
    [self reloadFilters];
}

- (void)assetCollectionDidUpdate:(AssetCollection *)assetCollection filter:(Filter *)filter {
    
}

@end
