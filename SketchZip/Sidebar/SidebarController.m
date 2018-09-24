//
//  SidebarController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 24/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SidebarController.h"
#import <PureLayout/PureLayout.h>


@implementation TDView

- (id)init {
    self = [super initWithFrame:NSMakeRect(0, 0, 64, 64)];
    
    self.wantsLayer = YES;
    self.backgroundColor = [NSColor colorWithDeviceRed:0.945 green:0.945 blue:0.953 alpha:1.000];
    
    return self;
}

- (NSColor *)backgroundColor {
    return [NSColor colorWithCGColor:self.layer.backgroundColor];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    self.layer.backgroundColor = backgroundColor.CGColor;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

@end


@implementation SidebarRow

@synthesize highlighted=_highlighted;

- (id)init {
    self = [super initWithFrame:NSMakeRect(0, 0, 120, 24)];
    
    self.wantsLayer = YES;
//    self.layer.backgroundColor = [[NSColor greenColor] CGColor];
    
    TDView *highlightView = [[TDView alloc] init];
    highlightView.cornerRadius = 4;
    [self addSubview:highlightView];
    self.highlightView = highlightView;
    
    NSImageView *iconView = [[NSImageView alloc] init];
    [self.highlightView addSubview:iconView];
    self.iconView = iconView;
    
    NSTextField *titleLabel = [NSTextField labelWithString:@"Title"];
    titleLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];
    titleLabel.textColor = [NSColor colorWithDeviceRed:0.216 green:0.235 blue:0.251 alpha:1.000];
    [self.highlightView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    // Auto layout
    [self.highlightView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 16, 0, 16)];
    [self.highlightView autoSetDimension:ALDimensionHeight toSize:32];
    
    [NSLayoutConstraint autoSetPriority:NSLayoutPriorityDefaultHigh forConstraints:^{
        [self autoSetContentHuggingPriorityForAxis:ALAxisHorizontal];
        [self autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
    }];
    
    [self.iconView autoSetDimensionsToSize:CGSizeMake(20, 20)];
    [self.iconView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.iconView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:8];
    
    [self.titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.highlightView withOffset:0];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.iconView withOffset:4];
//    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:8];
    
    [self setHighlighted:NO];
    
    return self;
}

- (BOOL)highlighted {
    return _highlighted;
}

- (void)setHighlighted:(BOOL)highlighted {
    if(highlighted) {
        self.highlightView.backgroundColor = [NSColor colorWithDeviceRed:0.894 green:0.902 blue:0.914 alpha:1.000];
    }
    else {
        self.highlightView.backgroundColor = [NSColor clearColor];
    }
    
    _highlighted = highlighted;
}

@end


@interface SidebarController ()

@end


@implementation SidebarController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 240, 640)];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [[NSColor colorWithDeviceRed:0.976 green:0.980 blue:0.980 alpha:1.000] CGColor];

    SidebarRow *everythingRow = [[SidebarRow alloc] init];
    everythingRow.iconView.image = [NSImage imageNamed:@"Everything"];
    everythingRow.titleLabel.stringValue = @"Everything";
    everythingRow.highlighted = YES;
    
    SidebarRow *recentsRow = [[SidebarRow alloc] init];
    recentsRow.iconView.image = [NSImage imageNamed:@"Recents"];
    recentsRow.titleLabel.stringValue = @"Recents";
    
    SidebarRow *favoritesRow = [[SidebarRow alloc] init];
    favoritesRow.iconView.image = [NSImage imageNamed:@"Favorites"];
    favoritesRow.titleLabel.stringValue = @"Favorites";
    
    NSStackView *stackView = [NSStackView stackViewWithViews:@[everythingRow, recentsRow, favoritesRow]];
//    [stackView setHuggingPriority:NSLayoutPriorityWindowSizeStayPut forOrientation:NSLayoutConstraintOrientationVertical];
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    stackView.distribution = NSStackViewDistributionEqualSpacing;
    stackView.spacing = 4;
    stackView.alignment = NSLayoutAttributeLeft;
    stackView.layer.backgroundColor = [[NSColor redColor] CGColor];
    
    [self.view addSubview:stackView];
    self.stackView = stackView;

//    [self.stackView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsZero];
    [self.stackView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:48];
    [self.stackView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.stackView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
}

@end
