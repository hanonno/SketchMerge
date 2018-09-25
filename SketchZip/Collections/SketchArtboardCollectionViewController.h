//
//  SketchArtboardCollectionViewController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 25/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SketchFileIndexer.h"


@interface SketchArtboardCollectionViewItem : NSCollectionViewItem

@property (strong) NSTextField                      *titleLabel;
@property (strong) NSImageView                      *artboardImageView;
@property (strong) NSImageView                      *presetIconView;

@end


@interface SketchPageHeaderView : NSView

@property (strong) NSTextField  *titleLabel;
@property (strong) NSTextField  *subtitleLabel;

@end


@interface SketchArtboardCollectionViewController : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate, SketchFileIndexerDelegate>

@property (strong) NSTokenField                 *tokenField;
@property (strong) NSPopUpButton                *presetNameFilterButton;
@property (strong) NSSlider                     *previewSizeSlider;

@property (strong) NSScrollView                 *scrollView;
@property (strong) NSCollectionView             *collectionView;
@property (strong) NSCollectionViewFlowLayout   *layout;

- (void)startLoading;
- (void)finishLoading;

- (void)reloadData;

@end
