//
//  Filter.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "Asset.h"
#import "SketchFile.h"


@interface Filter : NSObject

@property (readonly) NSString   *title;
@property (assign) BOOL         enabled;

- (BOOL)matchLayer:(SketchLayer *)layer;
- (BOOL)matchAsset:(Asset *)asset;

@end


@interface KeywordFilter : Filter

@property (strong) NSString *keywords;
@property (assign) BOOL     isCaseSensitive;

@end


@interface SizeFilter : Filter

@property (strong) NSString *presetName;
@property (assign) CGFloat  width;
@property (assign) CGFloat  height;

+ (SizeFilter *)filterWithName:(NSString *)name width:(CGFloat)width height:(CGFloat)height;
+ (NSArray *)appleDeviceFilters;

@end


@interface PathFilter : Filter

@property (strong) NSString *path;

@end


@interface FavoriteFilter : Filter
@end
