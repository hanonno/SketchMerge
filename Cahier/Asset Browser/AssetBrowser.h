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
#import "Filter.h"
#import "GalleryLayout.h"


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


@interface AssetCollectionView : NSCollectionView
@end


@interface AssetBrowser : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate, AssetCollectionDelegate>

@property (strong) NSScrollView                 *scrollView;
@property (strong) NSCollectionView             *collectionView;
@property (strong) NSCollectionViewFlowLayout   *layout;
@property (strong) GalleryLayout                *galleryLayout;

@property (assign) CGFloat                      zoomFactor;
@property (assign) CGSize                       previewImageSize;

@property (strong) AssetCollection              *assetCollection;

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection;

- (IBAction)addToFavorites:(id)sender;
- (void)assetBrowserItemDoubleClick:(id)sender;

@end
