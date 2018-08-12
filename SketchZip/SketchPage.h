//
//  SketchPage.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 02/08/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SketchArtboardPreviewOperation;


@class SketchPage;


typedef enum : NSUInteger {
    SketchOperationTypeInsert,
    SketchOperationTypeUpdate,
    SketchOperationTypeDelete,
    SketchOperationTypeNone
} SketchOperationType;


@interface SketchLayer : NSObject

@property (nonatomic, strong) NSDictionary  *JSON;
@property (nonatomic, strong) NSImage       *image;
@property (nonatomic, strong) NSString      *name;
@property (nonatomic, strong) NSString      *objectId;
@property (nonatomic, strong) NSString      *objectClass;
@property (nonatomic, strong) SketchPage    *page;

- (id)initWithJSON:(NSDictionary *)JSON fromPage:(SketchPage *)page;

@end


@interface SketchOperation : NSObject

@property (nonatomic, strong) NSString              *objectId;
@property (nonatomic, assign) SketchOperationType   type;

@property (nonatomic, strong) SketchLayer           *layerA;
@property (nonatomic, strong) NSImage               *previewImageA;

@property (nonatomic, strong) SketchLayer           *layerB;
@property (nonatomic, strong) NSImage               *previewImageB;

@end


@interface SketchPage : NSObject

@property (nonatomic, strong) NSDictionary          *JSON;
@property (nonatomic, strong) NSArray               *artboards;
@property (nonatomic, assign) SketchOperationType   operationType;

@property (nonatomic, strong) NSURL                 *fileURL;

- (id)initWithJSON:(NSDictionary *)JSON fileURL:(NSURL *)fileURL;

- (void)insertLayer:(SketchLayer *)artboard;
- (void)updateLayer:(SketchLayer *)artboard;
- (void)deleteLayer:(SketchLayer *)artboard;

@end
