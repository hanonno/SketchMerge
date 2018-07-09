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
//    self.view.layer.backgroundColor = [[NSColor redColor] CGColor];
    
    self.artboardImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 320, 320)];
    self.artboardImageView.wantsLayer = YES;
    self.artboardImageView.layer.backgroundColor = [[NSColor lightGrayColor] CGColor];
    self.artboardImageView.layer.cornerRadius = 8;
    [self.view addSubview:self.artboardImageView];
    
    self.titleLabel = [NSTextField labelWithString:@"Test"];
    self.titleLabel.alignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    // Auto Layout
    [self.artboardImageView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [self.artboardImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.titleLabel withOffset:-4];
    
    [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeTop];
    [self.titleLabel autoSetDimension:ALDimensionHeight toSize:22];
}

@end



@interface ArtboardGridViewController ()

@property (strong) SketchDiffTool       *sketchDiffTool;
@property (strong) NSArray              *transactions;
@property (strong) NSProgressIndicator  *progressIndicator;

@end


@implementation ArtboardGridViewController

- (id)init {
    self = [super init];
    
    self.transactions = @[];
    self.sketchDiffTool = [[SketchDiffTool alloc] init];
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 640, 640)];
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 640, 640)];
    self.scrollView.backgroundColor = [NSColor redColor];
//    self.scrollView.automaticallyAdjustsContentInsets = NO;
//    self.scrollView.contentInsets = NSEdgeInsetsMake(16, 16, 16, 16);
    [self.view addSubview:self.scrollView];
    
    self.gridLayout = [[NSCollectionViewGridLayout alloc] init];
    self.gridLayout.minimumItemSize = NSMakeSize(320-16, 320-16);
    self.gridLayout.maximumItemSize = NSMakeSize(64, 64);
    self.gridLayout.minimumLineSpacing = 16;
    self.gridLayout.minimumInteritemSpacing = 16;
    self.gridLayout.margins = NSEdgeInsetsMake(16, 16, 16, 16);
    
    self.collectionView = [[NSCollectionView alloc] initWithFrame:self.view.bounds];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.collectionViewLayout = self.gridLayout;
    [self.collectionView registerClass:[ArtboardCollectionViewItem class] forItemWithIdentifier:@"ArtboardCollectionViewItemIdentifier"];
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

- (void)loadChangesFromFile:(NSURL *)oldFileURL to:(NSURL *)newFileURL {
    [self.progressIndicator setFrameOrigin:NSMakePoint(
        (NSWidth([self.progressIndicator.superview bounds]) - NSWidth([self.progressIndicator frame])) / 2,
        (NSHeight([self.progressIndicator.superview bounds]) - NSHeight([self.progressIndicator frame])) / 2
    )];
    
    [self.progressIndicator startAnimation:self];
    
    self.transactions = @[];
    [self.collectionView reloadData];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSArray *transactions = [self.sketchDiffTool diffFromFile:oldFileURL to:newFileURL];
        
        for (CoreSyncTransaction *transaction in transactions) {
            NSLog(@"page: %@ > layer index: %@", transaction.pageID, transaction.artboardID);
            
            NSImage *image = [self.sketchDiffTool imageForArtboardWithID:transaction.artboardID inFileWithURL:newFileURL maxSize:CGSizeMake(1280, 1280)];
            transaction.image = image;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.transactions = transactions;
            
            [self.collectionView reloadData];
            [self.progressIndicator stopAnimation:self];
        });
    });
}

- (CoreSyncTransaction *)transactionAtIndexPath:(NSIndexPath *)indexPath {
    return [self.transactions objectAtIndex:indexPath.item];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.transactions.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    ArtboardCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"ArtboardCollectionViewItemIdentifier" forIndexPath:indexPath];
    CoreSyncTransaction *transaction = [self transactionAtIndexPath:indexPath];

    item.artboardImageView.image = transaction.image;
    
    if(transaction.transactionType == CSTransactionTypeDeletion) {
        item.titleLabel.stringValue = [NSString stringWithFormat:@"Deleted %@", transaction.artboardName];
    }
    else if(transaction.transactionType == CSTransactionTypeAddition) {
        item.titleLabel.stringValue = [NSString stringWithFormat:@"Added %@", transaction.artboardName];
    }
    else if(transaction.transactionType == CSTransactionTypeEdit) {
        item.titleLabel.stringValue = [NSString stringWithFormat:@"Updated %@", transaction.artboardName];
    }
    
    return item;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {

}

@end
