//
//  SketchFileManager.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 23/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchFileManager.h"


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

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.sketchFile = [[SketchFile alloc] initWithFileURL:[NSURL fileURLWithPath:self.path]];
    
        [self.sketchFile generatePreviews];
    
        self.endTime = CACurrentMediaTime();
        
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            
            self->_isExecuting = NO;
            self->_isFinished = YES;
            
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
//        });
    
        if(self.delegate && [self.delegate respondsToSelector:@selector(sketchFileIndexOperationDidFinish:)]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate sketchFileIndexOperationDidFinish:self];
//            });
        }
//    });
}

@end


@interface SketchFileManager () <SketchFileIndexOperationDelegate>

@property (nonatomic, strong) NSMetadataQuery   *query;
@property (nonatomic, strong) NSOperationQueue  *indexQueue;

@property (assign) CFTimeInterval   startTime;
@property (assign) CFTimeInterval   endTime;

@end


@implementation SketchFileManager

@synthesize delegate = _delegate;

- (id)init {
    self = [super init];
    
    _query = [[NSMetadataQuery alloc] init];
    _indexQueue = [[NSOperationQueue alloc] init];
    _indexQueue.maxConcurrentOperationCount = 16;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidUpdateResults:) name:NSMetadataQueryDidUpdateNotification object:_query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidGatherInitialResults:) name:NSMetadataQueryDidFinishGatheringNotification object:_query];

//    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"kMDItemContentTypeTree == 'public.image'"];
//    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"kMDItemContentTypeTree == 'com.bohemiancoding.sketch.drawing.single'"];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"kMDItemContentTypeTree == 'com.bohemiancoding.sketch.drawing.single'"];
//    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"kMDItemDisplayName == 'UW-Tutorial'"];
    [_query setPredicate:searchPredicate];
    
//    NSArray *searchScopes = @[NSMetadataQueryUserHomeScope];
    NSArray *searchScopes = @[[@"~/Design/Hanno" stringByExpandingTildeInPath]];
    [_query setSearchScopes:searchScopes];

//    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:(NSString *)kMDItemDisplayName ascending:YES];
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:(NSString *)kMDItemLastUsedDate ascending:NO];
    [_query setSortDescriptors:@[nameSortDescriptor]];
    
    return self;
}

- (void)startIndexing {
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
//    for (i=0; i < self.query.resultCount; i++) {
    for (i=0; i < 5; i++) {
        NSMetadataItem *result = [self.query resultAtIndex:i];
        NSString *filePath = [result valueForAttribute:@"kMDItemPath"];
        
        SketchFileIndexOperation *indexOperation = [SketchFileIndexOperation operationWithPath:filePath];
        indexOperation.delegate = self;
        
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
        [self.delegate sketchFileManager:self didIndexFile:fileIndexOperation.sketchFile];
    });
}

@end
