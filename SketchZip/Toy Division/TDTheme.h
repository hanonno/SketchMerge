//
//  TDTheme.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 26/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class TDTheme;


@interface TDTheme : NSObject

+ (TDTheme *)currentTheme;

- (NSColor *)titleTextColor;
- (NSColor *)subtitleTextColor;
- (NSColor *)bodyTextColor;

- (NSColor *)backgroundColor;
- (NSColor *)headerBackgroundColor;
- (NSColor *)dividerColor;

- (NSColor *)highlightColor;

@end


@interface NSColor (TDTheme)

+ (NSColor *)titleTextColor;
+ (NSColor *)subtitleTextColor;
+ (NSColor *)bodyTextColor;

+ (NSColor *)backgroundColor;
+ (NSColor *)headerBackgroundColor;
+ (NSColor *)dividerColor;

+ (NSColor *)highlightColor;

@end
