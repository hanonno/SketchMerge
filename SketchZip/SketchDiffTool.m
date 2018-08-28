//
//  SketchFile.m
//  SketchZip
//
//  Created by Hanno on 05/07/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchDiffTool.h"
#import "SSZipArchive.h"
#import "CoreSync.h"
#import "NSImage+PNGAdditions.h"
#import "SketchPage.h"


static const BOOL kLoggingEnabled = YES;


@implementation SketchLayerChange

@end


@implementation SketchPageChange

- (id)initWithPage:(SketchPage *)page operationType:(SketchOperationType)operationType {
    self = [super init];
    
    _page = page;
    _operationType = operationType;
    
    return self;
}

@end


@implementation SketchChangeSet

- (NSArray *)pageIds {
    NSMutableArray *pageIds = [[NSMutableArray alloc] init];
    
    for (SketchPageChange *pageChange in self.pageChanges) {
        [pageIds addObject:pageChange.page.objectId];
    }
    
    return pageIds;
}

- (SketchPageChange *)pageChangeWithId:(NSString *)pageId {
    for (SketchPageChange *pageChange in self.pageChanges) {
        if([pageChange.page.objectId isEqualToString:pageId]) {
            return pageChange;
        }
    }
    
    return nil;
}

@end


@implementation SketchLayerDiff

- (SketchLayerChange *)layerChangeWithId:(NSString *)objectId {
    return [self.changesById objectForKey:objectId];
}

- (void)removeChangeWithId:(NSString *)objectId {
    SketchLayerChange *layerChange = [self layerChangeWithId:objectId];
    [self.orderedChanges removeObject:layerChange];
    [self.changesById removeObjectForKey:objectId];
}

@end


@implementation SketchDiffTool

- (id)init {
    self = [super init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    self.sketchToolPath = @"/Applications/Sketch.app/Contents/Resources/sketchtool/bin/sketchtool";
    
    if (![fileManager fileExistsAtPath:self.sketchToolPath]) {
        self.sketchToolPath = [[NSBundle mainBundle] pathForResource:@"sketchtool/bin/sketchtool" ofType:nil];
    }
    
    return self;
}

- (NSDictionary *)artboardsForFileWithURL:(NSURL *)fileURL {
    // Extract Zip
    NSString *destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileURL.lastPathComponent];
    [SSZipArchive unzipFileAtPath:fileURL.path toDestination:destinationPath];
    
    if(kLoggingEnabled) NSLog(@"Destination: %@", destinationPath);
    
    // Load all page files
    NSString *pagesDirectory = [destinationPath stringByAppendingPathComponent:@"pages"];
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:pagesDirectory];
    
    NSString *currentPage = nil;
    NSMutableDictionary *artboardLookup = [[NSMutableDictionary alloc] init];
    
    while (currentPage = [directoryEnumerator nextObject]) {
        NSString *currentPagePath = [pagesDirectory stringByAppendingPathComponent:currentPage];
        if(kLoggingEnabled) NSLog(@"Current page: %@", currentPagePath);
        
        // Decode JSON
        NSData *pageData = [NSData dataWithContentsOfFile:currentPagePath];
        NSDictionary *pageJSON = [NSJSONSerialization JSONObjectWithData:pageData options:0 error:nil];
        NSArray *layers = pageJSON[@"layers"];
        
        if(layers == nil || layers.count == 0) {
            continue;
        }
        
        // Load artboards
        for (NSDictionary *layer in layers) {
            NSString *class = layer[@"_class"];
            NSString *objectID = layer[@"do_objectID"];
            
            if([class isEqualToString:@"artboard"]) {
                artboardLookup[objectID] = layer;
            }
        }
    }
    
    return artboardLookup;
}

- (NSDictionary *)pagesFromFileAtURL:(NSURL *)fileURL {
    // Extract Zip
    NSString *destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileURL.lastPathComponent];
    [SSZipArchive unzipFileAtPath:fileURL.path toDestination:destinationPath];
    
    if(kLoggingEnabled) NSLog(@"Source: %@", fileURL.path);
    if(kLoggingEnabled) NSLog(@"Destination: %@", destinationPath);
    
    // Load all page files
    NSString *pagesDirectory = [destinationPath stringByAppendingPathComponent:@"pages"];
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:pagesDirectory];
    
    if(kLoggingEnabled) NSLog(@"Pages: %@", pagesDirectory);

    NSString *currentFilename = nil;
