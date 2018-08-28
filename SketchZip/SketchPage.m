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
    _image = nil;

    return self;
}

- (NSString *)name {
    return _JSON[@"name"];
}

- (NSString *)objectId {
    return _JSON[@"do_objectID"];
}

- (NSString *)objectClass {
    return _JSON[@"_class"];
}

@end


@implementation SketchArtboard

- (id)init {
    NSData *artboardData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"artboard" ofType:@"json"]];
    NSDictionary *artboardJSON = [NSJSONSerialization JSONObjectWithData:artboardData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
    
    self = [super initWithJSON:artboardJSON fromPage:nil];
    
    self.JSON[@"do_objectID"] = [[NSUUID UUID] UUIDString];
    
    return self;
}

@end





@implementation SketchPage

- (id)initWithJSON:(NSDictionary *)JSON sketchFile:(SketchFile *)sketchFile {
    self = [super init];
    
    _JSON = JSON;
    _sketchFile = sketchFile;
    
    NSMutableDictionary *layers = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *layer in _JSON[@"layers"]) {
        if(layer[@"do_objectID"] != nil) {
            layers[layer[@"do_objectID"]] = [[SketchLayer alloc] initWithJSON:layer fromPage:self];
        }
    }
    
    _layers = layers;
    
    return self;
}

- (NSString *)objectId {
    return _JSON[@"do_objectID"];
}

- (NSString *)name {
    return _JSON[@"name"];
}

- (void)insertLayer:(SketchLayer *)layer {
    [_JSON[@"layers"] insertObject:layer.JSON atIndex:0];
}

- (void)updateLayer:(SketchLayer *)layer {
//    self.layers[layer.objectId] = layer;
}

- (void)deleteLayer:(SketchLayer *)layer {
    if(layer == nil) {
        return NSLog(@"Trying to delete nil layer");
    }
    
    NSInteger index = 0;
    NSInteger target = NSIntegerMax;
    
    for (NSDictionary *layerJSON in _JSON[@"layers"]) {
        if([layerJSON[@"do_objectID"] isEqualToString:layer.objectId]) {
            target = index;
        }
        
        if(target != NSIntegerMax) {
            break;
        }
        
        index++;
    }
    
    if(target != NSIntegerMax) {
        [_JSON[@"layers"] removeObjectAtIndex:target];
    }

    [self.layers removeObjectForKey:layer.objectId];
}

@end


@interface SketchFile ()

@property (strong) NSURL            *tempFileURL;

@property (strong) NSDictionary     *documentJSON;
@property (strong) NSDictionary     *metaJSON;

@end


@implementation SketchFile

- (id)initWithFileURL:(NSURL *)fileURL {
    self = [super init];
    
    _fileURL = fileURL;
    // Extract Zip
    NSString *UUID = [[NSUUID UUID] UUIDString];
    _tempFileURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:_fileURL.lastPathComponent] stringByAppendingPathComponent:UUID]];
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
    NSMutableDictionary *pagesLookup = [[NSMutableDictionary alloc] init];
    
    while (currentFilename = [directoryEnumerator nextObject]) {
        NSString *currentPagePath = [pagesDirectory stringByAppendingPathComponent:currentFilename];
        if(kLoggingEnabled) NSLog(@"Current page: %@", currentPagePath);
        
        // Decode JSON
        NSData *pageData = [NSData dataWithContentsOfFile:currentPagePath];
        NSDictionary *pageJSON = [NSJSONSerialization JSONObjectWithData:pageData options:NSJSONReadingMutableContainers error:nil];
        
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
    
    // Write pages to document.json
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
    NSString *homeDirectory =  [@"~/SketchMerged.sketch" stringByExpandingTildeInPath];
    
    if(![SSZipArchive createZipFileAtPath:homeDirectory withContentsOfDirectory:self.tempFileURL.path]) {
        NSLog(@"Something went wrong");
    }
    else {
        NSLog(@"Hoera! %@", homeDirectory);
    }
}

- (SketchPage *)pageWithId:(NSString *)pageId {
    for (SketchPage *page in self.pages) {
        if([page.objectId isEqualToString:pageId]) {
            return page;
        }
    }
    
    return nil;
}

- (void)insertPage:(SketchPage *)page {
    NSLog(@"Add page %@", page.objectId);
    
    [self.pages setValue:page forKey:page.objectId];
}

- (void)updatePage:(SketchPage *)page {
    [self.pages setValue:page forKey:page.objectId];
}

- (void)deletePage:(SketchPage *)page {
    
}

@end
