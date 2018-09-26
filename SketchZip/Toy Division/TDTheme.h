//
//  TDTheme.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 26/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class TDTheme;


@protocol TDTheme <NSObject>

- (void)applyTheme:(TDTheme *)theme;

- (NSColor *)titleTextColor;
- (NSColor *)subtitleTextColor;
- (NSColor *)bodyTextColor;

- (NSColor *)contentBackgroundColor;
- (NSColor *)headerBackgroundColor;

- (NSColor *)sidebarBackgroundColor;

- (NSColor *)highlightColor;

@end



@interface TDTheme : NSObject

- (void)registerForNotifications:(id <TDTheme>)object;

@end
