//
//  SketchItem.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Realm/Realm.h>



@class Filter, SketchLayer, SketchPage;


@interface Asset : RLMObject

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

//
@property (assign) BOOL         favorited;


+ (Asset *)assetWithSketchLayer:(SketchLayer *)layer;
- (void)takeValuesFromLayer:(SketchLayer *)layer;

@end


@interface AssetGroup : NSObject

@property (strong) NSString         *title;
@property (strong) NSString         *subtitle;
@property (strong) NSMutableArray   *assets;

@end


@class AssetCollection;


@protocol AssetCollectionDelegate <NSObject>

- (void)assetCollectionDidUpdate:(AssetCollection *)assetCollection;
- (void)assetCollectionDidUpdate:(AssetCollection *)assetCollection filter:(Filter *)filter;

@end


@interface AssetCollection : NSObject

@property (strong) RLMRealm     *realm;

- (instancetype)initWithRealm:(RLMRealm *)realm;

- (void)reloadData;

// Filtering
- (void)addFilter:(Filter *)filter;
- (void)removeFilter:(Filter *)filter;
- (void)replaceFilter:(Filter *)filter; // Removes all filters of the same class and adds the new one
- (NSInteger)numberOfFilers;
- (Filter *)filterAtIndex:(NSInteger)index;

- (NSArray *)activeFilters;
- (NSArray *)matchedFilters;

// Data Source
- (NSInteger)numberOfGroups;
- (AssetGroup *)groupAtIndex:(NSInteger)index;
- (Asset *)assetAtIndexPath:(NSIndexPath *)indexPath;

// Delegates
- (void)addDelegate:(id <AssetCollectionDelegate>)delegate;
- (void)removeDelegate:(id <AssetCollectionDelegate>)delegate;

@end
