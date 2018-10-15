//
//  Filter.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "Filter.h"


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

- (BOOL)matchAsset:(Asset *)asset {
    if(!self.enabled) {
        return YES;
    }
    
    // Any device will match everything
    if([self.presetName isEqualToString:@"Any device"]) {
        return YES;
    }
    
    // No will match everything
    if(self.presetName == nil || self.presetName.length == 0) {
        return YES;
    }
    
    // Setting width or height to 0 will ignore it
    if(self.width == 0 && asset.height == self.height) {
        return YES;
    }
    
    if(asset.width == self.width && self.height == 0) {
        return YES;
    }
    
    // Else both need to match
    if(asset.width == self.width && asset.height == self.height) {
        return YES;
    }
    
    return NO;
}

+ (SizeFilter *)filterWithName:(NSString *)name width:(CGFloat)width height:(CGFloat)height {
    SizeFilter *filter = [[SizeFilter alloc] init];
    
    filter.presetName = name;
    filter.width = width;
    filter.height = height;
    
    return filter;
}

+ (NSArray *)appleDeviceFilters {
    NSMutableArray *filters = [[NSMutableArray alloc] init];
    
    [filters addObject:[SizeFilter filterWithName:@"Any device" width:400 height:400]];
    [filters addObject:[SizeFilter filterWithName:@"iPhone 8" width:375 height:667]];
    [filters addObject:[SizeFilter filterWithName:@"iPhone 8 Plus" width:414 height:736]];
    [filters addObject:[SizeFilter filterWithName:@"iPhone SE" width:320 height:568]];
    [filters addObject:[SizeFilter filterWithName:@"iPhone XS" width:375 height:812]];
    [filters addObject:[SizeFilter filterWithName:@"iPhone XR" width:414 height:896]];
    [filters addObject:[SizeFilter filterWithName:@"iPhone XS Max" width:414 height:896]];
    [filters addObject:[SizeFilter filterWithName:@"iPad" width:768 height:1024]];
    [filters addObject:[SizeFilter filterWithName:@"iPad Pro" width:1024 height:1366]];
    [filters addObject:[SizeFilter filterWithName:@"Apple Watch 38mm" width:272 height:340]];
    [filters addObject:[SizeFilter filterWithName:@"Apple Watch 40mm" width:326 height:394]];
    [filters addObject:[SizeFilter filterWithName:@"Apple Watch 42mm" width:312 height:390]];
    [filters addObject:[SizeFilter filterWithName:@"Apple Watch 44mm" width:368 height:448]];
    [filters addObject:[SizeFilter filterWithName:@"Apple TV" width:1920 height:1080]];
    [filters addObject:[SizeFilter filterWithName:@"Touch Bar" width:1085 height:30]];
    
    return filters;
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

- (BOOL)matchAsset:(Asset *)asset {
    if(!self.enabled) {
        return YES;
    }
    
    if(!self.path) {
        return YES;
    }
    
    if([asset.filePath hasPrefix:self.path]) {
        return YES;
    }
    
    return NO;
}

@end


@implementation FavoriteFilter

- (BOOL)matchAsset:(Asset *)asset {
    if(asset.favorited == YES) {
        return YES;
    }
    
    return NO;
}

@end
