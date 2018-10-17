//
//  TDTheme.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 26/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "TDTheme.h"

@implementation TDTheme

+ (TDTheme *)currentTheme {
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



@implementation NSColor (TDTheme)

+ (NSColor *)titleTextColor {
    return [[TDTheme currentTheme] titleTextColor];
}

+ (NSColor *)subtitleTextColor {
    return [[TDTheme currentTheme] subtitleTextColor];
}

+ (NSColor *)bodyTextColor {
    return [[TDTheme currentTheme] bodyTextColor];
}

+ (NSColor *)backgroundColor {
    return [[TDTheme currentTheme] backgroundColor];
}

+ (NSColor *)headerBackgroundColor {
    return [[TDTheme currentTheme] headerBackgroundColor];
}

+ (NSColor *)dividerColor {
    return [[TDTheme currentTheme] dividerColor];
}

+ (NSColor *)highlightColor {
    return [[TDTheme currentTheme] highlightColor];
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
