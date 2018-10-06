//
//  SketchItemBrowserController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PureLayout/PureLayout.h>


#import "SketchItem.h"


@interface ItemBrowserItem : NSCollectionViewItem

@property (strong) NSTextField                      *titleLabel;
@property (strong) NSImageView                      *artboardImageView;
@property (strong) NSImageView                      *presetIconView;

@end


@interface ItemBrowserHeader : NSView

@property (strong) NSTextField  *titleLabel;
@property (strong) NSTextField  *subtitleLabel;

@end


@interface SketchItemBrowser : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>

@property (strong) NSScrollView                 *scrollView;
@property (strong) NSCollectionView             *collectionView;
@property (strong) NSCollectionViewFlowLayout   *layout;

@property (strong) RLMRealm                     *realm;

- (instancetype)initWithRealm:(RLMRealm *)realm;

@end
