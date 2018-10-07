//
//  SketchFileManager.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 23/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchFileIndexer.h"


#import "Asset.h"


@implementation SketchFileIndexOperation

@synthesize delegate = _delegate;

+ (SketchFileIndexOperation *)operationWithPath:(NSString *)path {
    SketchFileIndexOperation *operation = [[SketchFileIndexOperation alloc] init];
    
    operation.path = path;
    
    return operation;
}

- (id)init {
    self = [super init];
        _isExecuting = NO;
        _isFinished = NO;
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)main {
    self.startTime = CACurrentMediaTime();

    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];

    self.sketchFile = [[SketchFile alloc] initWithFileURL:[NSURL fileURLWithPath:self.path]];
    [self.sketchFile generatePreviewsInDirectory:self.previewImageDirectory];
    
//    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
//    config.fileURL = [NSURL fileURLWithPath:[@"~/Temp/SketchIndex.realm" stringByExpandingTildeInPath]];
//
    RLMRealm *realm = [RLMRealm realmWithURL:[NSURL fileURLWithPath:self.realmPath]];
    
    for(SketchPage *page in self.sketchFile.pages.allValues) {
        for(SketchLayer *layer in page.layers.allValues) {
            if(![layer.objectClass isEqualToString:@"artboard"]) {
                continue;
            }
            
            Asset *asset = [Asset objectInRealm:realm forPrimaryKey:layer.objectId];
            
            if(!asset) {
                asset = [Asset assetWithSketchLayer:layer];
            }
            else {
                [asset takeValuesFromLayer:layer];
            }

            [realm beginWriteTransaction];
            [realm addOrUpdateObject:asset];
            [realm commitWriteTransaction];
        }
    }

    self.endTime = CACurrentMediaTime();

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];

    self->_isExecuting = NO;
    self->_isFinished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];

    if(self.delegate && [self.delegate respondsToSelector:@selector(sketchFileIndexOperationDidFinish:)]) {
        [self.delegate sketchFileIndexOperationDidFinish:self];
    }
}

@end


@interface SketchFileIndexer () <SketchFileIndexOperationDelegate>

@property (nonatomic, strong) NSMetadataQuery   *query;
@property (nonatomic, strong) NSPredicate       *searchPredicate;
@property (nonatomic, strong) NSArray           *searchScopes;
@property (nonatomic, strong) NSArray           *sortDescriptors;

@property (nonatomic, strong) NSOperationQueue  *indexQueue;

@property (assign) CFTimeInterval   startTime;
@property (assign) CFTimeInterval   endTime;

@end


@implementation SketchFileIndexer

@synthesize delegate = _delegate;

- (id)init {
    self = [super init];
    
    _query = [[NSMetadataQuery alloc] init];
    _indexQueue = [[NSOperationQueue alloc] init];
    _indexQueue.maxConcurrentOperationCount = 32;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidUpdateResults:) name:NSMetadataQueryDidUpdateNotification object:_query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidGatherInitialResults:) name:NSMetadataQueryDidFinishGatheringNotification object:_query];

//    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"kMDItemContentTypeTree == 'public.image'"];
//    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"kMDItemContentTypeTree == 'com.bohemiancoding.sketch.drawing.single'"];
    _searchPredicate = [NSPredicate predicateWithFormat:@"kMDItemContentTypeTree == 'com.bohemiancoding.sketch.drawing.single'"];
    
//    NSArray *searchScopes = @[NSMetadataQueryUserHomeScope];
    _searchScopes = @[[@"~/Design/Hanno" stringByExpandingTildeInPath]];
    
//    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:(NSString *)kMDItemDisplayName ascending:YES];
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:(NSString *)kMDItemLastUsedDate ascending:NO];
    self.sortDescriptors = @[nameSortDescriptor];
    
    return self;
}

