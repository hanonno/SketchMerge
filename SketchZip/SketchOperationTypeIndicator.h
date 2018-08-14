//
//  SketchOperationTypeIndicator.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 14/08/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SketchPage.h"


@interface NSColor (SketchOperationType)

+ (NSColor *)colorForOperationType:(SketchOperationType)type;

@end


@interface SketchOperationTypeIndicator : NSView

@property (assign) SketchOperationType type;

@end
