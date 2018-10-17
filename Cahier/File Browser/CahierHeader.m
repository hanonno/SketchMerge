//
//  CahierHeader.m
//  Cahier
//
//  Created by Hanno ten Hoor on 17/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "CahierHeader.h"


@implementation CahierHeader

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
