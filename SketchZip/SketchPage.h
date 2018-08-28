//
//  SketchPage.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 02/08/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SketchFile, SketchPage, SketchDiff;


@interface SketchLayer : NSObject

@property (nonatomic, strong) NSMutableDictionary   *JSON;
@property (nonatomic, strong) NSImage               *image;
@property (nonatomic, strong, readonly) NSString    *name;
@property (nonatomic, strong, readonly) NSString    *objectId;
@property (nonatomic, strong, readonly) NSString    *objectClass;
@property (nonatomic, strong) SketchPage            *page;

- (id)initWithJSON:(NSDictionary *)JSON fromPage:(SketchPage *)page;

@end


@interface SketchArtboard : SketchLayer

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

@property (strong) NSURL        *fileURL;
@property (strong) NSDictionary *pages;

- (id)initWithFileURL:(NSURL *)fileURL;

- (void)writePages;

- (void)applyDiff:(SketchDiff *)diff;
- (void)insertPage:(SketchPage *)page;
- (void)updatePage:(SketchPage *)page;
- (void)deletePage:(SketchPage *)page;

@end
