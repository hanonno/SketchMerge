//
//  TDTheme.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 26/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PureLayout/PureLayout.h>


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

+ (NSColor *)browserBackgroundColor;

+ (NSColor *)accentColor;

@end


@interface View : NSView

@property (assign) CGFloat  cornerRadius;
@property (strong) NSColor  *backgroundColor;


+ (instancetype)horizontalDivider;
+ (instancetype)verticalDivider;

- (instancetype)initWithBackgroundColor:(NSColor *)backgroundColor;

- (void)pinToBottomOfView:(NSView *)view;
- (void)pinToBottomOfView:(NSView *)view withInset:(CGFloat)inset;
- (void)pinToLeftOfView:(NSView *)view;
- (void)pinToRightOfView:(NSView *)view;

@end


@interface Control : NSControl

@property (assign) BOOL     selected;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end


@interface Button : Control

@property (strong) View         *backgroundView;
@property (strong) NSTextField  *titleLabel;

@end


@interface SearchField : NSSearchField

@end


@interface Label : NSTextField


@end
