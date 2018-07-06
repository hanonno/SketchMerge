//
//  SketchFile.h
//  SketchZip
//
//  Created by Hanno on 05/07/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreSyncTransaction.h"


@interface SketchFile : NSObject

@property (strong) NSString *sketchToolPath;

- (NSDictionary *)artboardsForFileWithURL:(NSURL *)fileURL;

- (NSDictionary *)_pagesFromFileAtURL:(NSURL *)fileURL;

- (NSImage *)imageForArtboardWithID:(NSString *)artboardID inFileWithURL:(NSURL *)fileURL maxSize:(CGSize)maxSize;

- (NSArray *)diffFromFile:(NSURL *)oldFile to:(NSURL *)newFile;

@end


@interface CoreSyncTransaction (Sketch)

- (NSString *)pageID;

@end
