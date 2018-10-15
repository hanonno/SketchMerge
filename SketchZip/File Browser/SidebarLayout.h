//
//  SidebarLayout.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 08/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SidebarLayout : NSCollectionViewLayout

@property (assign) BOOL     headersVisible;

- (void)collapseSectionAtIndex:(NSInteger)index;
- (void)expandSectionAtIndex:(NSInteger)index;
- (void)toggleSectionAtIndex:(NSInteger)index;

@end
