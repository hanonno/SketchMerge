//
//  SidebarLayout.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 08/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SidebarLayout.h"


@interface SidebarSection : NSObject

@property (strong) NSCollectionViewLayoutAttributes *headerAttributes;
@property (strong) NSMutableArray                   *itemAttributes;
@property (strong) NSMutableSet                     *itemIndexPaths;

@end

@implementation SidebarSection

- (instancetype)init {
    self = [super init];
    
    _itemAttributes = [[NSMutableArray alloc] init];
    _itemIndexPaths = [[NSMutableSet alloc] init];
    
    return self;
}

@end


@interface SidebarLayout ()

@property (strong) NSArray              *sections;
@property (strong) NSArray              *oldSections;

@property (assign) CGFloat              headerHeight;
@property (assign) CGFloat              itemHeight;
@property (assign) NSSize               collectionViewContentSize;
@property (strong) NSMutableIndexSet    *collapsedSectionIndexes;

@end


@implementation SidebarLayout

- (instancetype)init {
    self = [super init];
    
    _headerHeight = 56;
    _itemHeight = 28;
    _collapsedSectionIndexes = [[NSMutableIndexSet alloc] init];
    
    return self;
}

- (SidebarSection *)sectionAtIndex:(NSInteger)index {
    return [self.sections objectAtIndex:index];
}

- (void)collapseSectionAtIndex:(NSInteger)index {
    [self.collapsedSectionIndexes addIndex:index];
}

- (void)expandSectionAtIndex:(NSInteger)index {
    [self.collapsedSectionIndexes removeIndex:index];
}

- (void)toggleSectionAtIndex:(NSInteger)index {
    if([self.collapsedSectionIndexes containsIndex:index]) {
        [self expandSectionAtIndex:index];
    }
    else {
        [self collapseSectionAtIndex:index];
    }
}

- (void)prepareLayout {
    NSInteger numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    
    CGSize size = self.collectionView.enclosingScrollView.frame.size;
    CGPoint origin = CGPointZero;
    
    CGFloat headerHeight = self.headerHeight;
    
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    
    for (NSInteger currentSection = 0; currentSection < numberOfSections; currentSection++) {
        SidebarSection *section = [[SidebarSection alloc] init];
    
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:currentSection];
        
        NSCollectionViewLayoutAttributes *headerAttributes = [NSCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIndexPath:indexPath];
        headerAttributes.frame = CGRectMake(origin.x, origin.y, size.width, headerHeight);
        section.headerAttributes = headerAttributes;

        origin.y = origin.y + headerHeight;
        
        NSInteger numberOfItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:indexPath.section];
//        NSMutableArray *itemAttributes = [[NSMutableArray alloc] init];

        BOOL sectionCollapsed = [self.collapsedSectionIndexes containsIndex:currentSection];
        
        CGFloat itemHeight = self.itemHeight;
//        CGFloat itemHeight = self.itemHeight;
        
        for(NSInteger currentItem = 0; currentItem < numberOfItems; currentItem++) {
            indexPath = [NSIndexPath indexPathForItem:currentItem inSection:currentSection];
            NSCollectionViewLayoutAttributes *itemAttributes = [NSCollectionViewLayoutAttributes layoutAttributesForItemWithIndexPath:indexPath];
            
            if(sectionCollapsed) {
//                itemAttributes.alpha = 1.0;
                itemAttributes.frame = CGRectMake(size.width, section.headerAttributes.frame.origin.y, size.width, 0);
            }
            else {
                itemAttributes.frame = CGRectMake(origin.x, origin.y, size.width, itemHeight);
//                itemAttributes.alpha = 1.0;
                origin.y = origin.y + itemHeight;
            }

            [section.itemAttributes addObject:itemAttributes];
            [section.itemIndexPaths addObject:indexPath];
        }
        
        [sections addObject:section];
    }
    
    self.collectionViewContentSize = NSMakeSize(size.width, origin.y);
    self.sections = sections;
}

- (NSArray*)layoutAttributesForElementsInRect:(NSRect)rect {
    NSMutableArray *layoutAttributes = [[NSMutableArray alloc] init];
    
    for (SidebarSection *section in self.sections) {
        [layoutAttributes addObject:section.headerAttributes];
        [layoutAttributes addObjectsFromArray:section.itemAttributes];
    }
    
    return layoutAttributes;
}

- (NSCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[self sectionAtIndex:indexPath.section].itemAttributes objectAtIndex:indexPath.item];
}

//- (NSCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
//    NSCollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//    layoutAttributes.alpha = 0.2;
//    return layoutAttributes;
//}
//
//- (NSCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
//    NSCollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//    layoutAttributes.alpha = 1.0;
//    return layoutAttributes;
//}

- (NSCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSCollectionViewSupplementaryElementKind)elementKind atIndexPath:(NSIndexPath *)indexPath {
    return [self sectionAtIndex:indexPath.section].headerAttributes;
}

@end
