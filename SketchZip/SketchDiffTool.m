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

@implementation SketchDiff

- (SketchLayerChange *)operationWithId:(NSString *)objectId {
    return [self.operationsById objectForKey:objectId];
}

- (void)removeOperation:(SketchLayerChange *)operation {
    
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
    
    self.artboardImageQueue = [[NSOperationQueue alloc] init];
    
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

- (SketchDiff *)operationsFromPageA:(SketchPage *)pageA toPageB:(SketchPage *)pageB {
    NSDictionary *layersA = pageA.layers;
    NSDictionary *layersB = pageB.layers;
    
    NSMutableSet *layerIds = [[NSMutableSet alloc] init];
    [layerIds addObjectsFromArray:[layersA allKeys]];
    [layerIds addObjectsFromArray:[layersB allKeys]];

    NSMutableArray *insertOperations = [[NSMutableArray alloc] init];
    NSMutableArray *updateOperations = [[NSMutableArray alloc] init];
    NSMutableArray *deleteOperations = [[NSMutableArray alloc] init];
    NSMutableArray *ignoreOperations = [[NSMutableArray alloc] init];
    NSMutableArray *allOperations = [[NSMutableArray alloc] init];
    NSMutableDictionary *operationsById = [[NSMutableDictionary alloc] init];
    
    for (NSString *layerId in layerIds) {
        NSLog(@"artboard: %@", layerId);
        
        SketchLayer *layerA = layersA[layerId];
        SketchLayer *layerB = layersB[layerId];
        
        if(layerA == nil && layerB != nil) {
            NSLog(@"Layer added!");
            
            SketchLayerChange *operation = [[SketchLayerChange alloc] init];
            operation.type = SketchOperationTypeInsert;
            operation.layerB = layerB;
            operation.objectId = operation.layerB.objectId;
            [insertOperations addObject:operation];
            [allOperations addObject:operation];
            [operationsById setObject:operation forKey:operation.objectId];
        }
        
        else if(layerB == nil && layerA != nil) {
            NSLog(@"Layer deleted!");
            
            SketchLayerChange *operation = [[SketchLayerChange alloc] init];
            operation.type = SketchOperationTypeDelete;
            operation.layerA = layerA;
            operation.objectId = operation.layerA.objectId;
            [deleteOperations addObject:operation];
            [allOperations addObject:operation];
            [operationsById setObject:operation forKey:operation.objectId];
        }
        
        else {
            NSArray *diff = [CoreSync diffAsTransactions:layerA.JSON :layerB.JSON];
            
            if(diff && [diff count]) {
                NSLog(@"Layer updated!");
                SketchLayerChange *operation = [[SketchLayerChange alloc] init];
                operation.type = SketchOperationTypeUpdate;
                operation.layerA = layerA;
                operation.layerB = layerB;
                operation.objectId = operation.layerB.objectId;
                [updateOperations addObject:operation];
                [allOperations addObject:operation];
                [operationsById setObject:operation forKey:operation.objectId];
            }
            else {
                NSLog(@"Layer is the same!");
                SketchLayerChange *operation = [[SketchLayerChange alloc] init];
                operation.type = SketchOperationTypeIgnore;
                operation.layerA = layerA;
                operation.layerB = layerB;
                operation.objectId = operation.layerB.objectId;
                [ignoreOperations addObject:operation];
                [allOperations addObject:operation];
                [operationsById setObject:operation forKey:operation.objectId];
            }
        }
    }
    
    SketchDiff *diff = [[SketchDiff alloc] init];
    diff.insertOperations = insertOperations;
    diff.updateOperations = updateOperations;
    diff.deleteOperations = deleteOperations;
    diff.ignoreOperations = ignoreOperations;
    diff.allOperations = allOperations;
    diff.operationsById = operationsById;
    
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
            pageChange.diff = [self operationsFromPageA:nil toPageB:pageB];
            [pageChanges addObject:pageChange];
        }
        
        else if(pageA != nil && pageB == nil) {
            NSLog(@"Page deleted!");

            SketchPageChange *pageChange = [[SketchPageChange alloc] initWithPage:pageA operationType:SketchOperationTypeDelete];
            pageChange.diff = [self operationsFromPageA:pageA toPageB:nil];
            [pageChanges addObject:pageChange];
        }
        
        else {
            NSLog(@"Page updated!");            
            SketchDiff *diff = [self operationsFromPageA:pageA toPageB:pageB];
            
            if(diff.allOperations.count > 0) {
                SketchPageChange *pageChange = [[SketchPageChange alloc] initWithPage:pageA operationType:SketchOperationTypeUpdate];
                pageChange.diff = diff;
                [pageChanges addObject:pageChange];
            }
        }
    }

    SketchChangeSet *changeSet = [[SketchChangeSet alloc] init];
    
    changeSet.pageChanges = pageChanges;
    
    return changeSet;
}

