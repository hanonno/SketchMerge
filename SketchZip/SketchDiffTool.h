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


@interface SketchDiff : NSObject

@property (strong) NSArray *insertOperations;
@property (strong) NSArray *updateOperations;
@property (strong) NSArray *deleteOperations;
@property (strong) NSArray *ignoreOperations;
@property (strong) NSArray *allOperations;

@end


@interface SketchDiffTool : NSObject

@property (strong) NSString             *sketchToolPath;
@property (strong) NSOperationQueue     *artboardImageQueue;

- (NSDictionary *)artboardsForFileWithURL:(NSURL *)fileURL;
- (NSDictionary *)pagesFromFileAtURL:(NSURL *)fileURL;

- (void)generatePreviewsForArtboards:(NSArray *)artboards;

- (SketchDiff *)diffFromFile:(SketchFile *)fileA to:(SketchFile *)fileB;
//- (NSArray *)operationsFromRoot:(NSURL *)fileRoot toA:(NSURL *)fileA toB:(NSURL *)fileB;

@end


@interface CoreSyncTransaction (Sketch)

- (NSString *)pageID;

@end
