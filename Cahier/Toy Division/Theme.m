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
    return [NSColor colorNamed:@"browserBackgroundColor"];
    return [NSColor colorWithDeviceHue:0.31 saturation:0.00 brightness:0.04 alpha:1.00];
    return [NSColor colorWithDeviceHue:0.65 saturation:0.15 brightness:0.19 alpha:1.00];
}

+ (NSColor *)accentColor {
    return [NSColor controlAccentColor];
}

@end


@implementation View

@synthesize cornerRadius = _cornerRadius, backgroundColor = _backgroundColor, borderWidth = _borderWidth, borderColor = _borderColor;

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

- (CGFloat)cornerRadius {
    return _cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (NSColor *)backgroundColor {
    return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.layer.backgroundColor = [_backgroundColor CGColor];
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (NSColor *)borderColor {
    return _borderColor;
}

- (void)setBorderColor:(NSColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = [_borderColor CGColor];
}

- (void)updateLayer {
    self.layer.backgroundColor = [_backgroundColor CGColor];
    self.layer.borderColor = [_borderColor CGColor];
}

- (void)pinToBottomOfView:(NSView *)view {
    [self pinToBottomOfView:view withInset:0];
}

- (void)pinToBottomOfView:(NSView *)view withInset:(CGFloat)inset {
    [self autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, inset, 0, inset) excludingEdge:ALEdgeTop];
}

- (void)pinToLeftOfView:(NSView *)view {
    [self autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsZero excludingEdge:ALEdgeRight];
}

- (void)pinToRightOfView:(NSView *)view {
    [self autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsZero excludingEdge:ALEdgeLeft];
}

@end


@implementation Control

@synthesize selected = _selected;

- (instancetype)init {
    self = [super initWithFrame:NSMakeRect(0, 0, 120, 120)];
    
    return self;
}

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"Mouse DOWN!");
}

- (void)mouseMoved:(NSEvent *)event {
    NSLog(@"Mouse MOVED!");
}

- (void)mouseDragged:(NSEvent *)event {
    NSLog(@"Mouse DRAGGED!");
}

- (void)mouseUp:(NSEvent *)event {
    NSLog(@"Mouse UP!");
    
    [self sendAction:self.action to:self.target];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    _selected = selected;
}

@end


@implementation Button

- (instancetype)init {
    self = [super init];
    
    _backgroundView = [[View alloc] initWithBackgroundColor:[NSColor accentColor]];
    _backgroundView.cornerRadius = 11;
    [self addSubview:_backgroundView];
    
    _titleLabel = [NSTextField labelWithString:@"Title"];
    [self addSubview:_titleLabel];
    
    // Autolayout
    [_backgroundView autoPinEdgesToSuperviewEdges];
    [_titleLabel autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(2, 10, 3, 10)];

    [self setSelected:NO animated:NO];
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if(selected) {
        self.titleLabel.textColor = [NSColor browserBackgroundColor];
        self.backgroundView.backgroundColor = [NSColor accentColor];
    }
    else {
        self.titleLabel.textColor = [NSColor secondaryLabelColor];
        self.backgroundView.backgroundColor = [NSColor dividerColor];
    }
}

@end

@interface FilterField ()

@property (strong) NSLayoutConstraint   *widthLayoutConstraint;

@end


@implementation FilterField

- (instancetype)init {
    self = [super init];
    
    _backgroundView = [[View alloc] initWithBackgroundColor:[NSColor browserBackgroundColor]];
    _backgroundView.borderColor = [NSColor dividerColor];
    _backgroundView.borderWidth = 1;
    _backgroundView.cornerRadius = 11;
    [self addSubview:_backgroundView];
    
    _filterTextField = [[NSTextField alloc] init];
    _filterTextField.focusRingType = NSFocusRingTypeNone;
    _filterTextField.drawsBackground = NO;
    _filterTextField.backgroundColor = [NSColor clearColor];
    _filterTextField.bordered = NO;
    _filterTextField.font = [NSFont systemFontOfSize:13 weight:NSFontWeightRegular];
    _filterTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_filterTextField];
    
    // Autolayout
    [_backgroundView autoPinEdgesToSuperviewEdges];
    [_filterTextField autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(2, 11, 0, 11)];
    
    _widthLayoutConstraint = [self autoSetDimension:ALDimensionWidth toSize:22];
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected];
    
    if(selected) {
        self.widthLayoutConstraint.constant = 160;
    }
    else {
        self.widthLayoutConstraint.constant = 22;
    }        
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
