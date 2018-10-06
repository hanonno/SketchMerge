//
//  SketchItem.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchItem.h"
#import "NSImage+PNGAdditions.h"


#import "SketchFile.h"


@implementation SketchItem

@synthesize previewImage = _previewImage;

+ (NSString *)primaryKey {
    return @"objectId";
}

+ (NSArray *)ignoredProperties {
    return @[@"previewImage"];
}

+ (SketchItem *)itemWithSketchLayer:(SketchLayer *)layer {
    SketchItem *item = [[SketchItem alloc] init];
    
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
