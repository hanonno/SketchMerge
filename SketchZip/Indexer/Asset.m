//
//  SketchItem.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "Asset.h"
#import "NSImage+PNGAdditions.h"

#import "Filter.h"
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
        NSLog(@"Reload preview image");
        _previewImage = [[NSImage alloc] initWithContentsOfFile:self.previewImagePath];
        _previewImage = [_previewImage scaleToSize:NSMakeSize(480, 480)];
    }
    
    return _previewImage;
}

@end


@implementation AssetGroup

- (instancetype)init {
    self = [super init];
    
    _title = @"Title";
    _subtitle = @"Subtitle";
    _assets = [[NSMutableArray alloc] init];
    
    return self;
}

@end



@interface AssetCollection ()

@property (strong) RLMResults       *assets;
@property (strong) NSArray          *groups;
@property (strong) NSMutableArray   *filters;

@end


@implementation AssetCollection

- (instancetype)initWithRealm:(RLMRealm *)realm {
    self = [super init];
    
    _realm = realm;
    _assets = [Asset allObjectsInRealm:_realm];
    _filters = [[NSMutableArray alloc] init];
    
    [self reloadData];
    
    return self;
}

- (void)reloadData {
    NSMutableDictionary *groupsById = [[NSMutableDictionary alloc] init];
    NSInteger count = 0;
    
    for (Asset *asset in self.assets) {
        BOOL exit = NO;
        
        for (Filter *filter in self.filters) {
            if(![filter matchAsset:asset]) {
                exit = YES;
            }
        }
        
        if(exit) {
            continue;
        }
        
        count++;
        
        NSString *groupKey = asset.pageId;
        AssetGroup *group = groupsById[groupKey];
        
        if(!group) {
            group = [[AssetGroup alloc] init];
            group.title = [asset.filePath.lastPathComponent stringByDeletingPathExtension];
            group.subtitle = asset.pageName;
            [groupsById setObject:group forKey:groupKey];
        }
        
        [group.assets addObject:asset];
    }
    
//    NSLog(@"%i Assets of %i", count, self.assets.count);
    
    self.groups = groupsById.allValues;
}

- (void)addFilter:(Filter *)filter {
    [self.filters addObject:filter];
    [self reloadData];
}

- (void)removeFilter:(Filter *)filter {
    [self.filters removeObject:filter];
    [self reloadData];
}

- (void)replaceFilter:(Filter *)filter {
    NSMutableArray *removeFilters = [[NSMutableArray alloc] init];
    
    for (Filter *activeFilter in self.filters) {
        if([activeFilter isKindOfClass:[filter class]]) {
            [removeFilters addObject:activeFilter];
            NSLog(@"Filter remove");
        }
    }
    
    [self.filters removeObjectsInArray:removeFilters];
    [self.filters addObject:filter];
    [self reloadData];
}

- (NSInteger)numberOfGroups {
    return self.groups.count;
}

- (AssetGroup *)groupAtIndex:(NSInteger)groupIndex {
    return [self.groups objectAtIndex:groupIndex];
}

- (Asset *)assetAtIndexPath:(NSIndexPath *)indexPath {
    return [[self groupAtIndex:indexPath.section].assets objectAtIndex:indexPath.item];
}

@end
