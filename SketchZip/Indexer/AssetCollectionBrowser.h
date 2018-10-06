//
//  SketchItemBrowserController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PureLayout/PureLayout.h>
#import <SDWebImage/SDWebImage.h>


#import "Asset.h"


@interface ItemBrowserItem : NSCollectionViewItem

@property (strong) NSTextField                      *titleLabel;
@property (strong) NSView                           *previewBackground;
@property (strong) NSImageView                      *artboardImageView;
@property (strong) NSImageView                      *presetIconView;

- (void)setImageSize:(NSSize)imageSize;

@end


@interface ItemBrowserHeader : NSView

@property (strong) NSTextField  *titleLabel;
@property (strong) NSTextField  *subtitleLabel;

@end


@interface AssetCollectionBrowser : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>

@property (strong) NSScrollView                 *scrollView;
@property (strong) NSCollectionView             *collectionView;
@property (strong) NSCollectionViewFlowLayout   *layout;

@property (strong) AssetCollection              *assetCollection;

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection;

@end
