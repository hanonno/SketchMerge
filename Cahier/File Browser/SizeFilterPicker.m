//
//  SizeFilterPicker.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 07/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SizeFilterPicker.h"


@implementation MenuItemView

- (instancetype)init {
    self = [super initWithFrame:NSMakeRect(0, 0, 320, 44)];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSView *highlightView = [[NSView alloc] init];
    highlightView.wantsLayer = YES;
    highlightView.layer.cornerRadius = 4;
//    highlightView.layer.backgroundColor = [[NSColor redColor] CGColor];
    [self addSubview:highlightView];
    self.highlightView = highlightView;
    
    NSImageView *iconView = [[NSImageView alloc] init];
    [self.highlightView addSubview:iconView];
    self.iconView = iconView;
    
    NSTextField *titleLabel = [NSTextField labelWithString:@"Title"];
    titleLabel.font = [NSFont systemFontOfSize:11 weight:NSFontWeightMedium];
    titleLabel.textColor = [NSColor titleTextColor];
    [self.highlightView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    
    NSTextField *subtitleLabel = [NSTextField labelWithString:@"Subtitle"];
    subtitleLabel.font = [NSFont systemFontOfSize:11 weight:NSFontWeightRegular];
    subtitleLabel.textColor = [NSColor subtitleTextColor];
    [self.highlightView addSubview:subtitleLabel];
    self.subtitleLabel = subtitleLabel;
    
    // Auto layout
    [self.highlightView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 4, 0, 4)];
    
    [self.iconView autoSetDimensionsToSize:CGSizeMake(20, 20)];
    [self.iconView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.iconView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:8];
    
//    [self.titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.highlightView withOffset:0];
//    [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(8, 8, 8, 0) excludingEdge:ALEdgeRight];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:4];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:4];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.iconView withOffset:4];
    
    [self.subtitleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.subtitleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:8];
    
    return self;
}

- (void)setSelected:(BOOL)selected {
    if(selected) {
        self.highlightView.layer.backgroundColor = [[NSColor headerBackgroundColor] CGColor];
    }
    else {
        self.highlightView.layer.backgroundColor = [[NSColor clearColor] CGColor];;
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self setSelected:YES];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    [self setSelected:NO];
    [self setNeedsDisplay:YES];
    
    [self sendAction:self.action to:self.target];
}

@end


@implementation SizeFilterPicker

- (instancetype)init {
    self = [super init];
    
    self.filters = [SizeFilter appleDeviceFilters];
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 240, 320)];
    
    self.stackView = [[NSStackView alloc] init];
    self.stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    self.stackView.spacing = 0;
    [self.view addSubview:self.stackView];

    for (SizeFilter *filter in self.filters) {
        MenuItemView *menuItemView = [[MenuItemView alloc] init];
        
        menuItemView.titleLabel.stringValue = filter.presetName;
        menuItemView.subtitleLabel.stringValue = [NSString stringWithFormat:@"%i × %i", (int)filter.width, (int)filter.height];
        menuItemView.representedObject = filter;
        menuItemView.target = self;
        menuItemView.action = @selector(sizeSelected:);
        
        [self.stackView addArrangedSubview:menuItemView];
    }
    
    [self.stackView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(4, 0, 4, 0)];
}

- (void)sizeSelected:(MenuItemView *)sender {
    SizeFilter *filter = (SizeFilter *)[sender representedObject];
    
    if([self.delegate respondsToSelector:@selector(sizeFilterPicker:didPickFilter:)]) {
        [self.delegate sizeFilterPicker:self didPickFilter:filter];
    }
    
    NSLog(@"Size: %@", sender.titleLabel.stringValue);
}

@end
