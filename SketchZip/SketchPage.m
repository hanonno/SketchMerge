//
//  SketchPage.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 02/08/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchPage.h"
#import "SketchDiffTool.h"


@implementation SketchLayer

- (id)initWithJSON:(NSDictionary *)JSON fromPage:(SketchPage *)page {
    self = [super init];

    _JSON = JSON;
    _page = page;
    _objectId = JSON[@"do_objectID"];
    _objectClass = JSON[@"_class"];
    _image = nil;

    return self;
}

- (NSString *)name {
    return _JSON[@"name"];
}

@end


@implementation SketchOperation

@end


@implementation SketchPage

- (id)initWithJSON:(NSDictionary *)JSON sketchFile:(SketchFile *)sketchFile {
    self = [super init];
    
    _JSON = JSON;
    _name = JSON[@"name"];
    _sketchFile = sketchFile;
    _operations = nil;
    
    return self;
}

- (void)insertLayer:(SketchLayer *)artboard {
    
}

- (void)updateLayer:(SketchLayer *)artboard {
    
}

- (void)deleteLayer:(SketchLayer *)artboard {
    
}

@end



@implementation SketchFile

+ (SketchFile *)readFromURL:(NSURL *)fileURL {
    SketchFile *sketchFile = [[SketchFile alloc] init];
    sketchFile.fileURL = fileURL;
    
    SketchDiffTool *sketchDiffTool = [[SketchDiffTool alloc] init];
    sketchFile.pages = [sketchDiffTool pagesFromFileAtURL:sketchFile.fileURL];
    
    return sketchFile;
}

@end
