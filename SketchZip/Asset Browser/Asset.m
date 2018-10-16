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
    [item takeValuesFromLayer:layer];
    
    return item;
}

- (void)takeValuesFromLayer:(SketchLayer *)layer {
    [self.realm beginWriteTransaction];
    self.objectClass = layer.objectClass;
    self.name = layer.name;
    
    self.fileId = layer.page.file.objectId;
    self.filePath = layer.page.file.fileURL.path;
    
    self.pageId = layer.page.objectId;
    self.pageName = layer.page.name;
    
    self.x = layer.x;
    self.y = layer.y;
    self.width = layer.width;
    self.height = layer.height;
    
    self.presetName = layer.presetName;
    self.presetWidth = layer.presetWidth;
    self.presetHeight = layer.presetHeight;
    
    self.textContent = layer.concatenatedStrings;
    self.previewImagePath = layer.previewImagePath;
    [self.realm commitWriteTransaction];
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
@property (strong) NSHashTable      *delegates;

@end


@implementation AssetCollection

- (instancetype)initWithRealm:(RLMRealm *)realm {
    self = [super init];
    
    _realm = realm;
    _assets = [Asset allObjectsInRealm:_realm];
    _filters = [[NSMutableArray alloc] init];
    _delegates = [NSHashTable weakObjectsHashTable];
    
    [self reloadData];
    
    return self;
}

- (void)reloadData {
    NSMutableDictionary *groupsById = [[NSMutableDictionary alloc] init];
    NSInteger count = 0;
    
    for (Asset *asset in self.assets) {
        BOOL exit = NO;
        
        for (Filter *filter in self.filters) {
            if(filter.enabled == NO) {
                continue;
            }
            
            if(![filter matchAsset:asset]) {
                exit = YES;
            }
        }
        
        if(exit) {
            continue;
        }
        
        count++;
        
        // This can be made more flexible in the future by adding different keys
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
    
    self.groups = groupsById.allValues;
   
    // Inform all delegates
    for (id <AssetCollectionDelegate> delegate in self.delegates) {
        if([delegate respondsToSelector:@selector(assetCollectionDidUpdate:)]) {
            [delegate assetCollectionDidUpdate:self];
        }
    }
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
    
    for (id <AssetCollectionDelegate>delegate in self.delegates) {
        if([delegate respondsToSelector:@selector(assetCollectionDidUpdate:filter:)]) {
            [delegate assetCollectionDidUpdate:self filter:filter];
        }
    }
}

- (NSInteger)numberOfFilers {
    return self.filters.count;
}

- (Filter *)filterAtIndex:(NSInteger)index {
    return [self.filters objectAtIndex:index];
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

- (void)addDelegate:(id <AssetCollectionDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id <AssetCollectionDelegate>)delegate {
    [self.delegates removeObject:delegate];
}

@end
