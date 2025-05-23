//
//  UIAccessibilityElement-KIFAdditions.m
//  KIF
//
//  Created by Eric Firestone on 5/23/11.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "NSError-KIFAdditions.h"
#import "NSPredicate+KIFAdditions.h"
#import "UIAccessibilityElement-KIFAdditions.h"
#import "UIApplication-KIFAdditions.h"
#import "UIScrollView-KIFAdditions.h"
#import "UIView-KIFAdditions.h"
#import "LoadableCategory.h"
#import "KIFTestActor.h"
#import "KIFUITestActor.h"

MAKE_CATEGORIES_LOADABLE(UIAccessibilityElement_KIFAdditions)

@interface UIAccessibilityElement (KIFAdditions_Private)

- (id)tableViewCell; // UITableViewCellAccessibilityElement

@end

@implementation UIAccessibilityElement (KIFAdditions)

+ (UIView *)viewContainingAccessibilityElement:(UIAccessibilityElement *)element;
{
    while (element && ![element isKindOfClass:[UIView class]]) {
        // Sometimes accessibilityContainer will return a view that's too far up the view hierarchy
        // UIAccessibilityElement instances will sometimes respond to view, so try to use that and then fall back to accessibilityContainer
        id view = nil;
        
        if([element respondsToSelector:@selector(view)]) {
            view = [(id)element view];
        } else if([element respondsToSelector:@selector(tableViewCell)]) {
            view = [(id)element tableViewCell];
        } else if([element isKindOfClass:NSClassFromString(@"UIAccessibilityElementMockView")]) {
            view = [element valueForKey:@"view"];
        }
        
        if (view) {
            element = view;
        } else {
            element = [element accessibilityContainer];
        }
    }
    
    return (UIView *)element;
}

+ (BOOL)accessibilityElement:(out UIAccessibilityElement **)foundElement view:(out UIView **)foundView withLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits tappable:(BOOL)mustBeTappable error:(out NSError **)error
{
    return [self accessibilityElement:foundElement view:foundView withLabel:label value:value traits:traits fromRootView:NULL tappable:mustBeTappable error:error];
}

+ (BOOL)accessibilityElement:(out UIAccessibilityElement **)foundElement view:(out UIView **)foundView withLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits fromRootView:(UIView *)fromView tappable:(BOOL)mustBeTappable error:(out NSError **)error
{
    return [self accessibilityElement:foundElement view:foundView withLabel:label value:value traits:traits fromRootView:fromView tappable:mustBeTappable error:error disableScroll:NO];
}

+ (BOOL)accessibilityElement:(out UIAccessibilityElement **)foundElement view:(out UIView **)foundView withLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits fromRootView:(UIView *)fromView tappable:(BOOL)mustBeTappable error:(out NSError **)error disableScroll:(BOOL)scrollDisabled
{
    UIAccessibilityElement *element = [self accessibilityElementWithLabel:label value:value traits:traits fromRootView:fromView error:error];
    if (!element) {
        return NO;
    }
    
    UIView *view = [self viewContainingAccessibilityElement:element tappable:mustBeTappable error:error disableScroll:scrollDisabled];
    if (!view) {
        return NO;
    }
    
    // viewContainingAccessibilityElement:.. can cause scrolling, which can cause cell reuse.
    // If this happens, the element we kept a reference to might have been reconfigured, and a
    // different element might be the one that matches.
    if (![UIView accessibilityElement:element hasLabel:label accessibilityValue:value traits:traits]) {
        return NO;
    }
    
    if (foundElement) { *foundElement = element; }
    if (foundView) { *foundView = view; }
    return YES;
}

+ (BOOL)accessibilityElement:(out UIAccessibilityElement **)foundElement view:(out UIView **)foundView withElementMatchingPredicate:(NSPredicate *)predicate tappable:(BOOL)mustBeTappable error:(out NSError **)error;
{
    return [self accessibilityElement:foundElement view:foundView withElementMatchingPredicate:predicate tappable:mustBeTappable error:error disableScroll:NO];
}

