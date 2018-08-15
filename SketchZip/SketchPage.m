//
//  SketchPage.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 02/08/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchPage.h"
#import "SketchDiffTool.h"
#import "SSZipArchive/SSZipArchive.h"


static const BOOL kLoggingEnabled = YES;


@implementation SketchLayer

- (id)initWithJSON:(NSDictionary *)JSON fromPage:(SketchPage *)page {
    self = [super init];

    _JSON = JSON;
    _page = page;
    _objectId = JSON[@"do_objectID"];
    _objectClass = JSON[@"_class"];
    _image = nil;

    return self;
}

- (NSString *)name {
    return _JSON[@"name"];
}

@end


@implementation SketchOperation

@end


@implementation SketchPage

- (id)initWithJSON:(NSDictionary *)JSON sketchFile:(SketchFile *)sketchFile {
    self = [super init];
    
    _JSON = JSON;
    _name = JSON[@"name"];
    _objectId = JSON[@"do_objectID"];
    _sketchFile = sketchFile;
    _operations = nil;
    
    return self;
}

- (void)insertLayer:(SketchLayer *)artboard {
    
}

- (void)updateLayer:(SketchLayer *)artboard {
    
}

- (void)deleteLayer:(SketchLayer *)artboard {
    
}

@end


@interface SketchFile ()

@property (strong) NSURL            *tempFileURL;

@property (strong) NSDictionary     *documentJSON;
@property (strong) NSDictionary     *metaJSON;

@end


@implementation SketchFile

+ (SketchFile *)readFromURL:(NSURL *)fileURL {
    SketchFile *sketchFile = [[SketchFile alloc] init];
    sketchFile.fileURL = fileURL;
    
    SketchDiffTool *sketchDiffTool = [[SketchDiffTool alloc] init];
    sketchFile.pages = [sketchDiffTool pagesFromFileAtURL:sketchFile.fileURL];
    
    return sketchFile;
}

- (id)initWithFileURL:(NSURL *)fileURL {
    self = [super init];
    
    _fileURL = fileURL;
    // Extract Zip
    _tempFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:_fileURL.lastPathComponent]];
    [SSZipArchive unzipFileAtPath:_fileURL.path toDestination:_tempFileURL.path];
    
    if(kLoggingEnabled) NSLog(@"Source: %@", _fileURL.path);
    if(kLoggingEnabled) NSLog(@"Destination: %@", _tempFileURL.path);

    [self loadPages];
    
    return self;
}

- (void)loadPages {
    // Load all page files
    NSString *pagesDirectory = [self.tempFileURL.path stringByAppendingPathComponent:@"pages"];
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
        
        NSString *objectID = pageJSON[@"do_objectID"];
        
        pagesLookup[objectID] = [[SketchPage alloc] initWithJSON:pageJSON sketchFile:self];
    }
    
    self.pages = pagesLookup;
    
    // Load document & meta JSON
    NSString *documentDataPath = [[self.tempFileURL.path stringByAppendingPathComponent:@"document"] stringByAppendingPathExtension:@"json"];
    NSData *documentData = [NSData dataWithContentsOfFile:documentDataPath];
    self.documentJSON = [NSJSONSerialization JSONObjectWithData:documentData options:0 error:nil];
    
    NSString *metaDataPath = [[self.tempFileURL.path stringByAppendingPathComponent:@"meta"] stringByAppendingPathExtension:@"json"];
    NSData *metaData = [NSData dataWithContentsOfFile:metaDataPath];
    self.metaJSON = [NSJSONSerialization JSONObjectWithData:metaData options:0 error:nil];

    
    
//    
}

- (void)writePages {
    NSString *pagesDirectory = [self.tempFileURL.path stringByAppendingPathComponent:@"pages"];
    
    for (NSString *pageId in self.pages.allKeys) {
        SketchPage *page = self.pages[pageId];
        
        NSError *error = nil;
        NSData *pageData = [NSJSONSerialization dataWithJSONObject:page.JSON options:0 error:&error];
        
        if(error) {
            return NSLog(@"Error:%@", error);
        }

        NSString *pageFileName = [[pagesDirectory stringByAppendingPathComponent:pageId] stringByAppendingPathExtension:@"json"];
        [pageData writeToFile:pageFileName atomically:YES];
        
        NSLog(@"Write to file: %@", pageFileName);
    }
    
    NSMutableArray *pagesJSON = [[NSMutableArray alloc] init];
    
    for (NSString *pageId in self.pages.allKeys) {
        SketchPage *page = self.pages[pageId];
        NSString *pageRef = [NSString stringWithFormat:@"pages/%@", page.objectId];
        NSDictionary *pageJSON = @{
            @"_class": @"MSJSONFileReference",
            @"_ref_class": @"MSImmutablePage",
            @"_ref": pageRef
        };
        
        [pagesJSON addObject:pageJSON];
    }
    
    NSMutableDictionary *documentJSON = [self.documentJSON mutableCopy];
    documentJSON[@"pages"] = pagesJSON;
    
    NSData *documentData = [NSJSONSerialization dataWithJSONObject:documentJSON options:0 error:nil];
    NSString *documentDataPath = [[self.tempFileURL.path stringByAppendingPathComponent:@"document"] stringByAppendingPathExtension:@"json"];
    [documentData writeToFile:documentDataPath atomically:YES];
    
    // Write zip
    NSString *homeDirectory =  [@"~/SketchJoh.sketch" stringByExpandingTildeInPath];
    
    if(![SSZipArchive createZipFileAtPath:homeDirectory withContentsOfDirectory:self.tempFileURL.path]) {
        NSLog(@"Something went wrong");
    }
    else {
        NSLog(@"Hoera! %@", homeDirectory);
    }


    
}

- (void)applyDiff:(SketchDiff *)diff {
    for (SketchPage *page in diff.insertOperations) {
        [self.pages setValue:page forKey:page.objectId];
    }
}

- (void)insertPage:(SketchPage *)page {
    
}

- (void)updatePage:(SketchPage *)page {
    
}

- (void)deletePage:(SketchPage *)page {
    
}

@end
