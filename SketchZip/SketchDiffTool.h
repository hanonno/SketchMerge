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



@interface SketchLayerChange : NSObject

@property (readonly) NSString                       *objectId;
@property (nonatomic, assign) SketchOperationType   operationType;
@property (nonatomic, strong) SketchLayer           *layer;
@property (nonatomic, strong) NSImage               *previewImage;

- (void)applyToPage:(SketchPage *)page;

@end


@interface SketchLayerDiff : NSObject

@property (strong) NSMutableArray          *orderedChanges;
@property (strong) NSMutableDictionary     *changesById;

- (SketchLayerChange *)layerChangeWithId:(NSString *)objectId;
- (void)removeChangeWithId:(NSString *)objectId;

@end


@interface SketchPageChange : NSObject

- (id)initWithPage:(SketchPage *)page operationType:(SketchOperationType)operationType;

@property (strong) SketchPage           *page;
@property (assign) SketchOperationType  operationType;
@property (assign) SketchResolutionType resolutionType;

@property (strong) SketchLayerDiff      *layerDiff;

- (void)applyToFile:(SketchFile *)file;

@end



@interface SketchChangeSet : NSObject

@property (strong) NSMutableArray *pageChanges;
@property (strong) NSMutableArray *imageChanges;

- (NSArray *)pageIds;
- (SketchPageChange *)pageChangeWithId:(NSString *)pageId;

@end



@interface SketchDiffTool : NSObject

@property (strong) NSString             *sketchToolPath;

- (NSDictionary *)artboardsForFileWithURL:(NSURL *)fileURL;
- (NSDictionary *)pagesFromFileAtURL:(NSURL *)fileURL;

- (void)generatePreviewsForArtboards:(NSArray *)artboards;

//- (SketchDiff *)diffFromFile:(SketchFile *)fileA to:(SketchFile *)fileB;
- (SketchChangeSet *)changesFromFile:(SketchFile *)fileA to:(SketchFile *)fileB;
//- (NSArray *)operationsFromRoot:(NSURL *)fileRoot toA:(NSURL *)fileA toB:(NSURL *)fileB;

@end



@interface SketchMergeOperation : NSObject

@property (assign) SketchResolutionType       resolutionType;

@property (readonly) SketchOperationType      operationType;
@property (readonly) NSString                 *objectName;
@property (readonly) NSString                 *objectClass;

@property (strong) SketchLayerChange          *layerChangeA;
@property (strong) SketchLayerChange          *layerChangeB;

- (void)applyToPage:(SketchPage *)page;

@end



@interface SketchMergeTool : NSObject

@property (strong) SketchFile        *fileO;
@property (strong) SketchFile        *fileA;
@property (strong) SketchFile        *fileB;

@property (strong) SketchChangeSet   *changeSetA;
@property (strong) SketchChangeSet   *changeSetB;

@property (strong) NSMutableArray    *pageChanges;
@property (strong) NSMutableArray    *operations;

- (id)initWithOrigin:(SketchFile *)fileO fileA:(SketchFile *)fileA fileB:(SketchFile *)fileB;

- (void)applyChanges;

@end



@interface CoreSyncTransaction (Sketch)

- (NSString *)pageID;

@end
