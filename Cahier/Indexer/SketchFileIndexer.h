//
//  SketchFileManager.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 23/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Appkit/AppKit.h>
#import <Realm/Realm.h>
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
@property (strong) SketchFile       *sketchFile;

@property (strong) NSString         *realmPath;
@property (strong) NSString         *previewImageDirectory;

@property (assign) CFTimeInterval   startTime;
@property (assign) CFTimeInterval   endTime;

+ (SketchFileIndexOperation *)operationWithSketchFile:(SketchFile *)sketchFile;

@end


@protocol SketchFileIndexerDelegate <NSObject>

- (void)sketchFileIndexer:(SketchFileIndexer *)fileIndexer willIndexFile:(SketchFile *)sketchFile;
- (void)sketchFileIndexer:(SketchFileIndexer *)fileIndexer didIndexFile:(SketchFile *)sketchFile;

@end


@interface SketchFileIndexer : NSObject

@property (assign) id <SketchFileIndexerDelegate>   delegate;

@property (strong) NSString                         *directory;
@property (strong) NSString                         *metaDirectory;

@property (strong) RLMRealm                         *realm;
@property (strong) NSString                         *realmPath;
@property (strong) NSString                         *previewImageDirectory;

- (id)initWithDirectory:(NSString *)directory;

- (void)startIndexing;
- (void)pauseIndexing;

@end
