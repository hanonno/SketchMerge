//
//  SketchFileManager.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 23/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Appkit/AppKit.h>
#import "SketchFile.h"


@class SketchFileIndexOperation, SketchFileIndexer;


@protocol SketchFileIndexOperationDelegate <NSObject>

- (void)sketchFileIndexOperationDidFinish:(SketchFileIndexOperation *)fileIndexOperation;

@end


@interface SketchFileIndexOperation : NSOperation {
    BOOL _isFinished;
    BOOL _isExecuting;
}

@property (assign) id <SketchFileIndexOperationDelegate> delegate;
@property (strong) NSString         *path;
@property (strong) SketchFile       *sketchFile;

@property (assign) CFTimeInterval   startTime;
@property (assign) CFTimeInterval   endTime;

+ (SketchFileIndexOperation *)operationWithPath:(NSString *)path;

@end


@protocol SketchFileIndexerDelegate <NSObject>

- (void)sketchFileIndexer:(SketchFileIndexer *)fileIndexer didIndexFile:(SketchFile *)file;

@end


@interface SketchFileIndexer : NSObject

@property (strong) NSString                         *directory;
@property (assign) id <SketchFileIndexerDelegate>   delegate;

- (id)initWithDirectory:(NSString *)directory;

- (void)startIndexing;
- (void)pauseIndexing;

@end
