//
//  ArtboardGridViewController.h
//  SketchZip
//
//  Created by Hanno on 06/07/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SketchPage.h"


@interface ArtboardCollectionViewItem : NSCollectionViewItem

@property (strong) SketchLayer   *artboard;
@property (strong) NSTextField      *titleLabel;
@property (strong) NSImageView      *artboardImageView;

@end


@interface ArtboardGridViewController : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>

@property (strong) NSScrollView                 *scrollView;
@property (strong) NSCollectionView             *collectionView;
@property (strong) NSCollectionViewGridLayout   *gridLayout;

- (void)loadChangesFromFile:(NSURL *)fileA to:(NSURL *)fileB;

@end
