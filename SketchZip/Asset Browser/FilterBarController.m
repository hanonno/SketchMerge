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
    
    self.favoriteFilter = [[FavoriteFilter alloc] init];
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] init];
    
    self.stackView = [[NSStackView alloc] init];
    [self.view addSubview:self.stackView];
    
    self.sizeFilterButton = [NSButton buttonWithTitle:@"Size" target:self action:@selector(changeSizeFilter:)];
    [self.stackView addArrangedSubview:self.sizeFilterButton];
    
    self.favoriteButton = [NSButton buttonWithTitle:@"Favorites" target:self action:@selector(changeFavoritesButton:)];
    [self.stackView addArrangedSubview:self.favoriteButton];
    
    self.statusButton = [NSButton buttonWithTitle:@"In progress" target:self action:@selector(changeStatusButton:)];
    [self.stackView addArrangedSubview:self.statusButton];
    
    // Autolayout
    [self.stackView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 8, 0, 8)];
}


- (void)changeSizeFilter:(id)sender {
    [self presentViewController:self.sizeFilterPicker asPopoverRelativeToRect:self.sizeFilterButton.frame ofView:self.stackView preferredEdge:NSRectEdgeMaxY behavior:NSPopoverBehaviorTransient];
}

- (void)changeFavoritesButton:(id)sender {
    NSLog(@"Favorites!");
    
    self.favoriteFilter.enabled = !self.favoriteFilter.enabled;
    
    if([self.delegate respondsToSelector:@selector(filterBarController:didUpdateFilter:)]) {
        [self.delegate filterBarController:self didUpdateFilter:self.favoriteFilter];
    }
}

- (void)changeStatusButton:(id)sender{
    NSLog(@"Status");
}

- (void)sizeFilterPicker:(SizeFilterPicker *)sizeFilterPicker didPickFilter:(SizeFilter *)filter {
//    [self dismissController:self.sizeFilterPicker];

    [self.sizeFilterButton setTitle:filter.presetName];
    
    if([self.delegate respondsToSelector:@selector(filterBarController:didUpdateFilter:)]) {
        [self.delegate filterBarController:self didUpdateFilter:filter];
    }
}

@end
