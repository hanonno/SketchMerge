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

- (NSDictionary *)layersFromPage:(NSDictionary *)page {
    if(page == nil) {
        return [[NSDictionary alloc] init];
    }
    
    NSMutableDictionary *layers = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *layer in page[@"layers"]) {
        if(layer[@"do_objectID"] != nil) {
            layers[layer[@"do_objectID"]] = layer;
        }
    }
    
    return layers;
}

- (NSArray *)operationsFromPageA:(SketchPage *)pageA toPageB:(SketchPage *)pageB {
    NSDictionary *layersA = [self layersFromPage:pageA.JSON];
    NSDictionary *layersB = [self layersFromPage:pageB.JSON];
    
    NSMutableSet *layerIds = [[NSMutableSet alloc] init];
    [layerIds addObjectsFromArray:[layersA allKeys]];
    [layerIds addObjectsFromArray:[layersB allKeys]];

    NSMutableArray *operations = [[NSMutableArray alloc] init];
    
    for (NSString *layerId in layerIds) {
        NSLog(@"artboard: %@", layerId);
        
        NSDictionary *layerA = layersA[layerId];
        NSDictionary *layerB = layersB[layerId];
        
        if(layerA == nil && layerB != nil) {
            NSLog(@"Layer added!");
            
            SketchOperation *operation = [[SketchOperation alloc] init];
            operation.type = SketchOperationTypeInsert;
            operation.layerB = [[SketchLayer alloc] initWithJSON:layerB fromPage:pageB];
            operation.objectId = operation.layerB.objectId;
            [operations addObject:operation];
        }
        
        else if(layerB == nil && layerA != nil) {
            NSLog(@"Layer deleted!");
            
            SketchOperation *operation = [[SketchOperation alloc] init];
            operation.type = SketchOperationTypeDelete;
            operation.layerA = [[SketchLayer alloc] initWithJSON:layerA fromPage:pageA];
            operation.objectId = operation.layerA.objectId;
            [operations addObject:operation];
        }
        
        else {
            NSArray *diff = [CoreSync diffAsTransactions:layerA :layerB];
            
            if(diff && [diff count]) {
                NSLog(@"Layer updated!");
                SketchOperation *operation = [[SketchOperation alloc] init];
                operation.type = SketchOperationTypeUpdate;
                operation.layerA = [[SketchLayer alloc] initWithJSON:layerA fromPage:pageA];
                operation.layerB = [[SketchLayer alloc] initWithJSON:layerB fromPage:pageB];
                operation.objectId = operation.layerB.objectId;
                [operations addObject:operation];
            }
            else {
                NSLog(@"Layer is the same!");
                SketchOperation *operation = [[SketchOperation alloc] init];
                operation.type = SketchOperationTypeIgnore;
                operation.layerA = [[SketchLayer alloc] initWithJSON:layerA fromPage:pageA];
                operation.layerB = [[SketchLayer alloc] initWithJSON:layerB fromPage:pageB];
                operation.objectId = operation.layerB.objectId;
                [operations addObject:operation];
            }
        }
    }
    
    return operations;
}

- (NSArray *)diffFromFile:(SketchFile *)fileA to:(SketchFile *)fileB {
    NSDictionary *pagesA = fileA.pages;
    NSDictionary *pagesB = fileB.pages;
    
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    NSMutableSet *pageIDs = [[NSMutableSet alloc] init];
    
    [pageIDs addObjectsFromArray:[pagesA allKeys]];
    [pageIDs addObjectsFromArray:[pagesB allKeys]];
    
    for (NSString *pageID in pageIDs) {
        NSDictionary *pageA = pagesA[pageID];
        NSDictionary *pageB = pagesB[pageID];

        if(pageA == nil && pageB != nil) {
            NSLog(@"Page added!");
            SketchPage *page = [[SketchPage alloc] initWithJSON:pageB sketchFile:fileB];
            page.operationType = SketchOperationTypeInsert;
            page.operations = [self operationsFromPageA:nil toPageB:page];
            [pages addObject:page];
        }
        
        else if(pageB == nil && pageA != nil) {
            NSLog(@"Page deleted!");
            SketchPage *page = [[SketchPage alloc] initWithJSON:pageA sketchFile:fileA];
            page.operationType = SketchOperationTypeDelete;
            page.operations = [self operationsFromPageA:page toPageB:nil];
            [pages addObject:page];
        }
        
        else {
            NSLog(@"Page updated!");
            SketchPage *pageAA = [[SketchPage alloc] initWithJSON:pageA sketchFile:fileA];
            SketchPage *pageBB = [[SketchPage alloc] initWithJSON:pageB sketchFile:fileB];
            pageAA.operationType = SketchOperationTypeUpdate;
            pageBB.operationType = SketchOperationTypeUpdate;
            pageBB.operations = [self operationsFromPageA:pageAA toPageB:pageBB];
            
            [pages addObject:pageBB];
        }
    }
    
    return pages;
}

@end


@implementation CoreSyncTransaction (Sketch)

- (NSString *)pageID {
    NSArray *parts = [self.keyPath componentsSeparatedByString:@"/"];
    return [parts objectAtIndex:1];
}

@end