//    NSMutableDictionary *artboardLookup = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *pagesLookup = [[NSMutableDictionary alloc] init];
    
    while (currentFilename = [directoryEnumerator nextObject]) {
        NSString *currentPagePath = [pagesDirectory stringByAppendingPathComponent:currentFilename];
        if(kLoggingEnabled) NSLog(@"Current page: %@", currentPagePath);
        
        // Decode JSON
        NSData *pageData = [NSData dataWithContentsOfFile:currentPagePath];
        NSDictionary *pageJSON = [NSJSONSerialization JSONObjectWithData:pageData options:0 error:nil];
        
        NSString *objectID =pageJSON[@"do_objectID"];
        
        pagesLookup[objectID] = pageJSON;
    }
    
    return pagesLookup;
}

- (void)generatePreviewsForArtboards:(NSArray *)operations {
    if(operations == nil || operations.count == 0) {
        return;
    }
    
    NSImage *image;
    NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    tempDir = [tempDir URLByAppendingPathComponent:[NSUUID UUID].UUIDString];
    NSString *filePath = nil;
    
    NSMutableArray *objectIds = [[NSMutableArray alloc] init];
    
    for (SketchLayerChange *operation in operations) {
        NSString *objectId = operation.objectId;
        
        if(filePath == nil) {
            filePath = operation.layerB.page.sketchFile.fileURL.path;
        }
        
        if(objectId != nil) {
            [objectIds addObject:objectId];
        }
    }
    
    // This should be improved, goes wrong mainly when generating previews from deleted artboards (we now always use the path from layerB)
    if(filePath == nil) {
        return;
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir.path withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:self.sketchToolPath];
    [task setArguments:@[
        @"export",
        @"artboards",
        filePath,
        [NSString stringWithFormat:@"--output=%@", tempDir.path],
        @"--use-id-for-name",
        [NSString stringWithFormat:@"--items=%@", [objectIds componentsJoinedByString:@","]]
    ]];
    
    NSPipe *outputPipe = [[NSPipe alloc] init];
    task.standardOutput = outputPipe;
    NSFileHandle *outputFile = outputPipe.fileHandleForReading;
    
    NSPipe *errorPipe = [[NSPipe alloc] init];
    task.standardError = errorPipe;
    NSFileHandle *errorFile = errorPipe.fileHandleForReading;
    
    [task launch];
    
    NSData *errorData = [errorFile readDataToEndOfFile];
    
    //    DDLogVerbose(@"SketchFilePlugin: sketchtool for %@ in %f ms", fileURL.relativeString, [now timeIntervalSinceNow]);
    
    NSLog(@"OUTPUT DIR: %@", tempDir);
    
    NSString *result;
    if (errorData.length == 0) {
        result = [[NSString alloc] initWithData:[outputFile readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        
        if ([result hasPrefix:@"Exported "]) {
            for (SketchLayerChange *operation in operations) {
                NSString *outputFilePath = [[tempDir.path stringByAppendingPathComponent:operation.objectId] stringByAppendingPathExtension:@"png"];
                image = [[NSImage alloc] initWithContentsOfFile:outputFilePath];
                operation.previewImageB = image;
            }
        }
    } else {
        result = [[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding];
        //        DDLogError(@"SketchFilePlugin error: %@", result);
    }
}

- (SketchLayerDiff *)layerDiffFromPageA:(SketchPage *)pageA toPageB:(SketchPage *)pageB {
    NSDictionary *layersA = pageA.layers;
    NSDictionary *layersB = pageB.layers;
    
    NSMutableSet *layerIds = [[NSMutableSet alloc] init];
    [layerIds addObjectsFromArray:[layersA allKeys]];
    [layerIds addObjectsFromArray:[layersB allKeys]];
    
    NSMutableArray *orderedChanges = [[NSMutableArray alloc] init];
    NSMutableDictionary *changesById = [[NSMutableDictionary alloc] init];

    for (NSString *layerId in layerIds) {
        NSLog(@"layer: %@", layerId);
        
        SketchLayer *layerA = layersA[layerId];
        SketchLayer *layerB = layersB[layerId];
        
        if(layerA == nil && layerB != nil) {
            NSLog(@"Layer added!");
            
            SketchLayerChange *layerChange = [[SketchLayerChange alloc] init];
            layerChange.operationType = SketchOperationTypeInsert;
            layerChange.layerB = layerB;
            layerChange.objectId = layerChange.layerB.objectId;
            [orderedChanges addObject:layerChange];
            [changesById setObject:layerChange forKey:layerChange.objectId];
        }
        
        else if(layerB == nil && layerA != nil) {
            NSLog(@"Layer deleted!");
            
            SketchLayerChange *layerChange = [[SketchLayerChange alloc] init];
            layerChange.operationType = SketchOperationTypeDelete;
            layerChange.layerA = layerA;
            layerChange.objectId = layerChange.layerA.objectId;
            [orderedChanges addObject:layerChange];
            [changesById setObject:layerChange forKey:layerChange.objectId];
        }
        
        else {
            NSArray *diff = [CoreSync diffAsTransactions:layerA.JSON :layerB.JSON];
            
            if(diff && [diff count]) {
                NSLog(@"Layer updated!");
                SketchLayerChange *layerChange = [[SketchLayerChange alloc] init];
                layerChange.operationType = SketchOperationTypeUpdate;
                layerChange.layerA = layerA;
                layerChange.layerB = layerB;
                layerChange.objectId = layerChange.layerB.objectId;
                [orderedChanges addObject:layerChange];
                [changesById setObject:layerChange forKey:layerChange.objectId];
            }
            else {
                NSLog(@"Layer is the same!");
                SketchLayerChange *layerChange = [[SketchLayerChange alloc] init];
                layerChange.operationType = SketchOperationTypeIgnore;
                layerChange.layerA = layerA;
                layerChange.layerB = layerB;
                layerChange.objectId = layerChange.layerB.objectId;
                [orderedChanges addObject:layerChange];
                [changesById setObject:layerChange forKey:layerChange.objectId];
            }
        }
    }
    
    SketchLayerDiff *diff = [[SketchLayerDiff alloc] init];
    diff.orderedChanges = orderedChanges;
    diff.changesById = changesById;
    
    return diff;
}

- (SketchChangeSet *)changesFromFile:(SketchFile *)fileA to:(SketchFile *)fileB {
    NSDictionary *pagesA = fileA.pages;
    NSDictionary *pagesB = fileB.pages;
    
    NSMutableSet *pageIds = [[NSMutableSet alloc] init];
    
    [pageIds addObjectsFromArray:[pagesA allKeys]];
    [pageIds addObjectsFromArray:[pagesB allKeys]];
    
    NSMutableArray *pageChanges = [[NSMutableArray alloc] init];
    
    for (NSString *pageId in pageIds) {
        SketchPage *pageA = pagesA[pageId];
        SketchPage *pageB = pagesB[pageId];
        
        if(pageA == nil && pageB != nil) {
            NSLog(@"Page added!");
            
            SketchPageChange *pageChange = [[SketchPageChange alloc] initWithPage:pageB operationType:SketchOperationTypeInsert];
            pageChange.layerDiff = [self layerDiffFromPageA:nil toPageB:pageB];
            [pageChanges addObject:pageChange];
        }
        
        else if(pageA != nil && pageB == nil) {
            NSLog(@"Page deleted!");

            SketchPageChange *pageChange = [[SketchPageChange alloc] initWithPage:pageA operationType:SketchOperationTypeDelete];
            pageChange.layerDiff = [self layerDiffFromPageA:pageA toPageB:nil];
            [pageChanges addObject:pageChange];
        }
        
        else {
            NSLog(@"Page updated!");            
            SketchLayerDiff *diff = [self layerDiffFromPageA:pageA toPageB:pageB];
            
            if(diff.orderedChanges.count > 0) {
                SketchPageChange *pageChange = [[SketchPageChange alloc] initWithPage:pageA operationType:SketchOperationTypeUpdate];
                pageChange.layerDiff = diff;
                [pageChanges addObject:pageChange];
            }
        }
    }

    SketchChangeSet *changeSet = [[SketchChangeSet alloc] init];
    
    changeSet.pageChanges = pageChanges;
    
    return changeSet;
}


@end


@implementation SketchMergeOperation

- (SketchOperationType)operationType {
    if(self.resolutionType == SketchResolutionTypeA) {
        return self.layerChangeA.operationType;
    }
    else if(self.resolutionType == SketchResolutionTypeB) {
        return self.layerChangeB.operationType;
    }
    
    return SketchOperationTypeIgnore;
}

- (NSString *)objectName {
    if(self.resolutionType == SketchResolutionTypeA) {
        return self.layerChangeA.layerA.name;
    }
    else if(self.resolutionType == SketchResolutionTypeB) {
        return self.layerChangeB.layerB.name;
    }
    else if(self.resolutionType == SketchResolutionTypeConflict) {
        return @"Conflicted";
    }

    return @"Something went wrong";
}

- (NSString *)objectClass {
    if(self.resolutionType == SketchResolutionTypeA) {
        return self.layerChangeA.layerA.className;
    }
    else if(self.resolutionType == SketchResolutionTypeB) {
        return self.layerChangeB.layerB.className;
    }
    else if(self.resolutionType == SketchResolutionTypeConflict) {
        return self.layerChangeB.layerB.className;
    }
    
    return @"Something went wrong";
}

@end



@implementation SketchMergeTool

- (id)initWithChangeSetA:(SketchChangeSet *)changeSetA changeSetB:(SketchChangeSet *)changeSetB {
    self = [super init];
    
    _changeSetA = changeSetA;
    _changeSetB = changeSetB;
    
//    _conflicts = [self conflictsFromPageChangeA:_changeSetA toPageChangeB:_changeSetB];

    NSMutableSet *pageIds = [[NSMutableSet alloc] init];
    [pageIds addObjectsFromArray:_changeSetA.pageIds];
    [pageIds addObjectsFromArray:_changeSetB.pageIds];
    
    self.operations = [[NSMutableArray alloc] init];
    
    for (NSString *pageId in pageIds) {
        SketchPageChange *pageChangeA = [_changeSetA pageChangeWithId:pageId];
        SketchPageChange *pageChangeB = [_changeSetB pageChangeWithId:pageId];
        
        if(pageChangeA != nil && pageChangeB != nil) {
            NSArray *operations = [self operationsFromPageChangeA:pageChangeA toPageChangeB:pageChangeB];
            
            if(operations.count > 0) {
                [self.operations addObjectsFromArray:operations];
            }
        }
    }

    return self;
}

- (NSArray *)operationsFromPageChangeA:(SketchPageChange *)pageChangeA toPageChangeB:(SketchPageChange *)pageChangeB {
    NSMutableSet *objectIds = [[NSMutableSet alloc] init];
    
    [objectIds addObjectsFromArray:pageChangeA.layerDiff.changesById.allKeys];
    [objectIds addObjectsFromArray:pageChangeB.layerDiff.changesById.allKeys];

    NSMutableArray *operations = [[NSMutableArray alloc] init];

    for (NSString *objectId in objectIds) {
        SketchLayerChange *layerChangeA = [pageChangeA.layerDiff layerChangeWithId:objectId];
        SketchLayerChange *layerChangeB = [pageChangeB.layerDiff layerChangeWithId:objectId];

        if(layerChangeA != nil && layerChangeB == nil) {
            NSLog(@"Layer added in A");
            SketchMergeOperation *operation = [[SketchMergeOperation alloc] init];
            operation.resolutionType = SketchResolutionTypeA;
            operation.layerChangeA = layerChangeA;
            [operations addObject:operation];
        }
        else if(layerChangeA == nil && layerChangeB != nil) {
            NSLog(@"Layer added in B");
            SketchMergeOperation *operation = [[SketchMergeOperation alloc] init];
            operation.resolutionType = SketchResolutionTypeB;
            operation.layerChangeB = layerChangeB;
            [operations addObject:operation];
        }
        else if (layerChangeA != nil && layerChangeB != nil) {
            // There can only be a conflict if both diffs have an operation
            if((layerChangeA.operationType == SketchOperationTypeDelete || layerChangeA.operationType == SketchOperationTypeIgnore) && layerChangeB.operationType == SketchOperationTypeUpdate) {
                NSLog(@"Layer updated in B");
                SketchMergeOperation *operation = [[SketchMergeOperation alloc] init];
                operation.resolutionType = SketchResolutionTypeB;
                operation.layerChangeA = layerChangeA;
                operation.layerChangeB = layerChangeB;
                [operations addObject:operation];
            }
            else if(layerChangeA.operationType == SketchOperationTypeUpdate && (layerChangeB.operationType == SketchOperationTypeDelete || layerChangeB.operationType == SketchOperationTypeIgnore)) {
                NSLog(@"Layer updated in A");
                // We should update with operationA
                SketchMergeOperation *operation = [[SketchMergeOperation alloc] init];
                operation.resolutionType = SketchResolutionTypeA;
                operation.layerChangeA = layerChangeA;
                operation.layerChangeB = layerChangeB;
                [operations addObject:operation];
            }
            else if(layerChangeA.operationType == SketchOperationTypeUpdate && layerChangeB.operationType == SketchOperationTypeUpdate) {
                NSLog(@"Layer updated in A & B");
                // Both updated, so now we have a conflict
                SketchMergeOperation *operation = [[SketchMergeOperation alloc] init];
                operation.resolutionType = SketchResolutionTypeConflict;
                operation.layerChangeA = layerChangeA;
                operation.layerChangeB = layerChangeB;
                [operations addObject:operation];
            }
        }
    }

    return operations;
}

@end


@implementation CoreSyncTransaction (Sketch)

- (NSString *)pageID {
    NSArray *parts = [self.keyPath componentsSeparatedByString:@"/"];
    return [parts objectAtIndex:1];
}

@end
