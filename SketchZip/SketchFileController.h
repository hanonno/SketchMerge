//
//  SketchFileController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 20/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "SketchPage.h"
#import "SketchDiffTool.h"


@interface PageItem : NSObject

@property (strong) SketchPage   *page;

@property (strong) NSString     *name;
@property (strong) NSArray      *layerItems;


@end


@interface LayerItem : NSObject

@property (strong) SketchLayer  *layer;

@property (strong) NSString     *name;
@property (strong) NSImage      *icon;
@property (strong) NSImage      *previewImage;

@end


@interface Filter : NSObject
- (BOOL)matchLayer:(SketchLayer *)layer;
@end


@interface KeywordFilter : Filter
@property (strong) NSString *keywords;
@end


@interface PresetFilter : Filter
@property (strong) NSString *name;
@end


@interface SketchFileController : NSObject

+ (NSArray *)pagesFromOperations:(NSArray *)pageOperations;

@property (strong) NSArray  *pages;
@property (strong) NSArray  *filters;

// Filtering
- (void)reloadData;

// Datasource
- (NSInteger)numberOfPages;
- (NSInteger)numberOfLayersInPageAtIndex:(NSInteger)pageIndex;

- (PageItem *)pageItemAtIndex:(NSInteger)index;
- (SketchPage *)pageAtIndex:(NSInteger)index;

- (LayerItem *)layerItemAtIndexPath:(NSIndexPath *)indexPath;
- (SketchLayer *)layerAtIndexPath:(NSIndexPath *)indexPath;

@end
