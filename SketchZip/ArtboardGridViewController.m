//
//  ArtboardGridViewController.m
//  SketchZip
//
//  Created by Hanno on 06/07/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "ArtboardGridViewController.h"
#import "CoreSyncTransaction.h"
#import "SketchDiffTool.h"

#import "SketchFileController.h"
#import "SketchFileManager.h"

#import "CollectionViewLeftAlignedLayout.h"

#import <PureLayout/PureLayout.h>


@implementation ArtboardCollectionViewItem

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 320, 320)];
    self.view.wantsLayer = YES;
    
    self.artboardImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 320, 320)];
    self.artboardImageView.wantsLayer = YES;
    self.artboardImageView.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:0.96 alpha:1.0] CGColor];
//    self.artboardImageView.layer.backgroundColor = [[NSColor redColor] CGColor];
    self.artboardImageView.layer.cornerRadius = 4;
    self.artboardImageView.layer.borderWidth = 2;
    
    [self.view addSubview:self.artboardImageView];
    
//    self.statusView = [[SketchOperationTypeIndicator alloc] init];
//    [self.view addSubview:self.statusView];
    
    self.presetIconView = [[NSImageView alloc] init];
    [self.view addSubview:self.presetIconView];
    
    self.titleLabel = [NSTextField labelWithString:@"Test"];
    self.titleLabel.alignment = NSTextAlignmentCenter;
    self.titleLabel.font = [NSFont systemFontOfSize:12];
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
    
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.presetIconView withOffset:2];
    [self.titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.presetIconView withOffset:2];
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
        self.artboardImageView.layer.borderColor =[[NSColor colorWithCalibratedRed:0.149 green:0.434 blue:0.964 alpha:1.000] CGColor];
    }
    else {
        self.artboardImageView.layer.borderColor = [[NSColor whiteColor] CGColor];
    }
}

@end


@implementation PageHeaderView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
    self.wantsLayer = YES;
    self.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    
    NSView *divider = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 120, 1)];
    divider.wantsLayer = YES;
    divider.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:0.917 alpha:1.000] CGColor];
    [self addSubview:divider];

    self.titleLabel = [NSTextField labelWithString:@"File Name"];
    self.titleLabel.font = [NSFont systemFontOfSize:12];
    self.titleLabel.textColor = [NSColor colorWithCalibratedWhite:0.12 alpha:1.000];
    [self.titleLabel setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self addSubview:self.titleLabel];
    
    self.subtitleLabel = [NSTextField labelWithString:@"Page Name"];
    self.subtitleLabel.font = [NSFont systemFontOfSize:12];
    self.subtitleLabel.textColor = [NSColor colorWithCalibratedWhite:0.50 alpha:1.000];
    [self addSubview:self.subtitleLabel];
    
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
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


@interface ArtboardGridViewController () <NSTokenFieldDelegate, SketchFileManagerDelegate>

@property (strong) SketchDiffTool       *sketchDiffTool;
@property (strong) NSProgressIndicator  *progressIndicator;
@property (strong) SketchFileController *sketchFileController;
@property (strong) SketchFileManager    *sketchFileManager;

// Controls
@property (strong) KeywordFilter        *keywordFilter;
@property (strong) SizeFilter           *sizeFilter;

@end


@implementation ArtboardGridViewController

- (id)init {
    self = [super init];
    
    self.mergeTool = nil;
    self.sketchDiffTool = [[SketchDiffTool alloc] init];
    self.keywordFilter = [[KeywordFilter alloc] init];
    self.sizeFilter = [[SizeFilter alloc] init];
    self.sketchFileController = [[SketchFileController alloc] init];
    self.sketchFileController.filters = @[self.keywordFilter, self.sizeFilter];
    self.sketchFileManager = [[SketchFileManager alloc] init];
    self.sketchFileManager.delegate = self;
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 640, 640)];
    
    self.tokenField = [[NSTokenField alloc] initWithFrame:NSMakeRect(0, 0, 240, 52)];
    self.tokenField.tokenStyle = NSTokenStyleSquared;
