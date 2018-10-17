//
//  FilterBarController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 10/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PureLayout/PureLayout.h>


#import "Theme.h"
#import "Asset.h"
#import "Filter.h"


@class FilterBarController;


@protocol FilterBarControllerDelegate <NSObject>

- (void)filterBarController:(FilterBarController *)filterBarController didUpdateFilter:(Filter *)filter;

@end


@interface FilterBarController : NSViewController

@property (assign) id <FilterBarControllerDelegate>    delegate;

@property (strong) NSStackView          *stackView;

@property (strong) NSSearchField        *filterTextField;
@property (strong) NSPopUpButton        *sizePopUpButton;
@property (strong) NSSlider             *previewSizeSlider;

@property (strong) AssetCollection      *assetCollection;

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection;

- (IBAction)find:(id)sender;

@end
