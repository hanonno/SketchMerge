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


static const BOOL kLoggingEnabled = NO;


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
        NSDictionary *artboards = [self _getArtboardsFromLayers:pageJSON[@"layers"]];
        [artboardLookup addEntriesFromDictionary:artboards];
    }
    
    return artboardLookup;
}

- (NSDictionary *)_pagesFromFileAtURL:(NSURL *)fileURL {
    // Extract Zip
    NSString *destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileURL.lastPathComponent];
    [SSZipArchive unzipFileAtPath:fileURL.path toDestination:destinationPath];
    
    if(kLoggingEnabled) NSLog(@"Destination: %@", destinationPath);
    
    // Load all page files
    NSString *pagesDirectory = [destinationPath stringByAppendingPathComponent:@"pages"];
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:pagesDirectory];
    
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

- (NSDictionary *)_getArtboardsFromLayers:(NSArray *)layers {
    NSMutableDictionary *artboards = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *layer in layers) {
        NSString *class = layer[@"_class"];
        NSString *objectID = layer[@"do_objectID"];
        
        if([class isEqualToString:@"artboard"]) {
            artboards[objectID] = layer;
        }
    }
    
    return artboards;
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


- (NSArray *)diffFromFile:(NSURL *)oldFile to:(NSURL *)newFile {
    NSDictionary *oldPages = [self _pagesFromFileAtURL:oldFile];
    NSDictionary *newPages = [self _pagesFromFileAtURL:newFile];
    
    NSArray *diff = [CoreSync diffAsTransactions:oldPages :newPages];
    
    NSMutableDictionary *diffLookup = [[NSMutableDictionary alloc] init];
    
    for(CoreSyncTransaction *transaction in diff) {
        // Don't overwrite delete transactions
        if([(CoreSyncTransaction *)diffLookup[transaction.artboardID] transactionType] == CSTransactionTypeDeletion) {
            continue;
        }
        
//        if(transaction.artboardID == nil) {
//            continue;
//        }

        diffLookup[transaction.artboardID] = transaction;
    }

    return diffLookup.allValues;
}

@end


@implementation CoreSyncTransaction (Sketch)

- (NSString *)pageID {
    NSArray *parts = [self.keyPath componentsSeparatedByString:@"/"];
    return [parts objectAtIndex:1];
}

@end
