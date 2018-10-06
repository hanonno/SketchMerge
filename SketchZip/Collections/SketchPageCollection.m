//
//  SketchFileController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 20/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchPageCollection.h"


#import "Asset.h"


@implementation PageItem
@end


@implementation LayerItem
@end


@implementation Filter

- (id)init {
    self = [super init];
    
    _enabled = YES;
    
    return self;
}

- (BOOL)matchLayer:(SketchLayer *)layer {
    return YES;
}

- (BOOL)matchAsset:(Asset *)asset {
    return YES;
}

@end

@implementation KeywordFilter

- (id)init {
    self = [super init];
    
    _keywords = nil;
    _isCaseSensitive = NO;
    
    return self;
}

- (BOOL)matchLayer:(SketchLayer *)layer {
    if(!self.enabled) {
        return YES;
    }
    
    NSString *keywords = self.keywords.copy;
    
    if(keywords == nil || keywords.length == 0) {
        return YES;
    }
    
    NSString *name = layer.name.copy;
    NSString *concatenatedStrings = layer.concatenatedStrings.copy;
    
    if(!self.isCaseSensitive) {
        name = name.lowercaseString;
        keywords = keywords.lowercaseString;
        concatenatedStrings = concatenatedStrings.lowercaseString;
    }
    
    if([name containsString:keywords]) {
        return YES;
    }
    
    if([concatenatedStrings containsString:keywords]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)matchAsset:(Asset *)asset {
    if(!self.enabled) {
        return YES;
    }
    
    NSString *keywords = self.keywords.copy;
    
    if(keywords == nil || keywords.length == 0) {
        return YES;
    }
    
    NSString *name = asset.name;
    NSString *textContent = asset.textContent;
    
    if(!self.isCaseSensitive) {
        keywords = keywords.lowercaseString;
        
        name = name.lowercaseString;
        textContent = textContent.lowercaseString;
    }
    
    if([name containsString:keywords]) {
        return YES;
    }
    
    if([textContent containsString:keywords]) {
        return YES;
    }
    
    return NO;
}

@end


@implementation SizeFilter

- (BOOL)matchLayer:(SketchLayer *)layer {
    if(!self.enabled) {
        return YES;
    }
    
    if([self.presetName isEqualToString:@"Any device"]) {
        return YES;
    }
    
    if(self.presetName == nil || self.presetName.length == 0) {
        return YES;
    }
    
    if([layer.presetName hasPrefix:self.presetName]) {
        return YES;
    }
    
    return NO;
}

@end


@implementation PathFilter

- (BOOL)matchLayer:(SketchLayer *)layer {
    if(!self.enabled) {
        return YES;
    }

    if(!self.path) {
        return YES;
    }
    
    if([layer.page.file.fileURL.path hasPrefix:self.path]) {
        return YES;
    }

    return NO;
}

@end


@interface SketchPageCollection ()

@property (strong) NSArray  *pageItems;
@property (strong) NSArray  *filteredPageItems;

- (PageItem *)pageItemAtIndex:(NSInteger)index;
- (LayerItem *)layerItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@implementation SketchPageCollection

@synthesize pageItems = _pageItems;

+ (NSArray *)pagesFromOperations:(NSArray *)pageOperations {
    NSMutableArray *pageItems = [[NSMutableArray alloc] init];
    
    for (SKPageOperation *pageOperation in pageOperations) {
        PageItem *pageItem = [[PageItem alloc] init];
        pageItem.page = pageOperation.page;
        pageItem.name = pageItem.page.name;
        
        NSMutableArray *layerItems = [[NSMutableArray alloc] init];
        
        for (SKLayerOperation *layerOperation in pageOperation.layerOperations) {
            LayerItem *layerItem = [[LayerItem alloc] init];
            layerItem.layer = layerOperation.layer;
            layerItem.name = layerItem.layer.name;
            layerItem.icon = layerItem.layer.presetIcon;
            layerItem.previewImage = layerItem.layer.previewImage;
            
            [layerItems addObject:layerItem];
        }
        
        pageItem.layerItems = layerItems;
        [pageItems addObject:pageItem];
    }
    
    return pageItems;
}

- (id)init {
    self = [super init];
    
    _filters = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)setPageItems:(NSArray *)pages {
    _pageItems = pages;
    [self reloadData];
}

- (NSArray *)pageItems {
    return _pageItems;
}

//- (void)addPagesFromFile:(SketchFile *)sketchFile {

- (void)addPages:(NSArray *)pages {
    NSMutableArray *pageItems = [[NSMutableArray alloc] init];

    for (SketchPage *page in pages) {
        PageItem *pageItem = [[PageItem alloc] init];
        pageItem.page = page;
        pageItem.name = page.name;
        
        NSMutableArray *layerItems = [[NSMutableArray alloc] init];
        
        for (SketchLayer *layer in page.layers.allValues) {
            LayerItem *layerItem = [[LayerItem alloc] init];
            layerItem.layer = layer;
            layerItem.name = layer.name;
            layerItem.icon = layer.presetIcon;
            layerItem.previewImage = layer.previewImage;
            
            [layerItems addObject:layerItem];
        }
        
        pageItem.layerItems = layerItems;
        [pageItems addObject:pageItem];
    }
    
    [pageItems addObjectsFromArray:self.pageItems];
    self.pageItems = pageItems;    
}

- (void)addFilter:(Filter *)filter {
    [self.filters addObject:filter];
    [self reloadData];
}

- (void)removeFilter:(Filter *)filter {
    [self.filters removeObject:filter];
    [self reloadData];
}


- (void)reloadData {
    NSMutableArray *filteredPageItems = [[NSMutableArray alloc] init];
    
    NSInteger pageCount = 0;
    NSInteger layerCount = 0;
    
    for (PageItem *pageItem in self.pageItems) {
        NSMutableArray *layerItems = [[NSMutableArray alloc] init];
        
        for (LayerItem *layerItem in pageItem.layerItems) {
            BOOL exit = NO;
            
            for (Filter *filter in self.filters) {
                if(![filter matchLayer:layerItem.layer]) {
                    exit = YES;
                }
            }
            
            if(exit) {
                continue;
            }
            
            [layerItems addObject:layerItem];
            layerCount = layerCount + 1;
        }
        
        if(layerItems.count == 0) {
            continue;
        }
        
        PageItem *newPageItem = [[PageItem alloc] init];
        newPageItem.name = pageItem.name;
        newPageItem.page = pageItem.page;
        newPageItem.layerItems = layerItems;
        
        [filteredPageItems addObject:newPageItem];
        pageCount = pageCount + 1;
    }
    
    self.filteredPageItems = filteredPageItems;
}

- (NSInteger)numberOfPages {
    return self.filteredPageItems.count;
}

- (NSInteger)numberOfLayersInPageAtIndex:(NSInteger)pageIndex {
    return [[[self pageItemAtIndex:pageIndex] layerItems] count];
}

- (PageItem *)pageItemAtIndex:(NSInteger)index {
    return [self.filteredPageItems objectAtIndex:index];
}

- (SketchPage *)pageAtIndex:(NSInteger)index {
    return [[self pageItemAtIndex:index] page];
}

- (SketchLayer *)layerAtIndexPath:(NSIndexPath *)indexPath {
    return [(LayerItem *)[[[self pageItemAtIndex:indexPath.section] layerItems] objectAtIndex:indexPath.item] layer];
}

- (LayerItem *)layerItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[[self pageItemAtIndex:indexPath.section] layerItems] objectAtIndex:indexPath.item];
}

@end
