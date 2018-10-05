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
#import "SketchFile.h"


static const BOOL kLoggingEnabled = YES;


@implementation SKLayerOperation

- (NSString *)layerId {
    return self.layer.objectId;
}

- (void)applyToPage:(SketchPage *)page {
    SketchRect *rect = [[SketchRect alloc] init];
    SketchText *text = [[SketchText alloc] init];
    
    rect.width = 4;
    
    [page insertLayer:text];
    [page insertLayer:rect];
    
    switch (self.operationType) {
        case SketchOperationTypeInsert:
            
            
            [page insertLayer:self.layer];
            break;
            
        case SketchOperationTypeUpdate:
            [page updateLayer:self.layer];
            break;

        case SketchOperationTypeDelete:
            [page deleteLayer:self.layer];
            break;
        
        case SketchOperationTypeIgnore:
            break;
    }
}

@end


@implementation SKPageOperation

- (id)initWithPage:(SketchPage *)page operationType:(SketchOperationType)operationType {
    self = [super init];
    
    _page = page;
    _operationType = operationType;
    
    return self;
}

- (NSArray *)layerIds {
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    
    for (SKLayerOperation *operation in self.layerOperations) {
        [keys addObject:operation.layerId];
    }
    
    return keys;
}

- (SKLayerOperation *)layerOperationWithId:(NSString *)objectId {
    for (SKLayerOperation *operation in self.layerOperations) {
        if([operation.layerId isEqualToString:objectId]) {
            return operation;
        }
    }
    
    return nil;
}

- (void)applyToFile:(SketchFile *)file {
    switch (self.operationType) {
        case SketchOperationTypeInsert:
            [file insertPage:self.page];
            break;
            
        case SketchOperationTypeUpdate:
            for (SKLayerOperation *layerChange in self.layerOperations) {
                [layerChange applyToPage:self.page];
            }

            [file updatePage:self.page];
            break;
            
        case SketchOperationTypeDelete:
            [file deletePage:self.page];
            break;
            
        case SketchOperationTypeIgnore:
            break;
    }
}

@end


@implementation SketchFileOperation

- (NSArray *)pageIds {
    NSMutableArray *pageIds = [[NSMutableArray alloc] init];
    
    for (SKPageOperation *pageChange in self.pageOperations) {
        [pageIds addObject:pageChange.page.objectId];
    }
    
    return pageIds;
}

- (SKPageOperation *)pageChangeWithId:(NSString *)pageId {
    for (SKPageOperation *pageChange in self.pageOperations) {
        if([pageChange.page.objectId isEqualToString:pageId]) {
            return pageChange;
        }
    }
    
    return nil;
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
    
    NSString *filePath = nil;
    NSMutableArray *operationsPerFilePath = nil;
    NSMutableDictionary *filePaths = [[NSMutableDictionary alloc] init];
    
    for (SKLayerOperation *operation in operations) {
        filePath = operation.layer.page.file.fileURL.path;
        
        operationsPerFilePath = [filePaths objectForKey:filePath];
        
        NSLog(@"Class: %@", NSStringFromClass([operation class]));
        
        if(operationsPerFilePath == nil) {
            operationsPerFilePath = [[NSMutableArray alloc] init];
            [filePaths setObject:operationsPerFilePath forKey:filePath];
        }
        
        [operationsPerFilePath addObject:operation];
    }
    
    for (NSString *filePath in filePaths.allKeys) {
        NSArray *operationsPerFilePath = [filePaths objectForKey:filePath];
        [self generatePreviewsForOperations:operationsPerFilePath inFileWithPath:filePath];
    }
}
    