//    self.tokenField.tokenStyle = NSTokenStylePlainSquared;
    self.tokenField.bezelStyle = NSTextFieldRoundedBezel;
    self.tokenField.delegate = self;
    [self.view addSubview:self.tokenField];
    
    self.presetNameFilterButton = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 120, 44) pullsDown:NO];
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
    [self.view addSubview:self.previewSizeSlider];
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(300, 0, 640, 640)];
    self.scrollView.backgroundColor = [NSColor redColor];
    [self.view addSubview:self.scrollView];
    
    self.layout = [[CollectionViewLeftAlignedLayout alloc] init];
    self.layout.itemSize = NSMakeSize(240, 240);
    self.layout.minimumLineSpacing = 16;
    self.layout.minimumInteritemSpacing = 16;
    self.layout.headerReferenceSize = NSMakeSize(320, 44);
    self.layout.sectionInset = NSEdgeInsetsMake(16, 16, 16, 16);
    self.layout.sectionHeadersPinToVisibleBounds = YES;
    
    self.collectionView = [[NSCollectionView alloc] initWithFrame:self.view.bounds];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.collectionViewLayout = self.layout;
    self.collectionView.selectable = YES;
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[ArtboardCollectionViewItem class] forItemWithIdentifier:@"ArtboardCollectionViewItemIdentifier"];
    [self.collectionView registerClass:[PageHeaderView class] forSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"PageHeaderViewIdentifier"];
    self.scrollView.documentView = self.collectionView;
    
    self.progressIndicator = [[NSProgressIndicator alloc] init];
    self.progressIndicator.style = NSProgressIndicatorSpinningStyle;
    self.progressIndicator.displayedWhenStopped = NO;
    self.progressIndicator.usesThreadedAnimation = YES;
    [self.progressIndicator sizeToFit];
    [self.view addSubview:self.progressIndicator];
    
    [self.collectionView reloadData];
    
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
    
    [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(52, 0, 0, 0)];
}

- (void)startLoading {
    self.mergeTool = nil;
    [self.collectionView reloadData];
    [self.sketchFileManager startIndexing];
    
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
    [self.sketchFileController reloadData];
    [self.collectionView reloadData];
    
    NSLog(@"%lu pages > %i filtered", (unsigned long)self.sketchFileController.pageItems.count, self.sketchFileController.filteredPageItems.count);
}

- (void)sketchFileManager:(SketchFileManager *)fileManager didIndexFile:(SketchFile *)file {
    [self.sketchFileController addPagesFromFile:file];
    [self.collectionView reloadData];
}

#pragma mark Collection View

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return self.sketchFileController.numberOfPages;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.sketchFileController numberOfLayersInPageAtIndex:section];
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    ArtboardCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"ArtboardCollectionViewItemIdentifier" forIndexPath:indexPath];
    SketchLayer *layer = [self.sketchFileController layerAtIndexPath:indexPath];
    
    item.artboardImageView.image = layer.previewImage;
    item.presetIconView.image = layer.presetIcon;
    item.titleLabel.stringValue = [NSString stringWithFormat:@"%@", layer.name];

    return item;
}

- (NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath {
    PageHeaderView *headerView = [collectionView makeSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"PageHeaderViewIdentifier" forIndexPath:indexPath];
    SketchPage *page = [self.sketchFileController pageAtIndex:indexPath.section];
    
    headerView.titleLabel.stringValue = page.sketchFile.fileName;
    headerView.subtitleLabel.stringValue = [NSString stringWithFormat:@"— %@", page.name];
    
    return headerView;
}

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if([self.sketchFileController numberOfLayersInPageAtIndex:section] == 0) {
        return NSZeroSize;
    }
    
    return NSMakeSize(320, 44);
}


- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
}

#pragma mark Filtering

- (void)controlTextDidChange:(NSNotification *)notification {
    NSLog(@"Keyword: %@", self.tokenField.stringValue);
    
    if(self.tokenField.stringValue.length == 0) {
        self.keywordFilter.keywords = nil;
    }
    else {
        self.keywordFilter.keywords = self.tokenField.stringValue;
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
    NSLog(@"Size: %f", self.previewSizeSlider.floatValue);
    
    self.layout.itemSize = NSMakeSize(self.previewSizeSlider.floatValue, self.previewSizeSlider.floatValue);
}

@end
