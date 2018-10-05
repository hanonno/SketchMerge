//
//  SketchArtboardCollectionViewController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 25/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchPageCollectionViewController.h"


@implementation SketchArtboardCollectionViewItem

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 320, 320)];
    self.view.wantsLayer = YES;
    
    self.artboardImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 320, 320)];
    self.artboardImageView.wantsLayer = YES;
    self.artboardImageView.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:1.0 alpha:0.1] CGColor];
    //    self.artboardImageView.layer.backgroundColor = [[NSColor redColor] CGColor];
    self.artboardImageView.layer.cornerRadius = 4;
    self.artboardImageView.layer.borderWidth = 2;
    
    [self.view addSubview:self.artboardImageView];
    
    //    self.statusView = [[SketchOperationTypeIndicator alloc] init];
    //    [self.view addSubview:self.statusView];
    
    self.presetIconView = [[NSImageView alloc] init];
    [self.view addSubview:self.presetIconView];
    
    self.titleLabel = [NSTextField labelWithString:@"Test"];
//    self.titleLabel.alignment = NSTextAlignmentL;
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
    
    //    [self.statusView autoSetDimensionsToSize:CGSizeMake(12, 12)];
    //    [self.statusView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    //    [self.statusView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
    
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


@implementation SketchPageHeaderView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
    self.wantsLayer = YES;
    self.layer.backgroundColor = [[NSColor headerBackgroundColor] CGColor];
    
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
//    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    //    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    
    [self.subtitleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.titleLabel];
    [self.subtitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.titleLabel withOffset:4];
    [self.subtitleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    
    [divider autoSetDimension:ALDimensionHeight toSize:1];
    [divider autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsZero excludingEdge:ALEdgeTop];
    
    return self;
}

@end


@interface SketchPageCollectionViewController ()

@property (strong) NSProgressIndicator  *progressIndicator;
@property (strong) SketchPageCollection *sketchPageCollection;

// Controls
@property (strong) KeywordFilter        *keywordFilter;
@property (strong) SizeFilter           *sizeFilter;

@end


@implementation SketchPageCollectionViewController

- (id)initWithPageCollection:(SketchPageCollection *)pageCollection {
    self = [super init];
    
    self.keywordFilter = [[KeywordFilter alloc] init];
    self.sizeFilter = [[SizeFilter alloc] init];

    self.sketchPageCollection = pageCollection;
//    self.sketchPageCollection.filters =
    
    [self.sketchPageCollection addFilter:self.keywordFilter];
    [self.sketchPageCollection addFilter:self.sizeFilter];
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 640, 640)];
    
    BOOL hidden = YES;
    
    self.tokenField = [[NSTokenField alloc] initWithFrame:NSMakeRect(0, 0, 240, 52)];
    self.tokenField.tokenStyle = NSTokenStyleSquared;
    //    self.tokenField.tokenStyle = NSTokenStylePlainSquared;
    self.tokenField.bezelStyle = NSTextFieldRoundedBezel;
    self.tokenField.delegate = self;
    self.tokenField.hidden = hidden;
    [self.view addSubview:self.tokenField];
    
    self.presetNameFilterButton = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 120, 44) pullsDown:NO];
    self.presetNameFilterButton.hidden = hidden;
    [self.presetNameFilterButton addItemWithTitle:@"Any device"];
    [self.presetNameFilterButton addItemWithTitle:@"iPhone"];
    [self.presetNameFilterButton addItemWithTitle:@"iPhone SE"];
    [self.presetNameFilterButton addItemWithTitle:@"iPhone 8"];
    [self.presetNameFilterButton addItemWithTitle:@"iPhone Xs"];
    [self.presetNameFilterButton addItemWithTitle:@"iPhone Xs Max"];
    //    [self.presetNameFilterButton menu] addItem: [NSMenuItem separatorItem]];
    [self.presetNameFilterButton addItemWithTitle:@"Apple Watch"];
    [self.presetNameFilterButton addItemWithTitle:@"Apple Watch 38mm"];
    [self.presetNameFilterButton addItemWithTitle:@"Apple Watch 40mm"];
    [self.presetNameFilterButton addItemWithTitle:@"Apple Watch 42mm"];
    [self.presetNameFilterButton addItemWithTitle:@"Apple Watch 44mm"];
    [self.presetNameFilterButton setTarget:self];
    [self.presetNameFilterButton setAction:@selector(presetNameFilterDidChange:)];
    [self.view addSubview:self.presetNameFilterButton];
    
    self.previewSizeSlider = [NSSlider sliderWithValue:360 minValue:240 maxValue:480 target:self action:@selector(previewSizeDidChange:)];
    self.previewSizeSlider.numberOfTickMarks = 11;
    self.previewSizeSlider.allowsTickMarkValuesOnly = YES;
    self.previewSizeSlider.hidden = hidden;
    [self.view addSubview:self.previewSizeSlider];
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:self.view.bounds];
    //    self.scrollView.backgroundColor = [NSColor redColor];
    [self.view addSubview:self.scrollView];
    
    self.layout = [[CollectionViewLeftAlignedLayout alloc] init];
    //    self.layout = [[NSCollectionViewFlowLayout alloc] init];
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
    [self.collectionView registerClass:[SketchArtboardCollectionViewItem class] forItemWithIdentifier:@"SketchArtboardCollectionViewItemIdentifier"];
    [self.collectionView registerClass:[SketchPageHeaderView class] forSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"SketchPageHeaderViewIdentifier"];
    self.scrollView.documentView = self.collectionView;

    self.progressIndicator = [[NSProgressIndicator alloc] init];
    self.progressIndicator.style = NSProgressIndicatorSpinningStyle;
    self.progressIndicator.displayedWhenStopped = NO;
    self.progressIndicator.usesThreadedAnimation = YES;
    [self.progressIndicator sizeToFit];
    [self.view addSubview:self.progressIndicator];
    
    // Auto Layout
    [self.tokenField autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    [self.tokenField autoSetDimension:ALDimensionWidth toSize:320];
    [self.tokenField autoSetDimension:ALDimensionHeight toSize:26];
    [self.tokenField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:16];
    
    [self.presetNameFilterButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.tokenField];
    [self.presetNameFilterButton autoSetDimension:ALDimensionWidth toSize:160];
    [self.presetNameFilterButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.self.tokenField withOffset:16];
    
    [self.previewSizeSlider autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.tokenField];
    [self.previewSizeSlider autoSetDimension:ALDimensionWidth toSize:240];
    [self.previewSizeSlider autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    
    [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(hidden ? 0 : 52, 0, 0, 0)];
}

- (void)startLoading {
    [self.collectionView reloadData];
    
    [self.progressIndicator setFrameOrigin:NSMakePoint(
        (NSWidth([self.progressIndicator.superview bounds]) - NSWidth([self.progressIndicator frame])) / 2,
        (NSHeight([self.progressIndicator.superview bounds]) - NSHeight([self.progressIndicator frame])) / 2
    )];
    
    [self.progressIndicator startAnimation:self];
}

- (void)finishLoading {
    [self.progressIndicator stopAnimation:self];
}

- (void)reloadData {
    [self.sketchPageCollection reloadData];
    [self.collectionView reloadData];
}

#pragma mark Collection View

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return self.sketchPageCollection.numberOfPages;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.sketchPageCollection numberOfLayersInPageAtIndex:section];
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    SketchArtboardCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"SketchArtboardCollectionViewItemIdentifier" forIndexPath:indexPath];
    SketchLayer *layer = [self.sketchPageCollection layerAtIndexPath:indexPath];
    
    item.artboardImageView.image = layer.previewImage;
    item.presetIconView.image = layer.presetIcon;
    item.titleLabel.stringValue = [NSString stringWithFormat:@"%@", layer.name];
    
    return item;
}

