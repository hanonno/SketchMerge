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
    
    if([self.presetName isEqualToString:@"Any device"]) {
        return YES;
    }
    
    if(self.presetName == nil || self.presetName.length == 0) {
        return YES;
    }
    
    if([asset.presetName hasPrefix:self.presetName]) {
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
