//
//  SidebarController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 24/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#import "TDTheme.h"
#import "SketchFile.h"
#import "SizeFilterPicker.h"
#import "SidebarLayout.h"
#import "TDCollectionViewListLayout.h"


@class SidebarController;


@interface SidebarHeaderView : NSView

@property (strong) NSImageView  *iconView;
@property (strong) NSTextField  *titleLabel;
@property (strong) NSView       *highlightView;
@property (strong) NSButton     *disclosureButton;

@end


@interface SidebarCollectionViewItem : NSCollectionViewItem

@property (strong) NSImageView  *iconView;
@property (strong) NSTextField  *titleLabel;
@property (strong) NSView       *highlightView;

@end


@protocol SidebarControllerDelegate <NSObject>

- (void)sidebarController:(SidebarController *)sidebarController didSelectItem:(SidebarCollectionViewItem *)sidebarItem atIndexPath:(NSIndexPath *)indexPath;

@end


@interface SidebarController : NSViewController <NSTokenFieldDelegate>

@property (strong) NSScrollView                         *scrollView;
@property (strong) NSCollectionView                     *collectionView;
@property (strong) SidebarLayout                        *sidebarLayout;

@property (assign) id <SidebarControllerDelegate>       delegate;

- (void)addSketchFile:(SketchFile *)sketchFile;
- (SketchFile *)sketchFileAtIndex:(NSInteger)index;

@end
