//
//  SidebarController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 24/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TDCollectionViewListLayout.h"


@interface NSView (TDView)

@property (strong) NSColor  *backgroundColor;
@property (assign) CGFloat  cornerRadius;

@end


@interface SidebarItem : NSCollectionViewItem

@property (strong) NSImageView  *iconView;
@property (strong) NSTextField  *titleLabel;
@property (strong) NSView       *highlightView;

@end


@interface SidebarController : NSViewController

@property (strong) NSScrollView                 *scrollView;
@property (strong) NSCollectionView             *collectionView;
@property (strong) TDCollectionViewListLayout   *listLayout;

@end
