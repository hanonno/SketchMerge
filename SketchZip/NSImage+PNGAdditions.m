//
//  NSImage+PNGAdditions.m
//  vault
//
//  Created by Emiel van Liere on 03/09/15.
//  Copyright (c) 2015 ysberg. All rights reserved.
//

#import "NSImage+PNGAdditions.h"

@implementation NSImage (PNGAdditions)

- (BOOL)writePNGToURL:(NSURL*)URL outputSizeInPixels:(NSSize)outputSizePx error:(NSError*__autoreleasing*)error
{
    BOOL result = YES;
    
    NSImage *scaledImage = self;
    if (!CGSizeEqualToSize(outputSizePx, self.size)) {
        scaledImage = [self scaleToSize:outputSizePx];
    }
    
    NSData *imageData = [scaledImage TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:@{}];
    result = [imageData writeToURL:URL atomically:NO];
    
    return result;
}

- (CGImageRef)scaleImageToSizeInPixels:(NSSize)outputSizePx
{
    NSRect proposedRect = NSMakeRect(0.0, 0.0, floor(outputSizePx.width), floor(outputSizePx.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef cgContext = CGBitmapContextCreate(NULL, proposedRect.size.width, proposedRect.size.height, 8, 4*proposedRect.size.width, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithGraphicsPort:cgContext flipped:NO];
    CGContextRelease(cgContext);
    CGImageRef cgImage = [self CGImageForProposedRect:&proposedRect context:context hints:nil];
    
    return cgImage;
}

- (NSImage *)scaleToSize:(NSSize)size {
    
    NSDictionary* sourceOptions = @{(id)kCGImageSourceShouldCache: (id) kCFBooleanFalse};
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)[self TIFFRepresentation],(CFDictionaryRef)sourceOptions);
    
    // Create a thumbnail without caching the decompressed result:
    NSDictionary* thumbOptions = @{(id)kCGImageSourceShouldCache: (id)kCFBooleanFalse,
                                   (id)kCGImageSourceCreateThumbnailWithTransform: (id)kCFBooleanTrue,
                                   (id)kCGImageSourceCreateThumbnailFromImageIfAbsent:  (id)kCFBooleanTrue,
                                   (id)kCGImageSourceCreateThumbnailFromImageAlways: (id)kCFBooleanTrue, // Otherwise thumbnail is going to be too small
                                   (id)kCGImageSourceThumbnailMaxPixelSize:[NSNumber numberWithInteger:size.width]};
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source,0,(CFDictionaryRef)thumbOptions);
    CFRelease(source);
    
    NSImage *image = nil;
    if (imageRef) {
        image = [[NSImage alloc] initWithCGImage:imageRef size:NSMakeSize(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef))];
    }
    CGImageRelease(imageRef);

    return image;
}

@end
