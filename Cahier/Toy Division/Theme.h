//
//  TDTheme.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 26/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class Theme;


@interface Theme : NSObject

+ (Theme *)currentTheme;

- (NSColor *)titleTextColor;
- (NSColor *)subtitleTextColor;
- (NSColor *)bodyTextColor;

- (NSColor *)backgroundColor;
- (NSColor *)headerBackgroundColor;
- (NSColor *)dividerColor;

- (NSColor *)highlightColor;

@end


@interface NSColor (Cahier)

+ (NSColor *)titleTextColor;
+ (NSColor *)subtitleTextColor;
+ (NSColor *)bodyTextColor;

+ (NSColor *)backgroundColor;
+ (NSColor *)headerBackgroundColor;
+ (NSColor *)dividerColor;

+ (NSColor *)highlightColor;

//

+ (NSColor *)sidebarTextColor;
+ (NSColor *)sidebarBackgroundColor;
+ (NSColor *)selectedSidebarItemColor;

@end


@interface BackgroundView : NSView

@property (strong) NSColor  *backgroundColor;

- (instancetype)initWithBackgroundColor:(NSColor *)backgroundColor;

@end


@interface SearchField : NSSearchField

@end
