//
//  FilterBarController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 10/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "FilterBarController.h"


@interface FilterBarController ()

@property (strong) NSMutableDictionary *filters;

@end


@implementation FilterBarController

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection {
    self = [super init];
    
    _assetCollection = assetCollection;
    
    self.previewSizeSlider = [[NSSlider alloc] init];
    
    self.sizePopUpButton = [[NSPopUpButton alloc] init];
    self.filters = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] init];
    
    self.stackView = [[NSStackView alloc] init];
    [self.view addSubview:self.stackView];
    
    self.filterTextField = [[SearchField alloc] init];
    self.filterTextField.placeholderString = @"Filter";
    self.filterTextField.sendsSearchStringImmediately = YES;
    [self.filterTextField setTarget:self];
    [self.filterTextField setAction:@selector(filterTextFieldChanged:)];
    [self.stackView addView:self.filterTextField inGravity:NSStackViewGravityLeading];
    
    for (SizeFilter *filter in [SizeFilter appleDeviceFilters]) {
        NSString *name = filter.presetName;
        [self.filters setObject:filter forKey:name];
        [self.sizePopUpButton addItemWithTitle:name];
    }
    
    [self.sizePopUpButton setTarget:self];
    [self.sizePopUpButton setAction:@selector(sizeFilterChanged:)];
    
    [self.stackView addView:self.sizePopUpButton inGravity:NSStackViewGravityTrailing];

    self.previewSizeSlider.minValue = 0.5;
    self.previewSizeSlider.maxValue = 2;
    [self.stackView addView:self.previewSizeSlider inGravity:NSStackViewGravityTrailing];
    
    // Autolayout
    [self.stackView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 4, 0, 4)];
    
    [self.filterTextField autoSetDimension:ALDimensionWidth toSize:320 relation:NSLayoutRelationLessThanOrEqual];
    [self.previewSizeSlider autoSetDimension:ALDimensionWidth toSize:160 relation:NSLayoutRelationLessThanOrEqual];
}

- (void)sizeFilterChanged:(id)sender {
    
    NSString *name = [self.sizePopUpButton titleOfSelectedItem];
    Filter *filter = [self.filters objectForKey:name];
    
    [self.assetCollection replaceFilter:filter];
    [self.assetCollection reloadData];
}

- (void)filterTextFieldChanged:(id)sender {
    NSLog(@"Filter: %@", self.filterTextField.stringValue);
    
    KeywordFilter *keywordFilter = [[KeywordFilter alloc] init];
    keywordFilter.keywords = self.filterTextField.stringValue;
    
    [self.assetCollection replaceFilter:keywordFilter];
    [self.assetCollection reloadData];
}

- (IBAction)find:(id)sender {
    [self.filterTextField becomeFirstResponder];
}

@end