+ (BOOL)accessibilityElement:(out UIAccessibilityElement **)foundElement view:(out UIView **)foundView withElementMatchingPredicate:(NSPredicate *)predicate tappable:(BOOL)mustBeTappable error:(out NSError **)error disableScroll:(BOOL)scrollDisabled;
{
    UIAccessibilityElement *element = [[UIApplication sharedApplication] accessibilityElementMatchingBlock:^BOOL(UIAccessibilityElement *element) {
        return [predicate evaluateWithObject:element];
    } disableScroll: scrollDisabled];

    if (!element) {
        if (error) {
            *error = [self errorForFailingPredicate:predicate disableScroll:scrollDisabled];
        }
        return NO;
    }
    
    UIView *view = [UIAccessibilityElement viewContainingAccessibilityElement:element tappable:mustBeTappable error:error disableScroll:scrollDisabled];
    if (!view) {
        return NO;
    }
    
    if (foundElement) { *foundElement = element; }
    if (foundView) { *foundView = view; }
    return YES;
}

+ (BOOL)accessibilityElement:(out UIAccessibilityElement *__autoreleasing *)foundElement view:(out UIView *__autoreleasing *)foundView withElementMatchingPredicate:(NSPredicate *)predicate fromRootView:(UIView *)fromView tappable:(BOOL)mustBeTappable error:(out NSError *__autoreleasing *)error
{
    return [self accessibilityElement:foundElement view:foundView withElementMatchingPredicate:predicate fromRootView:fromView tappable:mustBeTappable error:error disableScroll:NO];
}

+ (BOOL)accessibilityElement:(out UIAccessibilityElement *__autoreleasing *)foundElement view:(out UIView *__autoreleasing *)foundView withElementMatchingPredicate:(NSPredicate *)predicate fromRootView:(UIView *)fromView tappable:(BOOL)mustBeTappable error:(out NSError *__autoreleasing *)error disableScroll:(BOOL)scrollDisabled
{
    UIAccessibilityElement *element = [fromView accessibilityElementMatchingBlock:^BOOL(UIAccessibilityElement *element) {
        return [predicate evaluateWithObject:element];
    } disableScroll:scrollDisabled];

    if (!element) {
        if (error) {
            *error = [NSError KIFErrorWithFormat:@"Could not find view matching: %@", predicate];
        }
        return NO;
    }
    
    UIView *view = [UIAccessibilityElement viewContainingAccessibilityElement:element tappable:mustBeTappable error:error disableScroll:scrollDisabled];
    if (!view) {
        return NO;
    }
    
    if (foundElement) { *foundElement = element; }
    if (foundView) { *foundView = view; }
    return YES;
}

+ (UIAccessibilityElement *)accessibilityElementWithLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits error:(out NSError **)error
{
    return [self accessibilityElementWithLabel:label value:value traits:traits fromRootView:NULL error:error];
}

+ (UIAccessibilityElement *)accessibilityElementWithLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits fromRootView:(UIView *)fromView error:(out NSError **)error;
{
    UIAccessibilityElement *element = NULL;
    if (fromView == NULL) {
        element = [[UIApplication sharedApplication] accessibilityElementWithLabel:label accessibilityValue:value traits:traits];
    } else {
        element = [fromView accessibilityElementWithLabel:label accessibilityValue:value traits:traits];
    }
    if (element || !error) {
        return element;
    }
    
    element = [[UIApplication sharedApplication] accessibilityElementWithLabel:label accessibilityValue:nil traits:traits];
    // For purposes of a better error message, see if we can find the view, just not a view with the specified value.
    if (value && element) {
        *error = [NSError KIFErrorWithFormat:@"Found an accessibility element with the label \"%@\", but with the value \"%@\", not \"%@\"", label, element.accessibilityValue, value];
        return nil;
    }
    
    // Check the traits, too.
    element = [[UIApplication sharedApplication] accessibilityElementWithLabel:label accessibilityValue:nil traits:UIAccessibilityTraitNone];
    if (traits != UIAccessibilityTraitNone && element) {
        *error = [NSError KIFErrorWithFormat:@"Found an accessibility element with the label \"%@\", but not with the traits \"%llu\"", label, traits];
        return nil;
    }
    
    *error = [NSError KIFErrorWithFormat:@"Failed to find accessibility element with the label \"%@\"", label];
    return nil;
}

+ (UIView *)viewContainingAccessibilityElement:(UIAccessibilityElement *)element tappable:(BOOL)mustBeTappable error:(NSError **)error;
{
    return [self viewContainingAccessibilityElement:element tappable:mustBeTappable error:error disableScroll:NO];
}

