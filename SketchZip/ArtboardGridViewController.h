//
//  ArtboardGridViewController.h
//  SketchZip
//
//  Created by Hanno on 06/07/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ArtboardCollectionViewItem : NSCollectionViewItem

@property (strong) NSTextField  *titleLabel;
@property (strong) NSImageView  *artboardImageView;

@end


@interface ArtboardGridViewController : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>

@property (strong) NSScrollView                 *scrollView;
@property (strong) NSCollectionView             *collectionView;
@property (strong) NSCollectionViewGridLayout   *gridLayout;

- (void)loadChangesFromFile:(NSURL *)oldFileURL to:(NSURL *)newFileURL;

@end