- (void)generatePreviewsForOperations:(NSArray *)operations inFileWithPath:(NSString *)filePath {
    NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    tempDir = [tempDir URLByAppendingPathComponent:[NSUUID UUID].UUIDString];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir.path withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:self.sketchToolPath];
    [task setArguments:@[
        @"export",
        @"artboards",
        filePath,
        [NSString stringWithFormat:@"--output=%@", tempDir.path],
        @"--use-id-for-name",
//        [NSString stringWithFormat:@"--items=%@", [objectIds componentsJoinedByString:@","]]
    ]];
    
    NSPipe *outputPipe = [[NSPipe alloc] init];
    task.standardOutput = outputPipe;
    NSFileHandle *outputFile = outputPipe.fileHandleForReading;
    
    NSPipe *errorPipe = [[NSPipe alloc] init];
    task.standardError = errorPipe;
    NSFileHandle *errorFile = errorPipe.fileHandleForReading;
    
    [task launch];
    
    NSImage *image = nil;
    NSData *errorData = [errorFile readDataToEndOfFile];
    
    //    DDLogVerbose(@"SketchFilePlugin: sketchtool for %@ in %f ms", fileURL.relativeString, [now timeIntervalSinceNow]);
    
    NSLog(@"OUTPUT DIR: %@", tempDir);
    
    NSString *result;
    if (errorData.length == 0) {
        result = [[NSString alloc] initWithData:[outputFile readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        
        if ([result hasPrefix:@"Exported "]) {
            for (SKLayerOperation *operation in operations) {
                NSString *outputFilePath = [[tempDir.path stringByAppendingPathComponent:operation.layer.objectId] stringByAppendingPathExtension:@"png"];
                image = [[NSImage alloc] initWithContentsOfFile:outputFilePath];
                operation.layer.previewImage = image;
            }
        }
    } else {
        result = [[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding];
        //        DDLogError(@"SketchFilePlugin error: %@", result);
    }
}

- (NSMutableArray *)operationsFromPageA:(SketchPage *)pageA toPageB:(SketchPage *)pageB {
    NSDictionary *layersA = pageA.layers;
    NSDictionary *layersB = pageB.layers;
    
    NSMutableSet *layerIds = [[NSMutableSet alloc] init];
    [layerIds addObjectsFromArray:[layersA allKeys]];
    [layerIds addObjectsFromArray:[layersB allKeys]];
    
    NSMutableArray *operations = [[NSMutableArray alloc] init];

    for (NSString *layerId in layerIds) {
        NSLog(@"layer: %@", layerId);
        
        SketchLayer *layerA = layersA[layerId];
        SketchLayer *layerB = layersB[layerId];
        
        if(layerA == nil && layerB != nil) {
            NSLog(@"Layer added!");
            
            SKLayerOperation *layerChange = [[SKLayerOperation alloc] init];
            layerChange.operationType = SketchOperationTypeInsert;
            layerChange.layer = layerB;
            [operations addObject:layerChange];
        }
        
        else if(layerB == nil && layerA != nil) {
            NSLog(@"Layer deleted!");
            
            SKLayerOperation *layerChange = [[SKLayerOperation alloc] init];
            layerChange.operationType = SketchOperationTypeDelete;
            layerChange.layer = layerA;
            [operations addObject:layerChange];
        }
        
        else {
            NSArray *diff = [CoreSync diffAsTransactions:layerA.JSON :layerB.JSON];
            
            if(diff && [diff count]) {
                NSLog(@"Layer updated!");
                SKLayerOperation *layerChange = [[SKLayerOperation alloc] init];
                layerChange.operationType = SketchOperationTypeUpdate;
                layerChange.layer = layerB;
                [operations addObject:layerChange];
            }
            else {
                NSLog(@"Layer is the same!");
                SKLayerOperation *layerChange = [[SKLayerOperation alloc] init];
                layerChange.operationType = SketchOperationTypeIgnore;
                layerChange.layer = layerA;
                [operations addObject:layerChange];
            }
        }
    }
    
    return operations;
}

- (SketchFileOperation *)changesFromFile:(SketchFile *)fileA to:(SketchFile *)fileB {
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
            
            SKPageOperation *pageChange = [[SKPageOperation alloc] initWithPage:pageB operationType:SketchOperationTypeInsert];
            pageChange.layerOperations = [self operationsFromPageA:nil toPageB:pageB];
            [pageChanges addObject:pageChange];
        }
        
        else if(pageA != nil && pageB == nil) {
            NSLog(@"Page deleted!");

            SKPageOperation *pageChange = [[SKPageOperation alloc] initWithPage:pageA operationType:SketchOperationTypeDelete];
            pageChange.layerOperations = [self operationsFromPageA:pageA toPageB:nil];
            [pageChanges addObject:pageChange];
        }
        
        else {
            NSLog(@"Page updated!");            
            NSMutableArray *operations = [self operationsFromPageA:pageA toPageB:pageB];
            
            if(operations.count > 0) {
                SKPageOperation *pageChange = [[SKPageOperation alloc] initWithPage:pageA operationType:SketchOperationTypeUpdate];
                pageChange.layerOperations = operations;
                [pageChanges addObject:pageChange];
            }
        }
    }

    SketchFileOperation *changeSet = [[SketchFileOperation alloc] init];
    
    changeSet.pageOperations = pageChanges;
    
    return changeSet;
}