+ (UIView *)viewContainingAccessibilityElement:(UIAccessibilityElement *)element tappable:(BOOL)mustBeTappable error:(NSError **)error disableScroll:(BOOL)scrollDisabled;
{
    // Small safety mechanism.  If someone calls this method after a failing call to accessibilityElementWithLabel:..., we don't want to wipe out the error message.
    if (!element && error && *error) {
        return nil;
    }
    
    // Make sure the element is visible
    UIView *view = [UIAccessibilityElement viewContainingAccessibilityElement:element];
    if (!view) {
        if (error) {
            *error = [NSError KIFErrorWithFormat:@"Cannot find view containing accessibility element with the label \"%@\"", element.accessibilityLabel];
        }
        return nil;
    }

    if(!scrollDisabled) {
        // Scroll the view (and superviews) to be visible if necessary
        UIView *superview = view;
        while (superview) {
            if ([superview isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)superview;
                BOOL animationEnabled = [KIFUITestActor testActorAnimationsEnabled];

                if (((UIAccessibilityElement *)view == element) && ![view isKindOfClass:[UITableViewCell class]]) {
                    [scrollView scrollViewToVisible:view animated:animationEnabled];
                } else {
                    if ([view isKindOfClass:[UITableViewCell class]] && [scrollView.superview isKindOfClass:[UITableView class]]) {
                        UITableViewCell *cell = (UITableViewCell *)view;
                        UITableView *tableView = (UITableView *)scrollView.superview;
                        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
                        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:animationEnabled];
                    } else {
                        CGRect elementFrame = [view.window convertRect:element.accessibilityFrame toView:scrollView];
                        CGRect visibleRect = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds));

                        UIEdgeInsets contentInset;
    #ifdef __IPHONE_11_0
                            if (@available(iOS 11.0, *)) {
                                contentInset = scrollView.adjustedContentInset;
                            } else {
                                contentInset = scrollView.contentInset;
                            }
    #else
                            contentInset = scrollView.contentInset;
    #endif
                        visibleRect = UIEdgeInsetsInsetRect(visibleRect, contentInset);

                        // Only call scrollRectToVisible if the element isn't already visible
                        // iOS 8 will sometimes incorrectly scroll table views so the element scrolls out of view
                        if (!CGRectContainsRect(visibleRect, elementFrame)) {
                            [scrollView scrollRectToVisible:elementFrame animated:animationEnabled];
                        }
                    }

                    // Give the scroll view a small amount of time to perform the scroll.
                    CFTimeInterval delay = animationEnabled ? 0.3 : 0.05;
                    KIFRunLoopRunInModeRelativeToAnimationSpeed(kCFRunLoopDefaultMode, delay, false);

                    // Because of cell reuse the first found view could be different after we scroll.
                    // Find the same element's view to ensure that after we have scrolled we get the same view back.
                    UIView *checkedView = [UIAccessibilityElement viewContainingAccessibilityElement:element];
                    // intentionally doing a memory address check vs a isEqual check because
                    // we want to ensure that the memory address hasn't changed after scroll.
                    if(view != checkedView) {
                        view = checkedView;
                    }
                }
            }

            superview = superview.superview;
        }
    }
    
    // If we don't require tappability, at least make sure it's not hidden
    if ([view isHidden]) {
        if (error) {
            *error = [NSError KIFErrorWithFormat:@"Accessibility element with label \"%@\" is hidden.", element.accessibilityLabel];
        }
        return nil;
    }
    
    if (mustBeTappable && !view.isProbablyTappable) {
        if (error) {
            *error = [NSError KIFErrorWithFormat:@"Accessibility element %@ for view %@ with label \"%@\" is not tappable. It may be blocked by other views.", element, view, element.accessibilityLabel];
        }
        return nil;
    }
    
    return view;
}

+ (NSError *)errorForFailingPredicate:(NSPredicate*)failingPredicate disableScroll:(BOOL) scrollDisabled;
{
    NSPredicate *closestMatchingPredicate = [self findClosestMatchingPredicate:failingPredicate disableScroll:scrollDisabled];
    if (closestMatchingPredicate) {
        return [NSError KIFErrorWithFormat:@"Found element with %@ but not %@", \
                closestMatchingPredicate.kifPredicateDescription, \
                [failingPredicate minusSubpredicatesFrom:closestMatchingPredicate].kifPredicateDescription];
    }
    return [NSError KIFErrorWithFormat:@"Could not find element with %@", failingPredicate.kifPredicateDescription];
}

