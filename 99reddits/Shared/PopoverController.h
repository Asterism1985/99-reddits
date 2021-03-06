//
//  PopoverController.h
//  99reddits
//
//  Created by Frank Jacob on 12/10/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PopoverControllerDelegate;
@class PopoverWindow;

@interface PopoverController : NSObject {
	id<PopoverControllerDelegate> __weak delegate;
	UIViewController *contentViewController;
	PopoverWindow *window;
	CGSize popoverContentSize;
	BOOL fullscreen;
	
	UIWindow *ownerWindow;
}

@property (nonatomic, weak) id<PopoverControllerDelegate> delegate;
@property (nonatomic, assign) CGSize popoverContentSize;
@property (nonatomic, assign) BOOL fullscreen;
@property (nonatomic, readonly) UIWindow *ownerWindow;

- (id)initWithContentViewController:(UIViewController *)viewController;
- (void)showPopover:(BOOL)animated;
- (void)dismissPopover:(BOOL)animated;

@end

@protocol PopoverControllerDelegate <NSObject>

@optional
- (void)popoverControllerDidDismissed:(PopoverController *)controller;

@end
