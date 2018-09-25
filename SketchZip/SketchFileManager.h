//
//  SketchFileManager.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 23/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Appkit/AppKit.h>
#import "SketchPage.h"


@class SketchFileIndexOperation, SketchFileManager;


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


@protocol SketchFileManagerDelegate <NSObject>

- (void)sketchFileManager:(SketchFileManager *)fileManager didIndexFile:(SketchFile *)file;

@end

//#define SketchFileManagerDidIndexFileNotification  @"SketchFileManagerDidIndexFileNotification"


@interface SketchFileManager : NSObject

@property (assign) id <SketchFileManagerDelegate> delegate;

- (void)startIndexing;
- (void)pauseIndexing;

@end