- (NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath {
    SketchPageHeaderView *headerView = [collectionView makeSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"SketchPageHeaderViewIdentifier" forIndexPath:indexPath];
    SketchPage *page = [self.sketchPageCollection pageAtIndex:indexPath.section];
    
    headerView.titleLabel.stringValue = page.file.fileName;
    headerView.subtitleLabel.stringValue = [NSString stringWithFormat:@"— %@", page.name];
    
    return headerView;
}

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if([self.sketchPageCollection numberOfLayersInPageAtIndex:section] == 0) {
        return NSZeroSize;
    }
    
    return NSMakeSize(320, 44);
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView heightForHeaderInSection:(NSInteger)index {
    return 80;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
}

#pragma mark Filtering

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTokenField *tokenField = (NSTokenField *)[notification object];
    NSString *filterString = tokenField.stringValue;
    NSLog(@"Keyword: %@", filterString);
    
    if(filterString.length == 0) {
        self.keywordFilter.keywords = nil;
    }
    else {
        self.keywordFilter.keywords = filterString;
    }
    
    [self reloadData];
}

- (nullable NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(nullable NSInteger *)selectedIndex {
    return @[substring, @"iPhone", @"iPad", @"Apple Watch"];
}

- (BOOL)tokenField:(NSTokenField *)tokenField hasMenuForRepresentedObject:(id)representedObject {
    return YES;
}

- (NSMenu *)tokenField:(NSTokenField *)tokenField menuForRepresentedObject:(id)representedObject {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Autocomplete"];
    
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Add" action:nil keyEquivalent:@"a"]];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Remove" action:nil keyEquivalent:@"a"]];
    
    return menu;
}

- (IBAction)presetNameFilterDidChange:(id)sender {
    NSLog(@"Preset: %@", self.presetNameFilterButton.titleOfSelectedItem);
    
    self.sizeFilter.presetName = self.presetNameFilterButton.titleOfSelectedItem;
    [self reloadData];
}

- (IBAction)previewSizeDidChange:(id)sender {
    //    NSLog(@"Size: %f", self.previewSizeSlider.floatValue);
    
    self.layout.itemSize = NSMakeSize(self.previewSizeSlider.floatValue, self.previewSizeSlider.floatValue);
}

@end
