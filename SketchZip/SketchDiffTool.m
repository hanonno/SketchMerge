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

//- (void)generatePreviewsForArtboards:(NSArray *)artboards fromFileWithURL:(NSURL *)fileURL {
//    NSMutableArray *updatedArtboards = [[NSMutableArray alloc] init];
//    NSMutableArray *deletedArtboards = [[NSMutableArray alloc] init];
//    
//    for (SketchArtboard *artboard in artboards) {
//        NSString *artboardId = artboard.objectId;
//        
//        if(artboardId != nil) {
//            if(artboard.operationType == SketchOperationTypeDelete) {
//                [deletedArtboards addObject:artboard];
//            }
//            else {
//                [updatedArtboards addObject:artboardId];
//            }
//        }
//    }
//    
////    [self]
//}

- (void)generatePreviewsForArtboards:(NSArray *)operations {
    if(operations == nil || operations.count == 0) {
        return;
    }
    
    NSImage *image;
    NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    tempDir = [tempDir URLByAppendingPathComponent:[NSUUID UUID].UUIDString];
    NSString *filePath = nil;
    
    NSMutableArray *objectIds = [[NSMutableArray alloc] init];
    
    for (SketchOperation *operation in operations) {
        NSString *objectId = operation.objectId;
        
        if(filePath == nil) {
            filePath = operation.layerB.page.sketchFile.fileURL.path;
        }
        
        if(objectId != nil) {
            [objectIds addObject:objectId];
        }
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
            for (SketchOperation *operation in operations) {
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

- (NSArray *)operationsFromPageA:(SketchPage *)pageA toPageB:(SketchPage *)pageB {
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
    
    for (NSString *layerId in layerIds) {
        NSLog(@"artboard: %@", layerId);
        
        SketchLayer *layerA = layersA[layerId];
        SketchLayer *layerB = layersB[layerId];
        
        if(layerA == nil && layerB != nil) {
            NSLog(@"Layer added!");
            
            SketchOperation *operation = [[SketchOperation alloc] init];
            operation.type = SketchOperationTypeInsert;
            operation.layerB = layerB;
            operation.objectId = operation.layerB.objectId;
            [insertOperations addObject:operation];
            [allOperations addObject:operation];
        }
        
        else if(layerB == nil && layerA != nil) {
            NSLog(@"Layer deleted!");
            
            SketchOperation *operation = [[SketchOperation alloc] init];
            operation.type = SketchOperationTypeDelete;
            operation.layerA = layerA;
            operation.objectId = operation.layerA.objectId;
            [deleteOperations addObject:operation];
            [allOperations addObject:operation];
        }
        
        else {
            NSArray *diff = [CoreSync diffAsTransactions:layerA.JSON :layerB.JSON];
            
            if(diff && [diff count]) {
                NSLog(@"Layer updated!");
                SketchOperation *operation = [[SketchOperation alloc] init];
                operation.type = SketchOperationTypeUpdate;
                operation.layerA = layerA;
                operation.layerB = layerB;
                operation.objectId = operation.layerB.objectId;
                [updateOperations addObject:operation];
                [allOperations addObject:operation];
            }
            else {
                NSLog(@"Layer is the same!");
                SketchOperation *operation = [[SketchOperation alloc] init];
                operation.type = SketchOperationTypeIgnore;
                operation.layerA = layerA;
                operation.layerB = layerB;
                operation.objectId = operation.layerB.objectId;
                [ignoreOperations addObject:operation];
                [allOperations addObject:operation];
            }
        }
    }
    
    SketchDiff *diff = [[SketchDiff alloc] init];
    diff.insertOperations = insertOperations;
    diff.updateOperations = updateOperations;
    diff.deleteOperations = deleteOperations;
    diff.ignoreOperations = ignoreOperations;
    
    return allOperations;
}

- (SketchDiff *)diffFromFile:(SketchFile *)fileA to:(SketchFile *)fileB {
    NSDictionary *pagesA = fileA.pages;
    NSDictionary *pagesB = fileB.pages;
    
    NSMutableArray *insertOperations = [[NSMutableArray alloc] init];
    NSMutableArray *updateOperations = [[NSMutableArray alloc] init];
    NSMutableArray *deleteOperations = [[NSMutableArray alloc] init];
    NSMutableArray *ignoreOperations = [[NSMutableArray alloc] init];
    NSMutableArray *allOperations = [[NSMutableArray alloc] init];

    NSMutableSet *pageIDs = [[NSMutableSet alloc] init];
    
    [pageIDs addObjectsFromArray:[pagesA allKeys]];
    [pageIDs addObjectsFromArray:[pagesB allKeys]];
    
    for (NSString *pageID in pageIDs) {
        SketchPage *pageA = pagesA[pageID];
        SketchPage *pageB = pagesB[pageID];

        if(pageA == nil && pageB != nil) {
            NSLog(@"Page added!");
            pageB.operationType = SketchOperationTypeInsert;
            pageB.operations = [self operationsFromPageA:nil toPageB:pageB];
            [insertOperations addObject:pageB];
            [allOperations addObject:pageB];
        }
        
        else if(pageB == nil && pageA != nil) {
            NSLog(@"Page deleted!");
            pageA.operationType = SketchOperationTypeDelete;
            pageA.operations = [self operationsFromPageA:pageA toPageB:nil];
            [deleteOperations addObject:pageA];
            [allOperations addObject:pageA];
        }
        
        else {
            NSLog(@"Page updated!");
            pageA.operationType = SketchOperationTypeUpdate;
            pageB.operationType = SketchOperationTypeUpdate;
            pageB.operations = [self operationsFromPageA:pageA toPageB:pageB];
            [updateOperations addObject:pageB];
            [allOperations addObject:pageB];
        }
    }
    
    SketchDiff *diff = [[SketchDiff alloc] init];
    diff.insertOperations = insertOperations;
    diff.updateOperations = updateOperations;
    diff.deleteOperations = deleteOperations;
    diff.ignoreOperations = ignoreOperations;
    diff.allOperations = allOperations;
    
    return diff;
}

@end


@implementation CoreSyncTransaction (Sketch)

- (NSString *)pageID {
    NSArray *parts = [self.keyPath componentsSeparatedByString:@"/"];
    return [parts objectAtIndex:1];
}

@end
