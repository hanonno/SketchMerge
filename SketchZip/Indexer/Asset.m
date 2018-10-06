//
//  SketchItem.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "Asset.h"
#import "NSImage+PNGAdditions.h"


#import "SketchFile.h"


@implementation Asset

@synthesize previewImage = _previewImage;

+ (NSString *)primaryKey {
    return @"objectId";
}

+ (NSArray *)ignoredProperties {
    return @[@"previewImage"];
}

+ (Asset *)assetWithSketchLayer:(SketchLayer *)layer {
    Asset *item = [[Asset alloc] init];
    
    item.objectId = layer.objectId;
    item.objectClass = layer.objectClass;
    item.name = layer.name;
    
    item.fileId = layer.page.file.objectId;
    item.filePath = layer.page.file.fileURL.path;

    item.pageId = layer.page.objectId;
    item.pageName = layer.page.name;
    
    item.x = layer.x;
    item.y = layer.y;
    item.width = layer.width;
    item.height = layer.height;
    
    item.presetName = layer.presetName;
    item.presetWidth = layer.presetWidth;
    item.presetHeight = layer.presetHeight;
    
    item.textContent = layer.concatenatedStrings;
    item.previewImagePath = layer.previewImagePath;

    return item;
}

- (NSImage *)previewImage {
    if(!_previewImage) {
        _previewImage = [[NSImage alloc] initWithContentsOfFile:self.previewImagePath];
        _previewImage = [_previewImage scaleToSize:NSMakeSize(480, 480)];
    }
    
    return _previewImage;
}

@end


@interface AssetGroup ()

@property (strong) RLMResults   *assets;

@end


@implementation AssetGroup

@synthesize assets = _assets, filters = _filters;

+ (NSString *)primaryKey {
    return @"objectId";
}

+ (NSArray *)ignoredProperties {
    return @[@"assets", @"filters"];
}

+ (AssetGroup *)groupWithSketchPage:(SketchPage *)page {
    AssetGroup *assetGroup = [[AssetGroup alloc] init];
    
    assetGroup.objectId = page.objectId;
    
    assetGroup.fileId = page.file.objectId;
    assetGroup.pageId = page.objectId;
    assetGroup.pageName = page.name;
    
    assetGroup.title = page.file.name;
    assetGroup.subtitle = page.name;
    
    return assetGroup;
}

- (void)setAssets:(RLMResults *)assets {
    _assets = assets;
}

- (RLMResults *)assets {
    if(!_assets) {
        _assets = [Asset objectsInRealm:self.realm where:@"pageId == %@", self.objectId];
    }
    
    return _assets;
}

- (void)setFilters:(NSArray *)filters {
    _filters = filters;
    
    _assets = [Asset objectsInRealm:self.realm where:@"pageId == %@", self.objectId];
    
    for (AssetFilter *filter in _filters) {
        _assets = [filter applyFilter:_assets];
    }
}

- (NSArray *)filters {
    return _filters;
}

- (NSInteger)numberOfAssets {
    return self.assets.count;
}

- (Asset *)assetAtIndex:(NSInteger)index {
    return [self.assets objectAtIndex:index];
}

@end


@implementation AssetFilter

- (RLMResults *)applyFilter:(RLMResults *)results {
    return results;
}

@end


@implementation TextAssetFilter

- (RLMResults *)applyFilter:(RLMResults *)results {
    if(!self.text || self.text.length == 0) {
        return [super applyFilter:results];
    }
    
    return [results objectsWhere:@"textContent CONTAINS %@", self.text];
}

@end


@interface AssetCollection ()

@property (strong) RLMRealmConfiguration    *realmConfiguration;
@property (strong) RLMResults               *assetGroups;

@end


@implementation AssetCollection

- (instancetype)initWithRealm:(RLMRealm *)realm {
    self = [super init];
    
    _realm = realm;
    _assetGroups = [AssetGroup allObjectsInRealm:_realm];
    
    return self;
}

- (void)applyFilters:(NSArray *)filters {
    for (AssetGroup *group in self.assetGroups) {
        group.filters = filters;
    }
}

- (NSInteger)numberOfGroups {
    return self.assetGroups.count;
}

- (AssetGroup *)groupAtIndex:(NSInteger)groupIndex {
    return [self.assetGroups objectAtIndex:groupIndex];
}

- (NSInteger)numberOfAssetsInGroupAtIndex:(NSInteger)groupIndex {
    return [self groupAtIndex:groupIndex].numberOfAssets;
}

- (id <Asset>)assetAtIndexPath:(NSIndexPath *)indexPath {
    return [[self groupAtIndex:indexPath.section] assetAtIndex:indexPath.item];
}

@end
