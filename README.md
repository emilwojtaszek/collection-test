# Intro
This an example of UICollectionView with custom layout, using UICollectionViewInvalidationContext to work with self-sizing cells.

## TextCell
Simple subclass of UICollectionViewCell which display cell with UILabel inside.

## DataSource
This object is a collection view data source that will return *n* sections with one cell inside (colored, with random text inside). 

## MyLayoutAttributes
In this project I'm using custom subclass of UICollectionViewLayoutAttributes. This sublass has one property called `preferredWidth` which is width of collection view delegated form UICollectionViewLayout. `TextCell` class use this value in `self.preferredLayoutAttributesFitting(_:)` to activate additional width constraint. As a result of this operation each cell width is equal to collection view width.

## MyLayout
It's a subclass of UICollectionViewLayout. I've tried to comment each line in this file to explain everything I know.
Method `self.layoutAttributesForItem(at:)` returns newly created subclass of `MyLayoutAttributes` with already calculated frame.
In method `self.layoutAttributesForElements(in:)` I'm iterating over available indexPaths, finding index paths of layout attributes that frames are intersecting with current bounds.

I'm keeping cached cell size under array called `cachedSizes` where index is cell's section index.
If key is out of bounds, i'm using `estimatedHeight` property as default cell height.

**Now the fun part, context invalidation.**

1. First i'm checking if cached size of cell is different from preferredAttributes.size in `self.shouldInvalidateLayout(forPreferredLayoutAttributes:withOriginalAttributes:)`.
If true, that means I need to invalidate this cell...

2. In `self.invalidationContext(forPreferredLayoutAttributes:withOriginalAttributes:)` I'm caching new value of calculated cell size and invalidating item at given this index path and all index paths below (since at least frame origin of next cells will change).

3. This process will repeat until all cells have proper size.

## My Problems:

1. When you run project and scroll slowly everything looks great, self-sizing cells works! (https://cl.ly/1U2L1h3y2u43)
But when you scroll more dynamically strage things are happening, like some cell size is wrong, or strange spacing between cells occures (https://cl.ly/0T023b1T0u3l) 

2. I'm randomizing cell's label text to be 1-3 line text, so cell height is between 50pt - 77pt, that's why layout's `estimatedHeight` property is equal to 50pt which is resonable in this case. But when we increase this value to much bigger like 150 starange things are happening (https://cl.ly/2M452a2s0G0N). In production evniroment cell have more that three lines... What's the best approach here?

3. `preferredLayoutAttributesFitting(_:)` in TextCell is calling several times, in more complicated layouts this makes some performance issues / frames droppings. How can I improve/avoid this?

4. How does adding self-sizing cell work with custom layouts, since initial frame is estimated? 
From my reaserch, after insert cell is first layouted/displayed and then CollectionViewLayout try to invalidate cell to set proper frame. How can I get poper frame size a priori?
