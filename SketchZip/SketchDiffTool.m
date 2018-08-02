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


static const BOOL kLoggingEnabled = YES;


@interface SketchArtboardImageOperation : NSOperation

@property (strong) NSString *sketchToolPath;
@property (strong) NSString *filePath;
@property (strong) NSString *artboardID;
@property (strong) NSImage  *artboardImage;

@end


@implementation SketchArtboardImageOperation

- (id)initWithFilePath:(NSString *)filePath artboardID:(NSString *)artboardID {
    self = [super init];
    
    self.filePath = filePath;
    self.artboardID = artboardID;
    
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
                         [NSString stringWithFormat:@"--item=%@", self.artboardID]
                         ]];
    
    NSLog(@"%@", tempDir.path);
    
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
            NSString *outputFilePath = [[tempDir.path stringByAppendingPathComponent:self.artboardID] stringByAppendingPathExtension:@"png"];
            image = [[NSImage alloc] initWithContentsOfFile:outputFilePath];
        }
    } else {
        result = [[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding];
        //        DDLogError(@"SketchFilePlugin error: %@", result);
    }
    
    //    DDLogVerbose(@"SketchFilePlugin: %@", result);
    
    self.artboardImage = [image scaleToSize:NSMakeSize(1280, 1280)];
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

- (NSImage *)_imageForArtboardWithID:(NSString *)artboardID inFileWithURL:(NSURL *)fileURL maxSize:(CGSize)maxSize {
    SketchArtboardImageOperation *op = [[SketchArtboardImageOperation alloc] initWithFilePath:fileURL.path artboardID:artboardID];
    op.completionBlock = ^{
        NSLog(@"DONE!");
    };
    
    [self.artboardImageQueue addOperation:op];
    
    return nil;
}

- (NSImage *)imageForArtboardWithID:(NSString *)artboardID inFileWithURL:(NSURL *)fileURL maxSize:(CGSize)maxSize {
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
    
    NSLog(@"%@", tempDir.path);
    
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
    NSArray *layers = page[@"layers"];
    NSMutableDictionary *artboards = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *layer in layers) {
        if([layer[@"_class"] isEqualToString:@"artboard"] && layer[@"do_objectID"] != nil) {
            artboards[layer[@"do_objectID"]] = layer;
        }
    }
    
    return artboards;
}

- (void)artboardsFromPages:(NSDictionary *)pagesA to:(NSDictionary *)pagesB {
    
    NSString *pageID = @"4BDB2ECE-DFE7-40CF-A522-C09CC3A27D9F";
//    NSString *pageID = @"E8E9DABE-83B8-4C0A-9CE8-3C797F9835E5";
    
    NSDictionary *pageA = pagesA[pageID];
    NSDictionary *pageB = pagesB[pageID];

    NSDictionary *artboardsA = [self artboardsFromPage:pageA];
    NSDictionary *artboardsB = [self artboardsFromPage:pageB];

    NSMutableArray *artboardIDs = [[NSMutableArray alloc] init];
    [artboardIDs addObjectsFromArray:[artboardsA allKeys]];
    [artboardIDs addObjectsFromArray:[artboardsB allKeys]];

    for (NSString *artboardID in artboardIDs) {
        NSLog(@"artboard: %@", artboardID);
        
        NSDictionary *artboardA = artboardsA[artboardID];
        NSDictionary *artboardB = artboardsB[artboardID];
        
        if(artboardA == nil) {
            NSLog(@"Artboard added!");
        }
        
        else if(artboardB == nil) {
            NSLog(@"Artboard deleted!");
        }
        
        else {
            NSArray *diff = [CoreSync diffAsTransactions:artboardA :artboardB];
            
            if(diff) {
                NSLog(@"Artboard changed!");
            }
            else {
                NSLog(@"Artboard is the same!");
            }
        }
    }
    
}

- (NSArray *)diffFromFile:(NSURL *)oldFile to:(NSURL *)newFile {
    NSDictionary *oldPages = [self pagesFromFileAtURL:oldFile];
    NSDictionary *newPages = [self pagesFromFileAtURL:newFile];
    
    [self artboardsFromPages:oldPages to:newPages];
    
//    NSArray *diff = [CoreSync diffAsTransactions:oldPages :newPages];
    
    NSMutableDictionary *diffLookup = [[NSMutableDictionary alloc] init];
    
//    for(CoreSyncTransaction *transaction in diff) {
//        // Don't overwrite delete transactions
//        if([(CoreSyncTransaction *)diffLookup[transaction.artboardID] transactionType] == CSTransactionTypeDeletion) {
//            continue;
//        }
//
////        if([(CoreSyncTransaction *)diffLookup[transaction.artboardID] transactionType] == CSTransactionTypeAddition) {
////            continue;
////        }
//
//        diffLookup[transaction.artboardID] = transaction;
//    }

    return diffLookup.allValues;
}

@end


@implementation CoreSyncTransaction (Sketch)

- (NSString *)pageID {
    NSArray *parts = [self.keyPath componentsSeparatedByString:@"/"];
    return [parts objectAtIndex:1];
}

@end
