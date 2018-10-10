//
//  FilterBarController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 10/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PureLayout/PureLayout.h>


#import "SizeFilterPicker.h"


@interface FilterBarController : NSViewController <SizeFilterPickerDelegate>

@property (assign) id <SizeFilterPickerDelegate>    delegate;

@property (strong) NSStackView          *stackView;

@property (strong) NSButton             *sizeFilterButton;
@property (strong) SizeFilterPicker     *sizeFilterPicker;

@end
