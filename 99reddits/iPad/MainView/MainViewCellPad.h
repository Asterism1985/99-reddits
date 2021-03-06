//
//  MainViewCellPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewControllerPad;
@class SubRedditItem;

@interface MainViewCellPad : UICollectionViewCell {
	MainViewControllerPad __weak *mainViewController;
	SubRedditItem __weak *subReddit;

	UIView *imageOutlineView;
	UIImageView *imageView;
	UIButton *tapButton;
//	UIActivityIndicatorView *activityIndicator;
	UIButton *deleteButton;
	UIView *unshowedBackView;
	UILabel *unshowedLabel;
	UILabel *nameLabel;
	UIImageView *animateImageView;

	NSInteger unshowedCount;
	NSInteger totalCount;
	BOOL loading;
	
	BOOL bFavorites;
	BOOL editing;

	BOOL imageEmpty;
}

@property (nonatomic, weak) MainViewControllerPad *mainViewController;
@property (nonatomic, weak) SubRedditItem *subReddit;
@property (nonatomic, readonly) UILabel *nameLabel;

- (void)setUnshowedCount:(NSInteger)_unshowedCount totalCount:(NSInteger)_totalCount loading:(BOOL)_loading;
- (void)setTotalCount:(NSInteger)_totalCount;
- (void)setThumbImage:(UIImage *)thumbImage animated:(BOOL)animated;
- (void)setEditing:(BOOL)_editing;

@end
