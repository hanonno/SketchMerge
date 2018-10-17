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
    
    _divider = [View horizontalDivider];
    [self addSubview:_divider];
    
    self.backgroundColor = [NSColor sidebarBackgroundColor];
    
    // Autolayout
    CGFloat inset = 24;
    
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:inset];
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:inset];
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:inset];

    [_divider autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleLabel withOffset:16];
    [_divider pinToBottomOfView:self];

    return self;
}

@end
