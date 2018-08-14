//
//  SketchOperationTypeIndicator.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 14/08/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchOperationTypeIndicator.h"


@implementation NSColor (SketchOperationType)

+ (NSColor *)colorForOperationType:(SketchOperationType)type {
    NSColor *color = [NSColor lightGrayColor];
    
    switch (type) {
        case SketchOperationTypeInsert:
            color = [NSColor colorWithRed:0.295 green:0.849 blue:0.39 alpha:1];
            break;
            
        case SketchOperationTypeUpdate:
            color = [NSColor colorWithRed:0 green:0.476 blue:0.998 alpha:1];
            break;
            
        case SketchOperationTypeDelete:
            color = [NSColor colorWithRed:0.998 green:0.231 blue:0.187 alpha:1];
            break;
            
        case SketchOperationTypeNone:
            color = [NSColor colorWithRed:0.900 green:0.900 blue:0.900 alpha:1];
            break;
    }
    
    return color;
}

@end


@implementation SketchOperationTypeIndicator

@synthesize type = _type;

- (instancetype)init {
    self = [super init];
    
    self.wantsLayer = YES;
    self.layer.cornerRadius = 6;
    self.layer.backgroundColor = [[NSColor lightGrayColor] CGColor];
    
    return self;
}

- (SketchOperationType)type {
    return _type;
}

- (void)setType:(SketchOperationType)type {
    _type = type;
    self.layer.backgroundColor = [[NSColor colorForOperationType:type] CGColor];
}

@end
