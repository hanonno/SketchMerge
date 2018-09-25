//
//  ArtboardGridViewController.h
//  SketchZip
//
//  Created by Hanno on 06/07/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SketchPage.h"
#import "SketchDiffTool.h"
#import "SketchOperationTypeIndicator.h"

#import "TDCollectionViewListLayout.h"


@interface ArtboardCollectionViewItem : NSCollectionViewItem

@property (strong) NSTextField                      *titleLabel;
@property (strong) NSImageView                      *artboardImageView;
@property (strong) SketchOperationTypeIndicator     *statusView;
@property (strong) NSImageView                      *presetIconView;

@end


@interface PageHeaderView : NSView

@property (strong) NSTextField  *titleLabel;
@property (strong) NSTextField  *subtitleLabel;
@property (strong) NSButton     *toggleButton;

@end


@interface ArtboardGridViewController : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>

@property (strong) NSTokenField                 *tokenField;
@property (strong) NSPopUpButton                *presetNameFilterButton;
@property (strong) NSSlider                     *previewSizeSlider;

@property (strong) NSScrollView                 *scrollView;
@property (strong) NSCollectionView             *collectionView;
@property (strong) NSCollectionViewFlowLayout   *layout;

@property (strong) SketchMergeTool              *mergeTool;

- (void)startLoading;
- (void)finishLoading;

- (void)reloadData;

@end
