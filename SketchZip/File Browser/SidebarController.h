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
#import "TDCollectionViewListLayout.h"


@class SidebarController;


@interface NSView (TDView)

@property (strong) NSColor  *backgroundColor;
@property (assign) CGFloat  cornerRadius;

@end


@interface SidebarCollectionViewItem : NSCollectionViewItem

@property (strong) NSImageView  *iconView;
@property (strong) NSTextField  *titleLabel;
@property (strong) NSView       *highlightView;

@end


//@interface SidebarItem




@protocol SidebarControllerDelegate <NSObject>

- (void)sidebarController:(SidebarController *)sidebarController didSelectItem:(SidebarCollectionViewItem *)sidebarItem atIndexPath:(NSIndexPath *)indexPath;

@end


@interface SidebarController : NSViewController <NSTokenFieldDelegate, SizeFilterPickerDelegate>

@property (strong) NSTokenField                         *filterTokenField;
//@property (strong) NSP
@property (strong) NSSlider                             *previewSizeSlider;
@property (strong) SizeFilterPicker                     *sizeFilterPicker;

@property (strong) NSScrollView                         *scrollView;
@property (strong) NSCollectionView                     *collectionView;
@property (strong) TDCollectionViewListLayout           *listLayout;

@property (assign) id <SidebarControllerDelegate>       delegate;

- (void)addSketchFile:(SketchFile *)sketchFile;
- (SketchFile *)sketchFileAtIndex:(NSInteger)index;

@end
