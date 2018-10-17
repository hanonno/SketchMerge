//
//  SizeFilterPicker.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 07/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PureLayout/PureLayout.h>


#import "Theme.h"
#import "Filter.h"


@interface MenuItemView : NSControl

@property (strong) NSImageView  *iconView;
@property (strong) NSTextField  *titleLabel;
@property (strong) NSTextField  *subtitleLabel;
@property (strong) NSView       *highlightView;

@property (strong) id           representedObject;

@end


@class SizeFilterPicker;


@protocol SizeFilterPickerDelegate <NSObject>

- (void)sizeFilterPicker:(SizeFilterPicker *)sizeFilterPicker didPickFilter:(SizeFilter *)filter;

@end


@interface SizeFilterPicker : NSViewController

@property id <SizeFilterPickerDelegate>     delegate;

@property (strong) NSArray                  *filters;
@property (strong) NSStackView              *stackView;

@end