@end


@implementation SKLayerMergeOperation

- (SketchOperationType)operationType {
    if(self.resolutionType == SketchResolutionTypeA) {
        return self.layerOperationA.operationType;
    }
    else if(self.resolutionType == SketchResolutionTypeB) {
        return self.layerOperationB.operationType;
    }
    
    return SketchOperationTypeIgnore;
}

- (NSString *)objectId {
    if(self.resolutionType == SketchResolutionTypeA) {
        return self.layerOperationA.layer.objectId;
    }
    else if(self.resolutionType == SketchResolutionTypeB) {
        return self.layerOperationB.layer.objectId;
    }
    else if(self.resolutionType == SketchResolutionTypeConflict) {
        return self.layerOperationA.layer.objectId;
    }
    
    return @"Something went wrong";
}

- (SketchLayer *)layer {
    if(self.resolutionType == SketchResolutionTypeA) {
        return self.layerOperationA.layer;
    }
    else if(self.resolutionType == SketchResolutionTypeB) {
        return self.layerOperationB.layer;
    }
    else if(self.resolutionType == SketchResolutionTypeConflict) {
        return self.layerOperationA.layer;
    }
    
    return nil;
}

- (NSString *)objectName {
    if(self.resolutionType == SketchResolutionTypeA) {
        return self.layerOperationA.layer.name;
    }
    else if(self.resolutionType == SketchResolutionTypeB) {
        return self.layerOperationB.layer.name;
    }
    else if(self.resolutionType == SketchResolutionTypeConflict) {
        return @"Conflicted";
    }

    return @"Something went wrong";
}

- (NSString *)objectClass {
    if(self.resolutionType == SketchResolutionTypeA) {
        return self.layerOperationA.layer.className;
    }
    else if(self.resolutionType == SketchResolutionTypeB) {
        return self.layerOperationB.layer.className;
    }
    else if(self.resolutionType == SketchResolutionTypeConflict) {
        return self.layerOperationB.layer.className;
    }
    
    return @"Something went wrong";
}

- (void)applyToPage:(SketchPage *)page {
    switch (self.resolutionType) {
        case SketchResolutionTypeA:
            [self.layerOperationA applyToPage:page];
            break;
            
        case SketchResolutionTypeB:
            [self.layerOperationB applyToPage:page];
            break;

        case SketchResolutionTypeConflict:
            NSLog(@"Conflict?!?!");
            break;
            
        default:
            break;
    }
}

@end



@implementation SketchMergeTool

- (id)initWithOrigin:(SketchFile *)fileO fileA:(SketchFile *)fileA fileB:(SketchFile *)fileB {
    self = [super init];

    _fileO = fileO;
    _fileA = fileA;
    _fileB = fileB;
    
    SketchDiffTool *diffTool = [[SketchDiffTool alloc] init];
    
    _changeSetA = [diffTool changesFromFile:_fileO to:_fileA];
    _changeSetB = [diffTool changesFromFile:_fileO to:_fileB];

    NSMutableSet *pageIds = [[NSMutableSet alloc] init];
    [pageIds addObjectsFromArray:_changeSetA.pageIds];
    [pageIds addObjectsFromArray:_changeSetB.pageIds];

    _pageOperations = [[NSMutableArray alloc] init];
    _operations = [[NSMutableArray alloc] init];
    
    for (NSString *pageId in pageIds) {
        SKPageOperation *pageChangeA = [_changeSetA pageChangeWithId:pageId];
        SKPageOperation *pageChangeB = [_changeSetB pageChangeWithId:pageId];
        
        if(pageChangeA != nil && pageChangeB == nil) {
            [_pageOperations addObject:pageChangeA];
        }
        else if (pageChangeA == nil && pageChangeB != nil) {
            [_pageOperations addObject:pageChangeB];
        }
        else if(pageChangeA != nil && pageChangeB != nil) {
            NSMutableArray *operations = [self operationsFromPageChangeA:pageChangeA toPageChangeB:pageChangeB];
            
            if(operations.count > 0) {
                [_operations addObjectsFromArray:operations];
            }

            pageChangeA.layerOperations = operations;
            
            [_pageOperations addObject:pageChangeA];
        }
    }

    return self;
}