//- (SketchDiff *)diffFromFile:(SketchFile *)fileA to:(SketchFile *)fileB {
//    NSDictionary *pagesA = fileA.pages;
//    NSDictionary *pagesB = fileB.pages;
//    
//    NSMutableArray *insertOperations = [[NSMutableArray alloc] init];
//    NSMutableArray *updateOperations = [[NSMutableArray alloc] init];
//    NSMutableArray *deleteOperations = [[NSMutableArray alloc] init];
//    NSMutableArray *ignoreOperations = [[NSMutableArray alloc] init];
//    NSMutableArray *allOperations = [[NSMutableArray alloc] init];
//    NSMutableDictionary *operationsById = [[NSMutableDictionary alloc] init];
//
//    NSMutableSet *pageIDs = [[NSMutableSet alloc] init];
//    
//    [pageIDs addObjectsFromArray:[pagesA allKeys]];
//    [pageIDs addObjectsFromArray:[pagesB allKeys]];
//    
//    for (NSString *pageID in pageIDs) {
//        SketchPage *pageA = pagesA[pageID];
//        SketchPage *pageB = pagesB[pageID];
//
//        if(pageA == nil && pageB != nil) {
//            NSLog(@"Page added!");
//            pageB.operationType = SketchOperationTypeInsert;
//            pageB.diff = [self operationsFromPageA:nil toPageB:pageB];
//            [insertOperations addObject:pageB];
//            [allOperations addObject:pageB];
//            [operationsById setObject:pageB forKey:pageB.objectId];
//        }
//
//        else if(pageB == nil && pageA != nil) {
//            NSLog(@"Page deleted!");
//            pageA.operationType = SketchOperationTypeDelete;
//            pageA.diff = [self operationsFromPageA:pageA toPageB:nil];
//            [deleteOperations addObject:pageA];
//            [allOperations addObject:pageA];
//            [operationsById setObject:pageA forKey:pageA.objectId];
//        }
//        
//        else {
//            NSLog(@"Page updated!");
//            pageA.operationType = SketchOperationTypeUpdate;
//            pageB.operationType = SketchOperationTypeUpdate;
//            pageB.diff = [self operationsFromPageA:pageA toPageB:pageB];
//            [updateOperations addObject:pageB];
//            [allOperations addObject:pageB];
//            [operationsById setObject:pageB forKey:pageB.objectId];
//        }
//    }
//    
//    SketchDiff *diff = [[SketchDiff alloc] init];
//    diff.insertOperations = insertOperations;
//    diff.updateOperations = updateOperations;
//    diff.deleteOperations = deleteOperations;
//    diff.ignoreOperations = ignoreOperations;
//    diff.allOperations = allOperations;
//    diff.operationsById = operationsById;
//    
//    return diff;
//}

@end


@implementation SketchMergeConflict

@end


@implementation SketchMergeTool

- (id)initWithDiffA:(SketchDiff *)diffA diffB:(SketchDiff *)diffB {
    self = [super init];
    
    _diffA = diffA;
    _diffB = diffB;
    
    [self detectConflicts];
    
    return self;
}

- (void)detectConflicts {
    NSMutableSet *objectIds = [[NSMutableSet alloc] init];
    
    [objectIds addObjectsFromArray:self.diffA.operationsById.allKeys];
    [objectIds addObjectsFromArray:self.diffB.operationsById.allKeys];
    
    NSMutableArray *conflicts = [[NSMutableArray alloc] init];
    
    for (NSString *objectId in objectIds) {
        SketchLayerChange *operationA = [self.diffA operationWithId:objectId];
        SketchLayerChange *operationB = [self.diffB operationWithId:objectId];
        
        if(operationA != nil && operationB != nil) {
            // There can only be a conflict if both diffs have an operation
            if(operationA.type == SketchOperationTypeDelete && operationB.type == SketchOperationTypeUpdate) {
                // We should update with operationB
                [self.diffA removeOperation:operationA];
            }
            else if(operationA.type == SketchOperationTypeUpdate && operationB.type == SketchOperationTypeDelete) {
                // We should update with operationA
                [self.diffB removeOperation:operationB];
            }
            else if(operationA.type == SketchOperationTypeUpdate && operationB.type == SketchOperationTypeUpdate) {
                // Both updated, so now we have a conflict
                SketchMergeConflict *conflict = [[SketchMergeConflict alloc] init];
                conflict.operationA = operationA;
                conflict.operationB = operationB;
                
                [conflicts addObject:conflict];
            }
        }
    }
    
    self.conflicts = conflicts;
}

@end


@implementation CoreSyncTransaction (Sketch)

- (NSString *)pageID {
    NSArray *parts = [self.keyPath componentsSeparatedByString:@"/"];
    return [parts objectAtIndex:1];
}

@end
