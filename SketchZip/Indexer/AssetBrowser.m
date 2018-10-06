//
//  SketchItemBrowserController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "AssetBrowser.h"

#import "TDTheme.h"
#import "CollectionViewLeftAlignedLayout.h"


@implementation ItemBrowserItem

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 320, 320)];
    self.view.wantsLayer = YES;
    
    self.artboardImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 320, 320)];
    self.artboardImageView.wantsLayer = YES;
    self.artboardImageView.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:1.0 alpha:0.1] CGColor];
    self.artboardImageView.layer.cornerRadius = 4;
    self.artboardImageView.layer.borderWidth = 2;
    
    [self.view addSubview:self.artboardImageView];
    
    self.presetIconView = [[NSImageView alloc] init];
    [self.view addSubview:self.presetIconView];
    
    self.titleLabel = [NSTextField labelWithString:@"Test"];
    self.titleLabel.font = [NSFont systemFontOfSize:12];
    self.titleLabel.textColor = [NSColor colorWithCalibratedWhite:0.50 alpha:1.000];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.view addSubview:self.titleLabel];
    
    // Auto Layout
    [self.artboardImageView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [self.artboardImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.titleLabel withOffset:-8];
    
    [self.presetIconView autoSetDimensionsToSize:CGSizeMake(20, 20)];
    [self.presetIconView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:4];
    [self.presetIconView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    [self.titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.presetIconView withOffset:2];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.presetIconView withOffset:6];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:4];
    [self.titleLabel autoSetDimension:ALDimensionHeight toSize:22];
    
    self.selected = NO;
}

- (void)setHighlightState:(NSCollectionViewItemHighlightState)highlightState {
    [super setHighlightState:highlightState];
    
    if(highlightState == NSCollectionViewItemHighlightForSelection) {
        [self setSelected:YES];
    }
    
    if(highlightState == NSCollectionViewItemHighlightForDeselection) {
        [self setSelected:NO];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected) {
        self.artboardImageView.layer.borderColor =[[NSColor highlightColor] CGColor];
    }
    else {
        self.artboardImageView.layer.borderColor = [[NSColor clearColor] CGColor];
    }
}

@end


@implementation ItemBrowserHeader

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
    self.wantsLayer = YES;
    self.layer.backgroundColor = [[NSColor backgroundColor] CGColor];
    
    NSView *divider = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 120, 1)];
    divider.wantsLayer = YES;
    divider.layer.backgroundColor = [[NSColor dividerColor] CGColor];
    [self addSubview:divider];
    
    self.titleLabel = [NSTextField labelWithString:@"File Name"];
    self.titleLabel.font = [NSFont systemFontOfSize:14];
    self.titleLabel.textColor = [NSColor titleTextColor];
    [self.titleLabel setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self addSubview:self.titleLabel];
    
    self.subtitleLabel = [NSTextField labelWithString:@"Page Name"];
    self.subtitleLabel.font = [NSFont systemFontOfSize:14];
    self.subtitleLabel.textColor = [NSColor subtitleTextColor];
    [self addSubview:self.subtitleLabel];
    
    // Autolayout
    [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    
    [self.subtitleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.titleLabel];
    [self.subtitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.titleLabel withOffset:4];
    [self.subtitleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    
    [divider autoSetDimension:ALDimensionHeight toSize:1];
    [divider autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsZero excludingEdge:ALEdgeTop];
    
    return self;
}

@end


@implementation AssetBrowser

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection {
    self = [super init];
    
    _assetCollection = assetCollection;
    _imageCache = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 320, 480)];

    self.scrollView = [[NSScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    self.layout = [[CollectionViewLeftAlignedLayout alloc] init];
    self.layout.itemSize = NSMakeSize(240, 240);
    self.layout.minimumLineSpacing = 16;
    self.layout.minimumInteritemSpacing = 16;
    self.layout.headerReferenceSize = NSMakeSize(320, 44);
    self.layout.sectionInset = NSEdgeInsetsMake(16, 16, 16, 16);
    self.layout.sectionHeadersPinToVisibleBounds = YES;
    
    //    self.layout.itemSize = NSMakeSize(240, 240);
    //    self.layout.minimumLineSpacing = 16;
    //    self.layout.minimumInteritemSpacing = 16;
    //    self.layout.headerReferenceSize = NSMakeSize(320, 44);
    //    self.layout.sectionInset = NSEdgeInsetsMake(16, 16, 16, 16);
    //    self.layout.sectionHeadersPinToVisibleBounds = YES;
    
    self.collectionView = [[NSCollectionView alloc] initWithFrame:self.view.bounds];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.collectionViewLayout = self.layout;
    self.collectionView.selectable = YES;
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[ItemBrowserItem class] forItemWithIdentifier:@"SketchArtboardCollectionViewItemIdentifier"];
    [self.collectionView registerClass:[ItemBrowserHeader class] forSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"SketchPageHeaderViewIdentifier"];
    self.scrollView.documentView = self.collectionView;

    [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0)];
}

#pragma mark Collection View

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return self.assetCollection.numberOfGroups;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.assetCollection groupAtIndex:section].assets.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    ItemBrowserItem *item = [collectionView makeItemWithIdentifier:@"SketchArtboardCollectionViewItemIdentifier" forIndexPath:indexPath];
    Asset *asset = [self.assetCollection assetAtIndexPath:indexPath];
    
    NSImage *image = [self.imageCache objectForKey:asset.previewImagePath];
    
    if(!image) {
        image = asset.previewImage;
        [self.imageCache setObject:image forKey:asset.previewImagePath];
    }
    
    item.artboardImageView.image = image;
    item.titleLabel.stringValue = (asset.name) ? asset.name : @"WHat";
    
    return item;
}

- (NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath {
    ItemBrowserHeader *headerView = [collectionView makeSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"SketchPageHeaderViewIdentifier" forIndexPath:indexPath];
    AssetGroup *group = [self.assetCollection groupAtIndex:indexPath.section];
    
    headerView.titleLabel.stringValue = group.title;
    headerView.subtitleLabel.stringValue = [NSString stringWithFormat:@" — %@", group.subtitle];
    
    return headerView;
}

@end