+ (NSPredicate *)findClosestMatchingPredicate:(NSPredicate *)aPredicate disableScroll:(BOOL) scrollDisabled;
{
    if (!aPredicate) {
        return nil;
    }
    
    UIAccessibilityElement *match = [[UIApplication sharedApplication] accessibilityElementMatchingBlock:^BOOL (UIAccessibilityElement *element) {
        return [aPredicate evaluateWithObject:element];
    } disableScroll:scrollDisabled];
    if (match) {
        return aPredicate;
    }
    
    // Breadth-First algorithm to match as many subpredicates as possible
    NSMutableArray *queue = [NSMutableArray arrayWithObject:aPredicate];
    while (queue.count > 0) {
        // Dequeuing
        NSPredicate *predicate = [queue firstObject];
        [queue removeObject:predicate];
        
        // Remove one subpredicate at a time an then check if an element would match this resulting predicate
        for (NSPredicate *subpredicate in [predicate flatten]) {
            NSPredicate *predicateMinusOneCondition = [predicate minusSubpredicatesFrom:subpredicate];
            if (predicateMinusOneCondition) {
                UIAccessibilityElement *match = [[UIApplication sharedApplication] accessibilityElementMatchingBlock:^BOOL (UIAccessibilityElement *element) {
                    return [predicateMinusOneCondition evaluateWithObject:element];
                } disableScroll:scrollDisabled];
                if (match) {
                    return predicateMinusOneCondition;
                }
                [queue addObject:predicateMinusOneCondition];
            }
        }
    }
    return nil;
}

+ (NSString *)stringFromAccessibilityTraits:(UIAccessibilityTraits)traits;
{
    if (traits == UIAccessibilityTraitNone) {
        return  @"UIAccessibilityTraitNone";
    }
    
    NSString *string = @"";
    
    NSArray *allTraits = @[
                           @(UIAccessibilityTraitButton),
                           @(UIAccessibilityTraitLink),
                           @(UIAccessibilityTraitHeader),
                           @(UIAccessibilityTraitSearchField),
                           @(UIAccessibilityTraitImage),
                           @(UIAccessibilityTraitSelected),
                           @(UIAccessibilityTraitPlaysSound),
                           @(UIAccessibilityTraitKeyboardKey),
                           @(UIAccessibilityTraitStaticText),
                           @(UIAccessibilityTraitSummaryElement),
                           @(UIAccessibilityTraitNotEnabled),
                           @(UIAccessibilityTraitUpdatesFrequently),
                           @(UIAccessibilityTraitStartsMediaSession),
                           @(UIAccessibilityTraitAdjustable),
                           @(UIAccessibilityTraitAllowsDirectInteraction),
                           @(UIAccessibilityTraitCausesPageTurn)
                           ];
    
    NSArray *traitNames = @[
                            @"UIAccessibilityTraitButton",
                            @"UIAccessibilityTraitLink",
                            @"UIAccessibilityTraitHeader",
                            @"UIAccessibilityTraitSearchField",
                            @"UIAccessibilityTraitImage",
                            @"UIAccessibilityTraitSelected",
                            @"UIAccessibilityTraitPlaysSound",
                            @"UIAccessibilityTraitKeyboardKey",
                            @"UIAccessibilityTraitStaticText",
                            @"UIAccessibilityTraitSummaryElement",
                            @"UIAccessibilityTraitNotEnabled",
                            @"UIAccessibilityTraitUpdatesFrequently",
                            @"UIAccessibilityTraitStartsMediaSession",
                            @"UIAccessibilityTraitAdjustable",
                            @"UIAccessibilityTraitAllowsDirectInteraction",
                            @"UIAccessibilityTraitCausesPageTurn"
                            ];
                            
    
    for (NSNumber *trait in allTraits) {
        if ((traits & trait.longLongValue) == trait.longLongValue) {
            NSString *name = [traitNames objectAtIndex:[allTraits indexOfObject:trait]];
            if (string.length > 0) {
                string = [string stringByAppendingString:@", "];
            }
            string = [string stringByAppendingString:name];
            traits &= ~trait.longLongValue;
        }
    }
    if (traits != UIAccessibilityTraitNone) {
        if (string.length > 0) {
            string = [string stringByAppendingString:@", "];
        }
        string = [string stringByAppendingFormat:@"UNKNOWN ACCESSIBILITY TRAIT: %llu", traits];
    }
    return string;
}

@end
