//
//  SketchPage.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 02/08/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchFile.h"
#import "SketchDiffTool.h"
#import "SSZipArchive.h"
#import "NSImage+PNGAdditions.h"


static const BOOL kLoggingEnabled = NO;


@interface SketchLayer ()

@property (strong) NSMutableArray   *strings;

@end


@implementation SketchLayer

@synthesize previewImage = _previewImage;

- (id)initWithJSON:(NSMutableDictionary *)JSON fromPage:(SketchPage *)page {
    self = [super init];

    _JSON = JSON;
    _page = page;
    _previewImage = nil;
    _strings = [[NSMutableArray alloc] init];
    
    [self collectStringFromLayer:_JSON];
    
    self.concatenatedStrings = [self.strings componentsJoinedByString:@" "];
    
    return self;
}

- (void)collectStringFromLayer:(NSDictionary *)rootLayer {
    if([rootLayer[@"_class"] isEqualToString:@"text"]) {
        NSString *string = rootLayer[@"attributedString"][@"string"];
        
        if(string) {
            [self.strings addObject:string];
        }
    }
    else if([rootLayer[@"_class"] isEqualToString:@"symbolInstance"]) {
        for (NSDictionary *override in rootLayer[@"overrideValues"]) {
            NSString *string = override[@"value"];
            
            if(string) {
                [self.strings addObject:string];
            }
        }
    }

    NSArray *sublayers = rootLayer[@"layers"];
    
    if(sublayers) {
        for (NSDictionary *sublayer in sublayers) {
            [self collectStringFromLayer:sublayer];
        }
    }
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

- (NSString *)objectClassName {
    NSString *objectClass = self.objectClass;
    
    if([objectClass isEqualToString:@"artboard"]) {
        return @"Artboard";
    }
    
    return @"Unknown";
}

- (NSMutableDictionary *)frame {
    return self.JSON[@"frame"];
}

- (float)x {
    return [self.frame[@"x"] floatValue];
}

- (float)y {
    return [self.frame[@"y"] floatValue];
}

- (float)width {
    return [self.frame[@"width"] floatValue];
}

- (float)height {
    return [self.frame[@"height"] floatValue];
}

- (NSString *)presetName {
    return _JSON[@"presetDictionary"][@"name"];
}

- (float)presetWidth {
    return [_JSON[@"presetDictionary"][@"width"] floatValue];
}

- (float)presetHeight {
    return [_JSON[@"presetDictionary"][@"height"] floatValue];
}


- (NSImage *)presetIcon {
    NSImage *image = [NSImage imageNamed:self.presetName];
    
    if(!image && self.presetName != nil) {
        NSLog(@"Missing preview image: %@", self.presetName);
    }
    
    return [NSImage imageNamed:@"Artboard"];
}

- (void)setPreviewImage:(NSImage *)previewImage {
    _previewImage = previewImage;
}

- (NSImage *)previewImage {
    if(!_previewImage) {
        _previewImage = [[NSImage alloc] initWithContentsOfFile:_previewImagePath];
        _previewImage = [_previewImage scaleToSize:NSMakeSize(480, 480)];
    }
    
    return _previewImage;
}

@end


@implementation SketchPage

- (id)initWithJSON:(NSDictionary *)JSON sketchFile:(SketchFile *)sketchFile {
    self = [super init];
    
    _JSON = JSON;
    _file = sketchFile;
    
    NSMutableDictionary *layers = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *symbolsById = [[NSMutableDictionary alloc] init];
    
    for (NSMutableDictionary *layer in _JSON[@"layers"]) {
        if(layer[@"do_objectID"] != nil) {
            if([layer[@"_class"] isEqualToString:@"symbolMaster"]) {
                symbolsById[layer[@"do_objectID"]] = [[SketchLayer alloc] initWithJSON:layer fromPage:self];
            }
            else {
                layers[layer[@"do_objectID"]] = [[SketchLayer alloc] initWithJSON:layer fromPage:self];
            }
        }
    }
    
    _layers = layers;
    _symbolsById = symbolsById;
    
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

- (NSString *)name {
    return [self.fileURL lastPathComponent];
}

- (NSString *)objectId {
    return self.documentJSON[@"do_objectID"];
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
        
        if(!pageData) {
            NSLog(@"Error: couldn't load data for: %@", currentPagePath);
            return;
        }
        
        NSDictionary *pageJSON = [NSJSONSerialization JSONObjectWithData:pageData options:NSJSONReadingMutableContainers error:nil];
        
        NSString *objectID = pageJSON[@"do_objectID"];
        
        pagesLookup[objectID] = [[SketchPage alloc] initWithJSON:pageJSON sketchFile:self];
    }
    
    self.pages = pagesLookup;
    
    // Load document & meta JSON
    NSString *documentDataPath = [[self.tempFileURL.path stringByAppendingPathComponent:@"document"] stringByAppendingPathExtension:@"json"];
    NSData *documentData = [NSData dataWithContentsOfFile:documentDataPath];
    
    if(!documentData) { NSLog(@"Error: couldn't load document data for: %@", documentDataPath); return; }
    
    self.documentJSON = [NSJSONSerialization JSONObjectWithData:documentData options:0 error:nil];
    
    NSString *metaDataPath = [[self.tempFileURL.path stringByAppendingPathComponent:@"meta"] stringByAppendingPathExtension:@"json"];
    NSData *metaData = [NSData dataWithContentsOfFile:metaDataPath];
    
    if(!metaData) { NSLog(@"Error: couldn't load meta data for: %@", metaDataPath); return; }
    
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
    [self.pages setValue:page forKey:page.objectId];
}

- (void)updatePage:(SketchPage *)page {
    [self.pages setValue:page forKey:page.objectId];
}

- (void)deletePage:(SketchPage *)page {
    [self.pages removeObjectForKey:page.objectId];
}

- (void)generatePreviews {
    [self generatePreviewsInDirectory:NSTemporaryDirectory()];
}

- (void)generatePreviewsInDirectory:(NSString *)previewImageDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *sketchToolPath = @"/Applications/Sketch.app/Contents/Resources/sketchtool/bin/sketchtool";
    
    if (![fileManager fileExistsAtPath:sketchToolPath]) {
        sketchToolPath = [[NSBundle mainBundle] pathForResource:@"sketchtool/bin/sketchtool" ofType:nil];
    }
    
    NSURL *previewImageDirectoryURL = [NSURL fileURLWithPath:previewImageDirectory];
    previewImageDirectoryURL = [previewImageDirectoryURL URLByAppendingPathComponent:[NSUUID UUID].UUIDString];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:previewImageDirectoryURL.path withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:sketchToolPath];
    [task setArguments:@[
        @"export",
        @"artboards",
        self.fileURL.path,
        [NSString stringWithFormat:@"--output=%@", previewImageDirectoryURL.path],
        @"--use-id-for-name",
        @"--include-symbols=YES",
        @"--overwriting=YES",
        @"--background=#ffffff"
        //        [NSString stringWithFormat:@"--items=%@", [objectIds componentsJoinedByString:@","]]
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
    
    NSLog(@"OUTPUT DIR: %@", previewImageDirectoryURL);
    
    NSString *result;
    if (errorData.length == 0) {
        for(SketchPage *page in self.pages.allValues) {
            for (SketchLayer *layer in page.layers.allValues) {
                layer.previewImagePath = [[previewImageDirectoryURL.path stringByAppendingPathComponent:layer.objectId] stringByAppendingPathExtension:@"png"];
            }
        }
    } else {
        result = [[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding];
        NSLog(@"Error: %@", result);
    }
}

@end
