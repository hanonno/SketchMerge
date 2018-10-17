//
//  CahierHeader.h
//  Cahier
//
//  Created by Hanno ten Hoor on 17/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#import "Theme.h"
#import "Asset.h"


@interface BrowserHeader : View

@property (strong) NSTextField  *titleLabel;
@property (strong) NSStackView  *filterStackView;
@property (strong) View         *divider;

@end


@interface BrowserHeaderController : NSViewController <AssetCollectionDelegate>

@property (strong) BrowserHeader    *browserHeaderView;
@property (strong) AssetCollection  *assetCollection;

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection;

@end
