//
//  SketchFileController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 20/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchFileController.h"

@implementation PageItem

@end


@implementation LayerItem

@end


@implementation Filter

- (BOOL)matchLayer:(SketchLayer *)layer {
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
    NSString *keywords = self.keywords.copy;
    
    if(keywords == nil || keywords.length == 0) {
        return YES;
    }
    
    NSString *name = layer.name.copy;
    
    if(!self.isCaseSensitive) {
        name = name.lowercaseString;
        keywords = keywords.lowercaseString;
    }
    
    if([name containsString:keywords]) {
        return YES;
    }
    
    return NO;
}

@end

@implementation PresetFilter

- (BOOL)matchLayer:(SketchLayer *)layer {
    if([layer.presetName isEqualToString:self.name]) {
        return YES;
    }
    
    return NO;
}

@end


@implementation SketchFileController

@synthesize pageItems = _pageItems;

+ (NSArray *)pagesFromOperations:(NSArray *)pageOperations {
    KeywordFilter *keywordFilter = [[KeywordFilter alloc] init];
    keywordFilter.keywords = @"HAHA";
    
    PresetFilter *presetFilter = [[PresetFilter alloc] init];
    presetFilter.name = @"iPhone 8";

    NSMutableArray *pageItems = [[NSMutableArray alloc] init];
    
    for (SKPageOperation *pageOperation in pageOperations) {
        PageItem *pageItem = [[PageItem alloc] init];
        pageItem.page = pageOperation.page;
        pageItem.name = pageItem.page.name;
        
        NSMutableArray *layerItems = [[NSMutableArray alloc] init];
        
        for (SKLayerOperation *layerOperation in pageOperation.layerOperations) {
            if(![presetFilter matchLayer:layerOperation.layer]) {
                continue;
            }
//
//            if(![keywordFilter matchLayer:layerOperation.layer]) {
//                continue;
//            }

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

- (void)setPageItems:(NSArray *)pages {
    _pageItems = pages;
    [self reloadData];
}

- (NSArray *)pageItems {
    return _pageItems;
}

- (void)reloadData {
    NSMutableArray *filteredPageItems = [[NSMutableArray alloc] init];
    
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
        }
        
        pageItem.layerItems = layerItems;
        [filteredPageItems addObject:pageItem];
    }
    
    self.filteredPageItems = filteredPageItems;
}

- (NSInteger)numberOfPages {
    return self.pageItems.count;
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