- (id)initWithDirectory:(NSString *)directory {
    self = [self init];

    _directory = directory;
    _metaDirectory = [directory stringByAppendingPathComponent:@"/meta"];
    [[NSFileManager defaultManager] createDirectoryAtPath:_metaDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    
    _searchScopes = @[directory];

    _realmPath = [[_metaDirectory stringByAppendingPathComponent:@"index"] stringByAppendingPathExtension:@"realm"];
    _realm = [RLMRealm realmWithURL:[NSURL fileURLWithPath:_realmPath]];
    _previewImageDirectory = [_metaDirectory stringByAppendingPathComponent:@"Previews"];
    
    return self;
}

- (void)startIndexing {
    [self.query setPredicate:self.searchPredicate];
    [self.query setSearchScopes:self.searchScopes];
    [self.query setSortDescriptors:self.sortDescriptors];
    [self.query startQuery];
}

- (void)pauseIndexing {
    
}

- (void)queryDidUpdateResults:(NSNotification *)notification {
    NSLog(@"Query updated!");
}

- (void)queryDidGatherInitialResults:(NSNotification *)notification {
    NSLog(@"Query has results!");
    
    self.startTime = CACurrentMediaTime();

    NSUInteger i=0;
    for (i=0; i < self.query.resultCount; i++) {
//    for (i=0; i < 5; i++) {
        NSMetadataItem *result = [self.query resultAtIndex:i];
        NSString *filePath = [result valueForAttribute:@"kMDItemPath"];

        SketchFileIndexOperation *indexOperation = [SketchFileIndexOperation operationWithPath:filePath];
        indexOperation.delegate = self;
        indexOperation.realmPath = self.realmPath;
        indexOperation.previewImageDirectory = self.previewImageDirectory;

        [self.indexQueue addOperation:indexOperation];

        NSLog(@"Display Name: %@", [result valueForAttribute:@"kMDItemDisplayName"]);
//        NSLog(@"result at %lu - %@",i,displayName);
//        NSLog(@"Authors: %@", [result valueForAttribute:@"kMDItemAuthors"]);
//        NSLog(@"Created: %@", [result valueForAttribute:@"kMDItemContentCreationDate"]);
//        NSLog(@"Modified: %@", [result valueForAttribute:@"kMDItemContentModificationDate"]);
//        NSLog(@"Used: %@", [result valueForAttribute:@"kMDItemLastUsedDate"]);
//        NSLog(@"Size: %@", [result valueForAttribute:@"kMDItemFSSize"]);
//        NSLog(@"Path: %@", [result valueForAttribute:@"kMDItemPath"]);
//        NSLog(@"Label: %@", [result valueForAttribute:@"kMDItemFSLabel"]);
//        NSLog(@"Copyright: %@", [result valueForAttribute:@"kMDItemCopyright"]);
//        NSLog(@"Description: %@", [result valueForAttribute:@"kMDItemDescription"]);
//        NSLog(@"Fonts: %@", [result valueForAttribute:@"kMDItemFonts"]);
//        NSLog(@"Keywords: %@", [result valueForAttribute:@"kMDItemKeywords"]);
//        NSLog(@"Text: %@", [result valueForAttribute:@"kMDItemTextContent"]);
//        NSLog(@"Title: %@", [result valueForAttribute:@"kMDItemTitle"]);
//        NSLog(@"Layers: %@", [result valueForAttribute:@"kMDItemLayerNames"]);
//        NSLog(@"Pixel height: %@", [result valueForAttribute:@"kMDItemPixelHeight"]);
//        NSLog(@"Pixel width: %@", [result valueForAttribute:@"kMDItemPixelWidth"]);
//        NSLog(@"==============================================================================================================================");
//        NSLog(@"UTI: %@", [result valueForAttribute:@"kMDItemContentTypeTree"]);
    }
}

- (void)sketchFileIndexOperationDidFinish:(SketchFileIndexOperation *)fileIndexOperation {
    NSLog(@"Finished: %lu", (unsigned long)self.indexQueue.operationCount);
    
    if(self.indexQueue.operationCount == 1) {
        self.endTime = CACurrentMediaTime();
        NSLog(@"Total Runtime: %g s", self.endTime - self.startTime);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate sketchFileIndexer:self didIndexFile:fileIndexOperation.sketchFile];
    });
}

@end
