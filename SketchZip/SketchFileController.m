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

- (BOOL)matchLayer:(SketchLayer *)layer {
    if([layer.name containsString:self.keywords]) {
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
            
            if(![keywordFilter matchLayer:layerOperation.layer]) {
                continue;
            }

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

- (void)reloadData {
    
}

- (NSInteger)numberOfPages {
    return self.pages.count;
}

- (NSInteger)numberOfLayersInPageAtIndex:(NSInteger)pageIndex {
    return [[[self pageItemAtIndex:pageIndex] layerItems] count];
}

- (PageItem *)pageItemAtIndex:(NSInteger)index {
    return [self.pages objectAtIndex:index];
}

- (SketchPage *)pageAtIndex:(NSInteger)index {
    return [[self.pages objectAtIndex:index] page];
}

- (SketchLayer *)layerAtIndexPath:(NSIndexPath *)indexPath {
    return [(LayerItem *)[[[self pageItemAtIndex:indexPath.section] layerItems] objectAtIndex:indexPath.item] layer];
}


- (LayerItem *)layerItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[[self pageItemAtIndex:indexPath.section] layerItems] objectAtIndex:indexPath.item];
}

@end
