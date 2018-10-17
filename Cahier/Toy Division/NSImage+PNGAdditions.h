//
//  NSImage+PNGAdditions.h
//  vault
//
//  Created by Emiel van Liere on 03/09/15.
//  Copyright (c) 2015 ysberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface NSImage (PNGAdditions)

- (BOOL)writePNGToURL:(NSURL*)URL outputSizeInPixels:(NSSize)outputSizePx error:(NSError*__autoreleasing*)error;
- (CGImageRef)scaleImageToSizeInPixels:(NSSize)outputSizePx;
- (NSImage *)scaleToSize:(NSSize)size;
@end
