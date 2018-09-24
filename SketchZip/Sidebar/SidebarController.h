//
//  SidebarController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 24/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TDView : NSView

@property (strong) NSColor  *backgroundColor;
@property (assign) CGFloat  cornerRadius;

@end


@interface SidebarRow : TDView

@property (strong) NSImageView  *iconView;
@property (strong) NSTextField  *titleLabel;
@property (strong) TDView       *highlightView;

@property (assign) BOOL         highlighted;

@end


@interface SidebarController : NSViewController

@property (strong) NSStackView  *stackView;

@end
