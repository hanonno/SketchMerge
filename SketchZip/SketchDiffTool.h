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


typedef enum : NSUInteger {
    SketchOperationTypeInsert,
    SketchOperationTypeUpdate,
    SketchOperationTypeDelete,
    SketchOperationTypeIgnore
} SketchOperationType;


typedef enum : NSUInteger {
    SketchResolutionTypeA,
    SketchResolutionTypeB,
    SketchResolutionTypeConflict,
    SketchResolutionTypeIgnore
} SketchResolutionType;



@interface SKLayerOperation : NSObject

@property (readonly) NSString                       *objectId;
@property (nonatomic, assign) SketchOperationType   operationType;
@property (nonatomic, strong) SketchLayer           *layer;
@property (nonatomic, strong) NSImage               *previewImage;

- (void)applyToPage:(SketchPage *)page;

@end


@interface SKLayerMergeOperation : NSObject

@property (assign) SketchResolutionType       resolutionType;

@property (strong) SKLayerOperation          *layerOperationA;
@property (strong) SKLayerOperation          *layerOperationB;

- (void)applyToPage:(SketchPage *)page;

// Shortcuts
@property (readonly) NSString                 *objectId;
@property (readonly) SketchLayer              *layer;
@property (readonly) NSString                 *objectName;
@property (readonly) NSString                 *objectClass;
@property (readonly) SketchOperationType      operationType;

@end


@interface SKPageOperation : NSObject

- (id)initWithPage:(SketchPage *)page operationType:(SketchOperationType)operationType;

@property (strong) SketchPage           *page;
@property (assign) SketchOperationType  operationType;
@property (assign) SketchResolutionType resolutionType;
@property (strong) NSMutableArray       *operations;

- (NSArray *)layerIds;

- (SKLayerOperation *)layerOperationWithId:(NSString *)objectId;

- (void)applyToFile:(SketchFile *)file;

@end



@interface SketchFileOperation : NSObject

@property (strong) NSMutableArray *pageOperations;
@property (strong) NSMutableArray *imageOperations;

- (NSArray *)pageIds;
- (SKPageOperation *)pageChangeWithId:(NSString *)pageId;

@end



@interface SketchDiffTool : NSObject

@property (strong) NSString             *sketchToolPath;

- (NSDictionary *)artboardsForFileWithURL:(NSURL *)fileURL;
- (NSDictionary *)pagesFromFileAtURL:(NSURL *)fileURL;

- (void)generatePreviewsForArtboards:(NSArray *)artboards;

//- (SketchDiff *)diffFromFile:(SketchFile *)fileA to:(SketchFile *)fileB;
- (SketchFileOperation *)changesFromFile:(SketchFile *)fileA to:(SketchFile *)fileB;
//- (NSArray *)operationsFromRoot:(NSURL *)fileRoot toA:(NSURL *)fileA toB:(NSURL *)fileB;

@end






@interface SketchMergeTool : NSObject

@property (strong) SketchFile               *fileO;
@property (strong) SketchFile               *fileA;
@property (strong) SketchFile               *fileB;

@property (strong) SketchFileOperation      *changeSetA;
@property (strong) SketchFileOperation      *changeSetB;

@property (strong) NSMutableArray           *pageOperations;
@property (strong) NSMutableArray           *operations;

- (id)initWithOrigin:(SketchFile *)fileO fileA:(SketchFile *)fileA fileB:(SketchFile *)fileB;

- (void)applyChanges;

@end



@interface CoreSyncTransaction (Sketch)

- (NSString *)pageID;

@end
