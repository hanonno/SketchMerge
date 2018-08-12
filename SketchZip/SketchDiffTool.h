//
//  SketchFile.h
//  SketchZip
//
//  Created by Hanno on 05/07/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CoreSyncTransaction.h"
#import "SketchPage.h"


@interface SketchArtboardPreviewOperation : NSOperation

@property (strong) NSString         *sketchToolPath;
@property (strong) NSString         *filePath;
@property (strong) SketchArtboard   *artboard;

- (id)initWithFilePath:(NSString *)filePath artboard:(SketchArtboard *)artboard;

@end


@interface SketchDiffTool : NSObject

@property (strong) NSString             *sketchToolPath;
@property (strong) NSOperationQueue     *artboardImageQueue;

- (NSDictionary *)artboardsForFileWithURL:(NSURL *)fileURL;
- (NSDictionary *)pagesFromFileAtURL:(NSURL *)fileURL;

- (NSImage *)imageForArtboardWithID:(NSString *)artboardID inFileWithURL:(NSURL *)fileURL maxSize:(CGSize)maxSize;
- (void)generatePreviewsForArtboards:(NSArray *)artboards fromFileWithURL:(NSURL *)fileURL;

- (NSArray *)diffFromFile:(NSURL *)oldFile to:(NSURL *)newFile;

@end


@interface CoreSyncTransaction (Sketch)

- (NSString *)pageID;

@end
