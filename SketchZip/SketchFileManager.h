//
//  SketchFileManager.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 23/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Appkit/AppKit.h>
#import "SketchPage.h"


@interface SketchFileManager : NSObject

- (void)startIndexing;
- (void)pauseIndexing;

@end


@interface SketchFileIndexOperation : NSOperation

@property (strong) NSString     *path;
@property (strong) SketchFile   *sketchFile;

+ (SketchFileIndexOperation *)operationWithPath:(NSString *)path;

@end
