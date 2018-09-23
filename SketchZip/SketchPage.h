//
//  SketchPage.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 02/08/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SketchFile, SketchPage, SketchLayerDiff;


@interface SketchLayer : NSObject

@property (nonatomic, strong) NSMutableDictionary   *JSON;
@property (nonatomic, strong) SketchPage            *page;

// Preview
@property (nonatomic, strong) NSImage               *previewImage;

// Convenience
@property (nonatomic, strong, readonly) NSString    *name;
@property (nonatomic, strong, readonly) NSString    *objectId;
@property (nonatomic, strong, readonly) NSString    *objectClass;
@property (nonatomic, strong, readonly) NSString    *objectClassName;

// Presets
@property (nonatomic, strong, readonly) NSString    *presetName;
@property (nonatomic, strong, readonly) NSImage     *presetIcon;


- (id)initWithJSON:(NSMutableDictionary *)JSON fromPage:(SketchPage *)page;

@end

@interface SketchArtboard : SketchLayer

@end

@interface SketchRect : SketchLayer

@property (assign) NSInteger x;
@property (assign) NSInteger y;

@property (assign) NSInteger width;
@property (assign) NSInteger height;

@end

@interface SketchText : SketchLayer

@end


@interface SketchPage : NSObject

@property (nonatomic, strong) NSDictionary          *JSON;

@property (nonatomic, strong, readonly) NSString    *objectId;
@property (nonatomic, strong, readonly) NSString    *name;
@property (nonatomic, strong) NSMutableDictionary   *layers;

@property (nonatomic, strong) SketchFile            *sketchFile;

- (id)initWithJSON:(NSDictionary *)JSON sketchFile:(SketchFile *)sketchFile;

- (void)insertLayer:(SketchLayer *)layer;
- (void)updateLayer:(SketchLayer *)layer;
- (void)deleteLayer:(SketchLayer *)layer;

@end


@interface SketchFile : NSObject

@property (strong) NSURL                *fileURL;
@property (strong) NSMutableDictionary  *pages;

@property (readonly) NSString          *fileName;

- (id)initWithFileURL:(NSURL *)fileURL;

- (void)loadPages;
- (void)writePages;

- (SketchPage *)pageWithId:(NSString *)pageId;

- (void)insertPage:(SketchPage *)page;
- (void)updatePage:(SketchPage *)page;
- (void)deletePage:(SketchPage *)page;

@end
