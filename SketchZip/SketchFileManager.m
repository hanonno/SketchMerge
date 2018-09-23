//
//  SketchFileManager.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 23/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchFileManager.h"


@implementation SketchFileIndexOperation

+ (SketchFileIndexOperation *)operationWithPath:(NSString *)path {
    SketchFileIndexOperation *operation = [[SketchFileIndexOperation alloc] init];
    
    operation.path = path;
    
    return operation;
}

- (void)main {
    CFTimeInterval startTime = CACurrentMediaTime();
    
    self.sketchFile = [[SketchFile alloc] initWithFileURL:[NSURL fileURLWithPath:self.path]];
    
    CFTimeInterval endTime = CACurrentMediaTime();
    NSLog(@"Index time: %g s", endTime - startTime);
}

@end


@interface SketchFileManager ()

@property (nonatomic, strong) NSMetadataQuery   *query;
@property (nonatomic, strong) NSOperationQueue  *indexQueue;

@end


@implementation SketchFileManager

- (id)init {
    self = [super init];
    
    _query = [[NSMetadataQuery alloc] init];
    _indexQueue = [[NSOperationQueue alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidUpdateResults:) name:NSMetadataQueryDidUpdateNotification object:_query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidGatherInitialResults:) name:NSMetadataQueryDidFinishGatheringNotification object:_query];
    
    NSPredicate *fileTypePredicate = [NSPredicate predicateWithFormat:@"kMDItemContentTypeTree == 'public.image'"];
    NSPredicate *sketchFilePredicate = [NSPredicate predicateWithFormat:@"kMDItemContentTypeTree == 'com.bohemiancoding.sketch.drawing.single'"];
    NSPredicate *fileNamePredicate = [NSPredicate predicateWithFormat:@"kMDItemDisplayName == 'HAN-Locker'"];
    [_query setPredicate:sketchFilePredicate];
    
    NSArray *searchScopes = @[NSMetadataQueryUserHomeScope];
    [_query setSearchScopes:searchScopes];

    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:(NSString *)kMDItemDisplayName ascending:YES];
    [_query setSortDescriptors:@[nameSortDescriptor]];

//    // Set the search scope. In this case it will search the User's home directory
//    // and the iCloud documents area
//    NSArray *searchScopes;
//    searchScopes=[NSArray arrayWithObjects:NSMetadataQueryUserHomeScope,
//                  NSMetadataQueryUbiquitousDocumentsScope,nil];
//    [metadataSearch setSearchScopes:searchScopes];
//
//    // Begin the asynchronous query
//    [metadataSearch startQuery];

    
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
    
    CFTimeInterval startTime = CACurrentMediaTime();

    NSUInteger i=0;
    for (i=0; i < [self.query resultCount]; i++) {
        NSMetadataItem *result = [self.query resultAtIndex:i];
        NSString *displayName = [result valueForAttribute:(NSString *)kMDItemDisplayName];
        
//        NSLog(@"Path: %@", [result valueForAttribute:@"kMDItemPath"]);
        
        NSString *filePath = [result valueForAttribute:@"kMDItemPath"];
        
        SketchFileIndexOperation *indexOperation = [SketchFileIndexOperation operationWithPath:filePath];
        
        [self.indexQueue addOperation:indexOperation];
        
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
    
    CFTimeInterval endTime = CACurrentMediaTime();
    NSLog(@"Total Runtime: %g s", endTime - startTime);

}

@end
