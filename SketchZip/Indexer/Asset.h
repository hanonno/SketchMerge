//
//  SketchItem.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Realm/Realm.h>


@class SketchLayer, SketchPage;


@protocol Asset <NSObject>

@property (strong) NSString     *objectId;
@property (strong) NSString     *objectClass;

@property (strong) NSString     *name;

@property (readonly) NSImage    *previewImage;
@property (strong) NSString     *previewImagePath;

@end


@interface Asset : RLMObject <Asset>

@property (strong) NSString     *objectId;
@property (strong) NSString     *objectClass;

@property (strong) NSString     *fileId;
@property (strong) NSString     *filePath;

@property (strong) NSString     *pageId;
@property (strong) NSString     *pageName;

@property (strong) NSString     *name;

@property (assign) float        x;
@property (assign) float        y;
@property (assign) float        width;
@property (assign) float        height;

// Artboard only
@property (strong) NSString     *presetName;
@property (assign) float        presetWidth;
@property (assign) float        presetHeight;

@property (strong) NSString     *textContent;           // Used for full text search

@property (readonly) NSImage    *previewImage;
@property (strong) NSString     *previewImagePath;

+ (Asset *)assetWithSketchLayer:(SketchLayer *)layer;

@end


@interface AssetGroup : RLMObject

@property (strong) NSString     *objectId;

@property (strong) NSString     *fileId;
@property (strong) NSString     *pageId;
@property (strong) NSString     *pageName;

@property (strong) NSString     *title;
@property (strong) NSString     *subtitle;

+ (AssetGroup *)groupWithSketchPage:(SketchPage *)page;

- (NSInteger)numberOfAssets;
- (Asset *)assetAtIndex:(NSInteger)index;

@end


@interface AssetCollection : NSObject

@property (strong) RLMRealm     *realm;

- (instancetype)initWithRealm:(RLMRealm *)realm;

// Data Source
- (NSInteger)numberOfGroups;
- (AssetGroup *)groupAtIndex:(NSInteger)index;

- (NSInteger)numberOfAssetsInGroupAtIndex:(NSInteger)index;
- (id <Asset>)assetAtIndexPath:(NSIndexPath *)indexPath;

@end
