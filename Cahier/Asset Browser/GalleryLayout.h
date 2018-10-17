//
//  GalleryLayout.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 16/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#import "Asset.h"


@interface GalleryLayoutSection : NSObject

@property (strong) NSString         *name;
@property (strong) NSMutableArray   *assetLayoutAttributes;

@end


@interface GalleryLayout : NSCollectionViewLayout

@property (strong) AssetCollection  *assetCollection;
@property (strong) NSArray          *sections;

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection;

@end
