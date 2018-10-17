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


@interface BrowserHeaderController : NSViewController <AssetCollectionDelegate, NSTextFieldDelegate>

@property (strong) NSTextField      *titleLabel;
@property (strong) FilterField      *filterField;
@property (strong) NSStackView      *filterStackView;
@property (strong) NSSlider         *slider;
@property (strong) View             *divider;

@property (strong) AssetCollection  *assetCollection;

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection;

@end
