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


@interface AssetBrowserItem ()

@property NSView                            *containerView;
@property NSLayoutConstraint                *previewWidth;
@property NSLayoutConstraint                *previewHeight;

@property (strong) RLMNotificationToken     *token;

@end


@implementation AssetBrowserItem

@synthesize asset = _asset;

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 320, 320)];
    self.view.wantsLayer = YES;
    
    self.previewImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 320, 320)];
    self.previewImageView.wantsLayer = YES;
    self.previewImageView.layer.cornerRadius = 4;
    self.previewImageView.layer.borderWidth = 2;
    self.previewImageView.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:1.0 alpha:0.02] CGColor];
    [self.view addSubview:self.previewImageView];
    
    self.presetIconView = [[NSImageView alloc] init];
    [self.view addSubview:self.presetIconView];
    
    self.favoriteIconView = [[NSImageView alloc] init];
    [self.view addSubview:self.favoriteIconView];

    self.titleLabel = [NSTextField labelWithString:@"Test"];
    self.titleLabel.font = [NSFont systemFontOfSize:12];
    self.titleLabel.textColor = [NSColor colorWithCalibratedWhite:0.50 alpha:1.000];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.view addSubview:self.titleLabel];
    
    // Auto Layout
    [self.previewImageView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [self.previewImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.titleLabel withOffset:-8];
    
    [self.presetIconView autoSetDimensionsToSize:CGSizeMake(20, 20)];
    [self.presetIconView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:4];
    [self.presetIconView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    [self.favoriteIconView autoSetDimensionsToSize:CGSizeMake(20, 20)];
    [self.favoriteIconView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.favoriteIconView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    [self.titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.presetIconView withOffset:2];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.presetIconView withOffset:6];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:4];
    [self.titleLabel autoSetDimension:ALDimensionHeight toSize:22];
    
    self.selected = NO;
}

- (Asset *)asset {
    return _asset;
}

- (void)setAsset:(Asset *)asset {
    _asset = asset;
    
    __weak typeof(self) weakSelf = self;

    self.token = [_asset addNotificationBlock:^(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes, NSError * _Nullable error) {
        [weakSelf takeValuesFromAsset:weakSelf.asset];
    }];
    
    [self takeValuesFromAsset:_asset];
}

- (void)takeValuesFromAsset:(Asset *)asset {
    [self.previewImageView sd_setImageWithURL:[NSURL fileURLWithPath:asset.previewImagePath] placeholderImage:[NSImage imageNamed:@"PreviewImagePlaceholder.png"] options:SDWebImageCacheMemoryOnly];
    self.titleLabel.stringValue = (asset.name) ? asset.name : @"WHat";
    self.favoriteIconView.image = (asset.favorited) ? [NSImage imageNamed:@"Favorites"] : nil;
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
        self.previewImageView.layer.borderColor =[[NSColor highlightColor] CGColor];
    }
    else {
        self.previewImageView.layer.borderColor = [[NSColor clearColor] CGColor];
    }
}

//- (void)setImageSize:(NSSize)targetSize {
//    NSSize currentSize = self.artboardImageView.frame.size;
//
//    CGFloat widthRatio = currentSize.width / targetSize.width;
//    CGFloat heightRatio = currentSize.height / targetSize.height;
//
//    CGFloat widthConstant = 1;
//    CGFloat heightConstant = 1;
//
//    if(widthRatio < heightRatio) {
//        widthConstant = floorf(targetSize.width * widthRatio);
//        heightConstant = floorf(targetSize.height * widthRatio);
//    }
//    else {
//        widthConstant = floorf(targetSize.width * heightRatio);
//        heightConstant = floorf(targetSize.height * heightRatio);
//    }
//    
//    
//    self.previewWidth.constant = widthConstant;
//    self.previewHeight.constant = heightConstant;
//    
//   NSLog(@"w: %f h: %f", widthConstant, heightConstant);
//    
//    [self.view setNeedsLayout:YES];
//}

@end


@implementation AssetBrowserHeader

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
    [self.collectionView registerClass:[AssetBrowserItem class] forItemWithIdentifier:@"SketchArtboardCollectionViewItemIdentifier"];
    [self.collectionView registerClass:[AssetBrowserHeader class] forSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"SketchPageHeaderViewIdentifier"];
    self.scrollView.documentView = self.collectionView;

    [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0)];
}

- (IBAction)addToFavorites:(id)sender {
    NSSet *selectedIndexPaths = [self.collectionView selectionIndexPaths];
    
    BOOL allFavorited = YES;
    
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        Asset *asset = [self.assetCollection assetAtIndexPath:indexPath];
        
        if(asset.favorited == NO) {
            allFavorited = NO;
        }
        
        [assets addObject:asset];
    }
    
    [self.assetCollection.realm beginWriteTransaction];
    
    for (Asset *asset in assets) {
        asset.favorited = allFavorited ? NO : YES;
    }
    
    if(allFavorited) {
        NSLog(@"Un favorited");
    }
    else {
        NSLog(@"Favorited");
    }
    
    [self.assetCollection.realm commitWriteTransaction];
}

#pragma mark Collection View

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return self.assetCollection.numberOfGroups;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.assetCollection groupAtIndex:section].assets.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    AssetBrowserItem *item = [collectionView makeItemWithIdentifier:@"SketchArtboardCollectionViewItemIdentifier" forIndexPath:indexPath];
    Asset *asset = [self.assetCollection assetAtIndexPath:indexPath];
    
    item.asset = asset;
    //    item.favoriteIconView.image = [NSImage imageNamed:@"Favorites"];
    
    return item;
}

- (NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath {
    AssetBrowserHeader *headerView = [collectionView makeSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"SketchPageHeaderViewIdentifier" forIndexPath:indexPath];
    AssetGroup *group = [self.assetCollection groupAtIndex:indexPath.section];
    
    headerView.titleLabel.stringValue = group.title;
    headerView.subtitleLabel.stringValue = [NSString stringWithFormat:@" — %@", group.subtitle];
    
    return headerView;
}

@end