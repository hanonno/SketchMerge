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


@implementation SketchArtboardPreviewOperation

- (id)initWithFilePath:(NSString *)filePath artboard:(SketchArtboard *)artboard {
    self = [super init];
    
    self.filePath = filePath;
    self.artboard = artboard;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    self.sketchToolPath = @"/Applications/Sketch.app/Contents/Resources/sketchtool/bin/sketchtool";
    
    if (![fileManager fileExistsAtPath:self.sketchToolPath]) {
        self.sketchToolPath = [[NSBundle mainBundle] pathForResource:@"sketchtool/bin/sketchtool" ofType:nil];
    }

    return self;
}

- (void)main {
    NSImage *image;
    NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    tempDir = [tempDir URLByAppendingPathComponent:[NSUUID UUID].UUIDString];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir.path withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:self.sketchToolPath];
    [task setArguments:@[
                         @"export",
                         @"artboards",
                         self.filePath,
                         [NSString stringWithFormat:@"--output=%@", tempDir.path],
                         @"--use-id-for-name",
                         [NSString stringWithFormat:@"--item=%@", self.artboard.objectId]
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
    
    NSString *result;
    if (errorData.length == 0) {
        result = [[NSString alloc] initWithData:[outputFile readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        
        if ([result hasPrefix:@"Exported "]) {
            NSString *outputFilePath = [[tempDir.path stringByAppendingPathComponent:self.artboard.objectId] stringByAppendingPathExtension:@"png"];
            image = [[NSImage alloc] initWithContentsOfFile:outputFilePath];
            self.artboard.image = [image scaleToSize:NSMakeSize(1280, 1280)];
        }
    } else {
        result = [[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding];
        //        DDLogError(@"SketchFilePlugin error: %@", result);
        self.artboard.error = [[NSError alloc] initWithDomain:@"Folio" code:001 userInfo:nil];
        //    DDLogVerbose(@"SketchFilePlugin: %@", result);
    }
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

- (void)generatePreviewsForArtboards:(NSArray *)artboards fromFileWithURL:(NSURL *)fileURL {
    NSImage *image;
    NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    tempDir = [tempDir URLByAppendingPathComponent:[NSUUID UUID].UUIDString];
    
    NSMutableArray *artboardIds = [[NSMutableArray alloc] init];
    
    for (SketchArtboard *artboard in artboards) {
        NSString *artboardId = artboard.objectId;
        
        if(artboardId != nil) {
            [artboardIds addObject:artboardId];
        }
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir.path withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:self.sketchToolPath];
    [task setArguments:@[
                         @"export",
                         @"artboards",
                         fileURL.path,
                         [NSString stringWithFormat:@"--output=%@", tempDir.path],
                         @"--use-id-for-name",
                         [NSString stringWithFormat:@"--items=%@", [artboardIds componentsJoinedByString:@","]]
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
    
    NSString *result;
    if (errorData.length == 0) {
        result = [[NSString alloc] initWithData:[outputFile readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        
        if ([result hasPrefix:@"Exported "]) {
            for (SketchArtboard *artboard in artboards) {
                NSString *outputFilePath = [[tempDir.path stringByAppendingPathComponent:artboard.objectId] stringByAppendingPathExtension:@"png"];
                image = [[NSImage alloc] initWithContentsOfFile:outputFilePath];
                artboard.image = image;
            }
        }
    } else {
        result = [[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding];
        //        DDLogError(@"SketchFilePlugin error: %@", result);
    }
    
    //    DDLogVerbose(@"SketchFilePlugin: %@", result);
}

- (NSImage *)_imageForArtboardWithID:(NSString *)artboardID inFileWithURL:(NSURL *)fileURL maxSize:(CGSize)maxSize {
    NSImage *image;
    NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    tempDir = [tempDir URLByAppendingPathComponent:[NSUUID UUID].UUIDString];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir.path withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:self.sketchToolPath];
    [task setArguments:@[
        @"export",
        @"artboards",
        fileURL.path,
        [NSString stringWithFormat:@"--output=%@", tempDir.path],
        @"--use-id-for-name",
        [NSString stringWithFormat:@"--item=%@", artboardID]
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
    
    NSString *result;
    if (errorData.length == 0) {
        result = [[NSString alloc] initWithData:[outputFile readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        
        if ([result hasPrefix:@"Exported "]) {
            NSString *outputFilePath = [[tempDir.path stringByAppendingPathComponent:artboardID] stringByAppendingPathExtension:@"png"];
            image = [[NSImage alloc] initWithContentsOfFile:outputFilePath];
        }
    } else {
        result = [[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding];
        //        DDLogError(@"SketchFilePlugin error: %@", result);
    }
    
    //    DDLogVerbose(@"SketchFilePlugin: %@", result);
    
    image = [image scaleToSize:maxSize];
    
    return image;
}

- (NSDictionary *)artboardsFromPage:(NSDictionary *)page {
    if(page == nil) {
        return [[NSDictionary alloc] init];
    }
    
    NSArray *layers = page[@"layers"];
    NSMutableDictionary *artboards = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *layer in layers) {
        if([layer[@"_class"] isEqualToString:@"artboard"] && layer[@"do_objectID"] != nil) {
            artboards[layer[@"do_objectID"]] = layer;
        }
    }
    
    return artboards;
}

- (NSArray *)artboardsFromPageA:(SketchPage *)pageA toPageB:(SketchPage *)pageB {
    NSDictionary *artboardsA = [self artboardsFromPage:pageA.JSON];
    NSDictionary *artboardsB = [self artboardsFromPage:pageB.JSON];
    
    NSMutableSet *artboardIDs = [[NSMutableSet alloc] init];
    [artboardIDs addObjectsFromArray:[artboardsA allKeys]];
    [artboardIDs addObjectsFromArray:[artboardsB allKeys]];

    NSMutableArray *artboards = [[NSMutableArray alloc] init];
    
    for (NSString *artboardID in artboardIDs) {
        NSLog(@"artboard: %@", artboardID);
        
        NSDictionary *artboardA = artboardsA[artboardID];
        NSDictionary *artboardB = artboardsB[artboardID];
        
        if(artboardA == nil && artboardB != nil) {
            NSLog(@"Artboard added!");
            
            SketchArtboard *artboard = [[SketchArtboard alloc] initWithJSON:artboardB];
            artboard.operationType = SketchOperationTypeInsert;
            [artboards addObject:artboard];
        }
        
        else if(artboardB == nil && artboardA != nil) {
            NSLog(@"Artboard deleted!");
            
            SketchArtboard *artboard = [[SketchArtboard alloc] initWithJSON:artboardA];
            artboard.operationType = SketchOperationTypeDelete;
            [artboards addObject:artboard];
        }
        
        else {
            NSArray *diff = [CoreSync diffAsTransactions:artboardA :artboardB];
            
            if(diff && [diff count]) {
                NSLog(@"Artboard changed!");
                
                SketchArtboard *artboard = [[SketchArtboard alloc] initWithJSON:artboardB];
                artboard.operationType = SketchOperationTypeUpdate;
                [artboards addObject:artboard];
            }
            else {
                NSLog(@"Artboard is the same!");
            }
        }
    }
    
    return artboards;
}

- (NSArray *)diffFromFile:(NSURL *)oldFile to:(NSURL *)newFile {
    NSDictionary *pagesA = [self pagesFromFileAtURL:oldFile];
    NSDictionary *pagesB = [self pagesFromFileAtURL:newFile];
    
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    NSMutableArray *changedArtboards = [[NSMutableArray alloc] init];
    NSMutableSet *pageIDs = [[NSMutableSet alloc] init];
    
    [pageIDs addObjectsFromArray:[pagesA allKeys]];
    [pageIDs addObjectsFromArray:[pagesB allKeys]];
    
    
    for (NSString *pageID in pageIDs) {
        NSDictionary *pageA = pagesA[pageID];
        NSDictionary *pageB = pagesB[pageID];

        if(pageA == nil && pageB != nil) {
            NSLog(@"Page added!");
            SketchPage *page = [[SketchPage alloc] initWithJSON:pageB];
            page.operationType = SketchOperationTypeInsert;
            [pages addObject:page];
            
            NSArray *artboards = [self artboardsFromPageA:nil toPageB:page];
            if(artboards) {
                page.changedArtboards = artboards;
                [changedArtboards addObjectsFromArray:artboards];
            }
        }
        
        else if(pageB == nil && pageA != nil) {
            NSLog(@"Page deleted!");
            SketchPage *page = [[SketchPage alloc] initWithJSON:pageA];
            page.operationType = SketchOperationTypeDelete;
            [pages addObject:page];
            
            NSArray *artboards = [self artboardsFromPageA:page toPageB:nil];
            if(artboards) {
                page.changedArtboards = artboards;
                [changedArtboards addObjectsFromArray:artboards];
            }
        }
        
        else {
            NSLog(@"Page updated!");
            SketchPage *page = [[SketchPage alloc] initWithJSON:pageB];
            page.operationType = SketchOperationTypeUpdate;
            [pages addObject:page];
            
            NSArray *artboards = [self artboardsFromPageA:[[SketchPage alloc] initWithJSON:pageA] toPageB:[[SketchPage alloc] initWithJSON:pageB]];
            if(artboards) {
                page.changedArtboards = artboards;
                [changedArtboards addObjectsFromArray:artboards];
            }
        }
    }
    
    return changedArtboards;
}

@end


@implementation CoreSyncTransaction (Sketch)

- (NSString *)pageID {
    NSArray *parts = [self.keyPath componentsSeparatedByString:@"/"];
    return [parts objectAtIndex:1];
}

@end
