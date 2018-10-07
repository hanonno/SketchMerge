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


@interface AssetBrowserItem : NSCollectionViewItem

@property (strong) NSTextField  *titleLabel;
@property (strong) NSView       *previewBackground;
@property (strong) NSImageView  *previewImageView;
@property (strong) NSImageView  *presetIconView;
@property (strong) NSImageView  *favoriteIconView;

//- (void)setImageSize:(NSSize)imageSize;
@property (strong) Asset        *asset;

@end


@interface AssetBrowserHeader : NSView

@property (strong) NSTextField  *titleLabel;
@property (strong) NSTextField  *subtitleLabel;

@end


@interface AssetBrowser : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>

@property (strong) NSScrollView                 *scrollView;
@property (strong) NSCollectionView             *collectionView;
@property (strong) NSCollectionViewFlowLayout   *layout;

@property (strong) AssetCollection              *assetCollection;

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection;

- (IBAction)addToFavorites:(id)sender;

@end
