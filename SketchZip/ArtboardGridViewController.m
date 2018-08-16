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
#import <PureLayout/PureLayout.h>


@implementation ArtboardCollectionViewItem

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 320, 320)];
    self.view.wantsLayer = YES;
    
    self.artboardImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 320, 320)];
    self.artboardImageView.wantsLayer = YES;
    self.artboardImageView.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] CGColor];
    self.artboardImageView.layer.cornerRadius = 4;
    self.artboardImageView.layer.borderWidth = 2;
    [self.view addSubview:self.artboardImageView];
    
    self.statusView = [[SketchOperationTypeIndicator alloc] init];
    [self.view addSubview:self.statusView];
    
    self.titleLabel = [NSTextField labelWithString:@"Test"];
    self.titleLabel.alignment = NSTextAlignmentCenter;
    self.titleLabel.font = [NSFont systemFontOfSize:12];
    [self.view addSubview:self.titleLabel];
    
    // Auto Layout
    [self.artboardImageView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [self.artboardImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.titleLabel withOffset:-4];
    
    [self.statusView autoSetDimensionsToSize:CGSizeMake(12, 12)];
    [self.statusView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.statusView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
    
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.statusView withOffset:4];
    [self.titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.statusView];
    [self.titleLabel autoSetDimension:ALDimensionHeight toSize:22];
    
    self.selected = NO;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected) {
        self.artboardImageView.layer.borderColor = [[NSColor redColor] CGColor];
    }
    else {
        self.artboardImageView.layer.borderColor = [[NSColor greenColor] CGColor];
    }
}

@end


@implementation PageHeaderView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
    self.wantsLayer = YES;
    self.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:0.951 alpha:1.000] CGColor];
    
    self.titleLabel = [NSTextField labelWithString:@"Page Name"];
    [self addSubview:self.titleLabel];
    
    [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    
    return self;
}

@end


@interface ArtboardGridViewController ()

@property (strong) SketchDiffTool       *sketchDiffTool;

@property (strong) NSOperationQueue     *artboardPreviewOperationQueue;
@property (strong) NSProgressIndicator  *progressIndicator;

@end


@implementation ArtboardGridViewController

- (id)init {
    self = [super init];
    
    self.pages = @[];
    self.sketchDiffTool = [[SketchDiffTool alloc] init];
    self.artboardPreviewOperationQueue = [[NSOperationQueue alloc] init];
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 640, 640)];
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 640, 640)];
    self.scrollView.backgroundColor = [NSColor redColor];
    [self.view addSubview:self.scrollView];
    
    self.layout = [[NSCollectionViewFlowLayout alloc] init];
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
    [self.scrollView autoPinEdgesToSuperviewEdges];
}

- (void)startLoading {
    self.pages = @[];
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

- (void)collapseAll {
    NSInteger index = 0, count = self.pages.count;
    
    for (index = 0; index < count; index++) {
        [self.layout collapseSectionAtIndex:index];
    }
}

- (SketchOperation *)operationAtIndexPath:(NSIndexPath *)indexPath {
    SketchPage *page = [self.pages objectAtIndex:indexPath.section];
    return [page.diff.allOperations objectAtIndex:indexPath.item];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return self.pages.count;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    SketchPage *page = [self.pages objectAtIndex:section];
    return page.diff.allOperations.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    ArtboardCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"ArtboardCollectionViewItemIdentifier" forIndexPath:indexPath];
    SketchOperation *operation = [self operationAtIndexPath:indexPath];

    item.artboardImageView.image = operation.previewImageB;
    item.statusView.type = operation.type;
    
    if(operation.type == SketchOperationTypeDelete) {
        item.titleLabel.stringValue = [NSString stringWithFormat:@"%@ - %@", operation.layerA.objectClass, operation.layerA.name];
    }
    else {
        item.titleLabel.stringValue = [NSString stringWithFormat:@"%@ - %@",operation.layerB.objectClass, operation.layerB.name];
    }

    return item;
}

- (NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath {
    PageHeaderView *headerView = [collectionView makeSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"PageHeaderViewIdentifier" forIndexPath:indexPath];
    
    SketchPage *page = [self.pages objectAtIndex:indexPath.section];
    
    headerView.titleLabel.stringValue = page.name;
    
    return headerView;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {

}

@end
