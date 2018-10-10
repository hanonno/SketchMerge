//
//  FilterBarController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 10/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "FilterBarController.h"


@interface FilterBarController ()

@end


@implementation FilterBarController

- (instancetype)init {
    self = [super init];
    
    self.sizeFilterPicker = [[SizeFilterPicker alloc] init];
    self.sizeFilterPicker.delegate = self;

    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] init];
    
    self.stackView = [[NSStackView alloc] init];
    [self.view addSubview:self.stackView];
    
    self.sizeFilterButton = [NSButton buttonWithTitle:@"Size" target:self action:@selector(changeSizeFilter:)];
    [self.stackView addArrangedSubview:self.sizeFilterButton];
    
    // Autolayout
    [self.stackView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 24, 0, 24)];
}


- (void)changeSizeFilter:(id)sender {
    [self presentViewController:self.sizeFilterPicker asPopoverRelativeToRect:self.sizeFilterButton.frame ofView:self.stackView preferredEdge:NSRectEdgeMaxY behavior:NSPopoverBehaviorTransient];
}

- (void)sizeFilterPicker:(SizeFilterPicker *)sizeFilterPicker didPickFilter:(SizeFilter *)filter {
//    [self dismissController:self.sizeFilterPicker];

    [self.sizeFilterButton setTitle:filter.presetName];
    [self.delegate sizeFilterPicker:sizeFilterPicker didPickFilter:filter];
}

@end