- (NSMutableArray *)operationsFromPageChangeA:(SKPageOperation *)pageChangeA toPageChangeB:(SKPageOperation *)pageChangeB {
    NSMutableSet *objectIds = [[NSMutableSet alloc] init];
    
    [objectIds addObjectsFromArray:pageChangeA.layerIds];
    [objectIds addObjectsFromArray:pageChangeB.layerIds];

    NSMutableArray *operations = [[NSMutableArray alloc] init];

    for (NSString *objectId in objectIds) {
        SKLayerOperation *layerChangeA = [pageChangeA layerOperationWithId:objectId];
        SKLayerOperation *layerChangeB = [pageChangeB layerOperationWithId:objectId];

        if(layerChangeA != nil && layerChangeB == nil) {
            NSLog(@"Layer added in A");
            SKLayerMergeOperation *operation = [[SKLayerMergeOperation alloc] init];
            operation.resolutionType = SketchResolutionTypeA;
            operation.layerOperationA = layerChangeA;
            [operations addObject:operation];
        }
        else if(layerChangeA == nil && layerChangeB != nil) {
            NSLog(@"Layer added in B");
            SKLayerMergeOperation *operation = [[SKLayerMergeOperation alloc] init];
            operation.resolutionType = SketchResolutionTypeB;
            operation.layerOperationB = layerChangeB;
            [operations addObject:operation];
        }
        else if (layerChangeA != nil && layerChangeB != nil) {
            // There can only be a conflict if both diffs have an operation
            if((layerChangeA.operationType == SketchOperationTypeDelete || layerChangeA.operationType == SketchOperationTypeIgnore) && layerChangeB.operationType == SketchOperationTypeUpdate) {
                NSLog(@"Layer updated in B");
                SKLayerMergeOperation *operation = [[SKLayerMergeOperation alloc] init];
                operation.resolutionType = SketchResolutionTypeB;
                operation.layerOperationA = layerChangeA;
                operation.layerOperationB = layerChangeB;
                [operations addObject:operation];
            }
            else if(layerChangeA.operationType == SketchOperationTypeUpdate && (layerChangeB.operationType == SketchOperationTypeDelete || layerChangeB.operationType == SketchOperationTypeIgnore)) {
                NSLog(@"Layer updated in A");
                // We should update with operationA
                SKLayerMergeOperation *operation = [[SKLayerMergeOperation alloc] init];
                operation.resolutionType = SketchResolutionTypeA;
                operation.layerOperationA = layerChangeA;
                operation.layerOperationB = layerChangeB;
                [operations addObject:operation];
            }
            else if(layerChangeA.operationType == SketchOperationTypeUpdate && layerChangeB.operationType == SketchOperationTypeUpdate) {
                NSLog(@"Layer updated in A & B");
                // Both updated, so now we have a conflict
                SKLayerMergeOperation *operation = [[SKLayerMergeOperation alloc] init];
                operation.resolutionType = SketchResolutionTypeConflict;
                operation.layerOperationA = layerChangeA;
                operation.layerOperationB = layerChangeB;
                [operations addObject:operation];
            }
        }
    }

    return operations;
}

- (void)applyChanges {
    for (SKPageOperation *pageChange in self.pageOperations) {
        [pageChange applyToFile:self.fileO];
    }
}

@end


@implementation CoreSyncTransaction (Sketch)

- (NSString *)pageID {
    NSArray *parts = [self.keyPath componentsSeparatedByString:@"/"];
    return [parts objectAtIndex:1];
}

@end
