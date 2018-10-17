//
//  TDTheme.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 26/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "Theme.h"

@implementation Theme

+ (Theme *)currentTheme {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (NSColor *)titleTextColor {
    return [NSColor colorWithCalibratedHue:0.67 saturation:0.01 brightness:1.00 alpha:1.00];
}

- (NSColor *)subtitleTextColor {
    return [NSColor colorWithCalibratedHue:0.67 saturation:0.01 brightness:0.80 alpha:1.00];
}

- (NSColor *)bodyTextColor {
    return [NSColor redColor];
}

- (NSColor *)backgroundColor {
    return [NSColor colorWithHue:0.63 saturation:0.11 brightness:0.15 alpha:1.00];
//    return [NSColor colorWithCalibratedHue:0.63 saturation:0.13 brightness:0.13 alpha:1.00];
//    return [NSColor colorWithCalibratedHue:0.63 saturation:0.11 brightness:0.15 alpha:1.00];
}

- (NSColor *)headerBackgroundColor {
    return [NSColor colorWithCalibratedHue:0.61 saturation:0.05 brightness:0.26 alpha:1.00];
}

- (NSColor *)dividerColor {
    return [NSColor colorWithCalibratedHue:0.63 saturation:0.16 brightness:0.10 alpha:1.00];
}

- (NSColor *)highlightColor {
    return [NSColor colorWithHue:0.59 saturation:0.95 brightness:1.00 alpha:1.00];
}

@end



@implementation NSColor (Cahier)

+ (NSColor *)titleTextColor {
    return [NSColor labelColor];
}

+ (NSColor *)subtitleTextColor {
    return [NSColor secondaryLabelColor];
}

+ (NSColor *)bodyTextColor {
    return [NSColor tertiaryLabelColor];
}

+ (NSColor *)backgroundColor {
    return [[Theme currentTheme] backgroundColor];
}

+ (NSColor *)headerBackgroundColor {
    return [[Theme currentTheme] headerBackgroundColor];
}

+ (NSColor *)dividerColor {
    return [NSColor colorNamed:@"dividerColor"];
//    return [NSColor colorWithDeviceHue:0.49 saturation:0.00 brightness:0.96 alpha:1.00];
}

+ (NSColor *)highlightColor {
    return [[Theme currentTheme] highlightColor];
}

+ (NSColor *)sidebarTextColor {
    return [NSColor colorNamed:@"sidebarTextColor"];
//    return [NSColor colorWithDeviceHue:0.57 saturation:0.12 brightness:0.25 alpha:1.00];
}

+ (NSColor *)sidebarBackgroundColor {
    return [NSColor colorNamed:@"sidebarBackgroundColor"];
//    return [NSColor colorWithDeviceHue:0.58 saturation:0.01 brightness:0.97 alpha:1.00];
}

+ (NSColor *)selectedSidebarItemColor {
    return [NSColor colorNamed:@"selectedSidebarItemColor"];
//    return [NSColor colorWithDeviceHue:0.59 saturation:0.03 brightness:0.91 alpha:1.00];
}

+ (NSColor *)browserBackgroundColor {
    return [NSColor colorWithDeviceHue:0.31 saturation:0.00 brightness:0.04 alpha:1.00];
    return [NSColor colorWithDeviceHue:0.65 saturation:0.15 brightness:0.19 alpha:1.00];
}

@end


@implementation View

@synthesize backgroundColor = _backgroundColor;

+ (instancetype)horizontalDivider {
    View *divider = [[View alloc] initWithBackgroundColor:[NSColor dividerColor]];
    [divider autoSetDimension:ALDimensionHeight toSize:1];
    return divider;
}

+ (instancetype)verticalDivider {
    View *divider = [[View alloc] initWithBackgroundColor:[NSColor dividerColor]];
    [divider autoSetDimension:ALDimensionWidth toSize:1];
    return divider;

}


- (instancetype)initWithBackgroundColor:(NSColor *)backgroundColor {
    self = [super initWithFrame:NSMakeRect(0, 0, 120, 120)];
    
    self.wantsLayer = YES;
    self.backgroundColor = backgroundColor;
    
    return self;
}

- (NSColor *)backgroundColor {
    return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.layer.backgroundColor = [_backgroundColor CGColor];
}

- (void)updateLayer {
    self.layer.backgroundColor = [_backgroundColor CGColor];
}

- (void)pinToBottomOfView:(NSView *)view {
    [self autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsZero excludingEdge:ALEdgeTop];
}

- (void)pinToLeftOfView:(NSView *)view {
    [self autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsZero excludingEdge:ALEdgeRight];
}

- (void)pinToRightOfView:(NSView *)view {
    [self autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsZero excludingEdge:ALEdgeLeft];
}

@end


@implementation SearchField

- (instancetype)init {
    self = [super init];
    
    NSColor *backgroundColor = [NSColor colorWithDeviceHue:0.31 saturation:0.00 brightness:0.20 alpha:1.00];
    
    self.centersPlaceholder = NO;
//    self.drawsBackground = YES;
    self.focusRingType = NSFocusRingTypeNone;
//    self.wantsLayer = YES;
//    self.backgroundColor = backgroundColor;
//    self.layer.backgroundColor = [backgroundColor CGColor];
//    self.layer.borderColor = [backgroundColor CGColor];
//    self.layer.borderWidth = 1;
//    self.layer.cornerRadius = 4;
    
    return self;
}

@end


//@implementation Label
//
//- (instancetype)init {
//    self = [NSTextField la
//}
//
//@end
