//
//  CahierHeader.m
//  Cahier
//
//  Created by Hanno ten Hoor on 17/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "BrowserHeader.h"


#import "Filter.h"


@implementation BrowserHeaderController

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection {
    self = [super init];
    
    _assetCollection = assetCollection;
    [_assetCollection addDelegate:self];
    
    self.zoomFactorSlider = [[NSSlider alloc] init];
    self.zoomFactorSlider.minValue = 0.5;
    self.zoomFactorSlider.maxValue = 1;
    
    return self;
}

- (void)loadView {
    self.view = [[View alloc] initWithBackgroundColor:[NSColor browserBackgroundColor]];
    
    self.titleLabel = [NSTextField labelWithString:@"Title"];
    self.titleLabel.font = [NSFont systemFontOfSize:22 weight:NSFontWeightMedium];
    [self.view addSubview:self.titleLabel];
    
    [self.view addSubview:self.zoomFactorSlider];
    
    self.filterField = [[FilterField alloc] init];
    [self.view addSubview:self.filterField];
    
    self.filterStackView = [[NSStackView alloc] init];
    [self.view addSubview:self.filterStackView];
    
    self.divider = [View horizontalDivider];
    [self.view addSubview:self.divider];
    
    // Autolayout
    CGFloat inset = 24;
    
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:inset];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:inset];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:inset];
    
    [self.filterField autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:inset];
    [self.filterField autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.filterStackView];
    [self.filterField autoSetDimension:ALDimensionHeight toSize:22];
    
    [self.filterStackView autoSetDimension:ALDimensionHeight toSize:22];
    [self.filterStackView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.filterField withOffset:8];
    //    [_filterStackView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:inset];
    [self.filterStackView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:inset];
    
    [self.filterStackView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:-16];

    [self.zoomFactorSlider autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:inset];
    [self.zoomFactorSlider autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:inset];
    [self.zoomFactorSlider autoSetDimension:ALDimensionWidth toSize:120];
    
    [self.divider autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.filterStackView withOffset:16];
    [self.divider pinToBottomOfView:self.view];

    
    self.filterField.target = self;
    self.filterField.action = @selector(toggleFilterField:);
    
//    self.filterField.filterTextField.target = self;
//    self.filterField.filterTextField.action = @selector(filterFieldChanged:);
    
    self.filterField.filterTextField.delegate = self;
}

- (void)controlTextDidChange:(NSNotification *)obj {
    KeywordFilter *filter = [[KeywordFilter alloc] init];
    filter.keywords = self.filterField.filterTextField.stringValue;
    [self.assetCollection replaceFilter:filter];
}

- (void)toggleFilterField:(id)sender {
    [self.filterField.filterTextField becomeFirstResponder];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.16;
        context.allowsImplicitAnimation = YES;
        
        [self.filterField setSelected:!self.filterField.selected animated:NO];
        
//        [self.filterField layoutSubtreeIfNeeded];
        [self.view layoutSubtreeIfNeeded];
    }];
}

- (void)reloadFilters {
//    [self.filterStack ]
    NSArray *subviews = [self.filterStackView.subviews copy];
    
    for (NSView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
//    [self.filterStackView addView:self.filterField inGravity:NSStackViewGravityLeading];
    
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
        
        [self.filterStackView addView:button inGravity:NSStackViewGravityLeading];
    }
}

- (void)filterSelected:(Button *)sender {
    NSArray *subviews = [self.filterStackView.subviews copy];
    
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

- (void)filterFieldChanged:(id)sender {
    NSLog(@"Hahah");
}

@end
