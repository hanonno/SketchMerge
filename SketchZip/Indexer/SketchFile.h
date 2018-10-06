//
//  SketchFile.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 02/08/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Asset.h"


@class SketchFile, SketchPage, SketchLayerDiff;


@interface SketchLayer : NSObject <Asset>

@property (nonatomic, strong) NSMutableDictionary   *JSON;
@property (nonatomic, strong) SketchPage            *page;

// Geometry
@property (assign, readonly) float                  x;
@property (assign, readonly) float                  y;
@property (assign, readonly) float                  width;
@property (assign, readonly) float                  height;

// Preview
@property (strong) NSImage                          *previewImage;
@property (strong) NSString                         *previewImagePath;

// Convenience
@property (strong, readonly) NSString               *name;
@property (strong, readonly) NSString               *objectId;
@property (strong, readonly) NSString               *objectClass;
@property (strong, readonly) NSString               *objectClassName;

// Presets
@property (nonatomic, strong, readonly) NSString    *presetName;
@property (nonatomic, strong, readonly) NSImage     *presetIcon;
@property (assign, readonly) float                  presetWidth;
@property (assign, readonly) float                  presetHeight;


// Text
@property (strong) NSString         *concatenatedStrings;


- (id)initWithJSON:(NSMutableDictionary *)JSON fromPage:(SketchPage *)page;

@end


@interface SketchPage : NSObject

@property (nonatomic, strong) NSDictionary          *JSON;

@property (nonatomic, strong, readonly) NSString    *objectId;
@property (nonatomic, strong, readonly) NSString    *name;
@property (nonatomic, strong) NSMutableDictionary   *layers;
@property (nonatomic, strong) NSMutableDictionary   *symbolsById;

@property (nonatomic, strong) SketchFile            *file;

- (id)initWithJSON:(NSDictionary *)JSON sketchFile:(SketchFile *)sketchFile;

- (void)insertLayer:(SketchLayer *)layer;
- (void)updateLayer:(SketchLayer *)layer;
- (void)deleteLayer:(SketchLayer *)layer;

@end


@interface SketchFile : NSObject

@property (strong) NSURL                *fileURL;
@property (strong) NSMutableDictionary  *pages;

@property (readonly) NSString           *objectId;
@property (readonly) NSString           *name;

- (id)initWithFileURL:(NSURL *)fileURL;

- (void)loadPages;
- (void)writePages;

- (SketchPage *)pageWithId:(NSString *)pageId;

- (void)insertPage:(SketchPage *)page;
- (void)updatePage:(SketchPage *)page;
- (void)deletePage:(SketchPage *)page;

- (void)generatePreviews;
- (void)generatePreviewsInDirectory:(NSString *)previewImageDirectory;

@end
