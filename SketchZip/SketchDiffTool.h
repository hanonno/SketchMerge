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

@property (strong) NSArray          *insertOperations;
@property (strong) NSArray          *updateOperations;
@property (strong) NSArray          *deleteOperations;
@property (strong) NSArray          *ignoreOperations;
@property (strong) NSArray          *allOperations;
@property (strong) NSDictionary     *operationsById;

- (SketchLayerChange *)operationWithId:(NSString *)objectId;

- (void)removeOperation:(SketchLayerChange *)operation;

@end


@interface SketchDiffTool : NSObject

@property (strong) NSString             *sketchToolPath;
@property (strong) NSOperationQueue     *artboardImageQueue;

- (NSDictionary *)artboardsForFileWithURL:(NSURL *)fileURL;
- (NSDictionary *)pagesFromFileAtURL:(NSURL *)fileURL;

- (void)generatePreviewsForArtboards:(NSArray *)artboards;

- (SketchDiff *)diffFromFile:(SketchFile *)fileA to:(SketchFile *)fileB;
- (SketchChangeSet *)changesFromFile:(SketchFile *)fileA to:(SketchFile *)fileB;
//- (NSArray *)operationsFromRoot:(NSURL *)fileRoot toA:(NSURL *)fileA toB:(NSURL *)fileB;

@end


@interface SketchMergeConflict : NSObject

@property (assign) SketchResolutionType       type;
@property (strong) SketchLayerChange          *operationA;
@property (strong) SketchLayerChange          *operationB;

@end


@interface SketchMergeTool : NSObject

@property (strong) SketchFile   *fileA;
@property (strong) SketchFile   *fileB;

@property (strong) SketchDiff   *diffA;
@property (strong) SketchDiff   *diffB;
@property (strong) NSArray      *conflicts;

- (id)initWithDiffA:(SketchDiff *)diffA diffB:(SketchDiff *)diffB;



@end



@interface CoreSyncTransaction (Sketch)

- (NSString *)pageID;

@end
