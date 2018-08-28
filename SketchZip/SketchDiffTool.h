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
    SketchResolutionTypeIgnore,
    SketchResolutionTypeUnknown,
} SketchResolutionType;



@interface SketchLayerChange : NSObject

@property (nonatomic, strong) NSString              *objectId;
@property (nonatomic, assign) SketchOperationType   type;

@property (nonatomic, strong) SketchLayer           *layerA;
@property (nonatomic, strong) NSImage               *previewImageA;

@property (nonatomic, strong) SketchLayer           *layerB;
@property (nonatomic, strong) NSImage               *previewImageB;

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



@interface SketchMergeConflict : NSObject

@property (assign) SketchResolutionType       type;
@property (strong) SketchLayerChange          *layerChangeA;
@property (strong) SketchLayerChange          *layerChangeB;

@end



@interface SketchMergeTool : NSObject

@property (strong) SketchChangeSet   *changeSetA;
@property (strong) SketchChangeSet   *changeSetB;

@property (strong) NSMutableArray    *conflicts;

- (id)initWithChangeSetA:(SketchChangeSet *)changeSetA changeSetB:(SketchChangeSet *)changeSetB;

@end



@interface CoreSyncTransaction (Sketch)

- (NSString *)pageID;

@end
