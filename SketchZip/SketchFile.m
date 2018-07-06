//
//  SketchFile.m
//  SketchZip
//
//  Created by Hanno on 05/07/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchFile.h"
#import "SSZipArchive.h"
#import "CoreSync.h"


static const BOOL kLoggingEnabled = NO;


@implementation SketchFile

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
//        NSLog(@"%@", pageJSON[@"layers"]);
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

- (NSArray *)diffFromFile:(NSURL *)oldFile to:(NSURL *)newFile {
    
    NSDictionary *oldPages = [self _pagesFromFileAtURL:oldFile];
    NSDictionary *newPages = [self _pagesFromFileAtURL:newFile];
    
    NSArray *diff = [CoreSync diffAsTransactions:oldPages :newPages];
    
    return diff;
}

@end


@implementation CoreSyncTransaction (Sketch)

- (NSString *)pageID {
    NSArray *parts = [self.keyPath componentsSeparatedByString:@"/"];
    return [parts objectAtIndex:1];
}

- (NSInteger)artboardIndex {
    NSArray *parts = [self.keyPath componentsSeparatedByString:@"/"];

    NSString *index = [parts objectAtIndex:3];
    
    return [index integerValue];
}

@end
