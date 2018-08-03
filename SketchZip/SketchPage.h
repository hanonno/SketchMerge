//
//  SketchPage.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 02/08/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    SketchOperationTypeInsert,
    SketchOperationTypeUpdate,
    SketchOperationTypeDelete,
} SketchOperationType;

@interface SketchArtboard : NSObject

@property (nonatomic, strong) NSDictionary          *JSON;
@property (nonatomic, strong) NSImage               *image;
@property (nonatomic, strong) NSString              *name;
@property (nonatomic, strong) NSString              *objectId;
@property (nonatomic, assign) SketchOperationType   operationType;

- (id)initWithJSON:(NSDictionary *)JSON;

@end


@interface SketchPage : NSObject

@property (nonatomic, strong) NSDictionary          *JSON;
@property (nonatomic, strong) NSArray               *artboards;
@property (nonatomic, strong) NSArray               *changedArtboards;
@property (nonatomic, assign) SketchOperationType   operationType;

- (id)initWithJSON:(NSDictionary *)JSON;

- (void)insertArtboard:(SketchArtboard *)artboard;
- (void)updateArtboard:(SketchArtboard *)artboard;
- (void)deleteArtboard:(SketchArtboard *)artboard;

@end
