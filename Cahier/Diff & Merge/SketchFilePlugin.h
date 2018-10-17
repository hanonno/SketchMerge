//
//  SketchFilePlugin.h
//  vault
//
//  Created by Emiel van Liere on 02/09/15.
//  Copyright (c) 2015 ysberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SketchFilePlugin : NSObject

@property (nonatomic, assign) NSInteger priority;

@property (nonatomic, assign) BOOL cacheable;

- (NSImage *)imageForFileWithURL:(NSURL *)fileURL maxSize:(CGSize)maxSize;
- (NSImage *)imageForArtboardWithID:(NSString *)artboardID inFileWithURL:(NSURL *)fileURL maxSize:(CGSize)maxSize;

@end
