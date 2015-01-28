//
//  PhotoViewControllerPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "PhotoViewControllerPad.h"
#import "NIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import <Accounts/Accounts.h>
#import "UserDef.h"
#import <ImageIO/CGImageSource.h>
#import "PhotoView.h"
#import <Social/Social.h>
#import "CommentViewControllerPad.h"

@interface PhotoViewControllerPad ()

- (void)requestImageFromSource:(NSString *)source photoSize:(NIPhotoScrollViewPhotoSize)photoSize photoIndex:(NSInteger)photoIndex;

- (void)shareImage:(UIImage *)image;

@end

@implementation PhotoViewControllerPad

@synthesize subReddit;
@synthesize index;
@synthesize disappearForSubview;
@synthesize bFavorites;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)dealloc {
	[self releaseCaches];
}

- (void)releaseCaches {
	for (ASIHTTPRequest *request in queue.operations) {
		[request clearDelegatesAndCancel];
	}
	
	activeRequests = nil;
	queue = nil;
}

- (void)didReceiveMemoryWarning {
	for (ASIHTTPRequest *request in queue.operations) {
		[request clearDelegatesAndCancel];
	}
	[activeRequests removeAllObjects];
	
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentButton.frame = CGRectMake(0, 0, 25, 25);
	[commentButton setBackgroundImage:[UIImage imageNamed:@"CommentBlueIcon.png"] forState:UIControlStateNormal];
	[commentButton addTarget:self action:@selector(onCommentButton:) forControlEvents:UIControlEventTouchUpInside];
	commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
	
	UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
	redButton.frame = CGRectMake(0, 0, 25, 25);
	[redButton setBackgroundImage:[UIImage imageNamed:@"FavoritesRedIcon.png"] forState:UIControlStateNormal];
	[redButton addTarget:self action:@selector(onFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
	favoriteRedItem = [[UIBarButtonItem alloc] initWithCustomView:redButton];
	
	UIButton *whiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	whiteButton.frame = CGRectMake(0, 0, 25, 25);
	[whiteButton setBackgroundImage:[UIImage imageNamed:@"FavoritesBlueIcon.png"] forState:UIControlStateNormal];
	[whiteButton addTarget:self action:@selector(onFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
	favoriteWhiteItem = [[UIBarButtonItem alloc] initWithCustomView:whiteButton];
	
	rightItem.translucent = YES;
	[rightItem setBackgroundImage:[UIImage imageNamed:@"Transparent.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteRedItem, actionItem, commentItem, nil];
	
	appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	activeRequests = [[NSMutableSet alloc] init];
	
	queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:3];
	
	self.titleLabel.font = [UIFont boldSystemFontOfSize:30];
	
	self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultPhotoLarge" ofType:@"png"]];
	self.photoAlbumView.dataSource = self;
	self.photoAlbumView.backgroundColor = [UIColor blackColor];
	self.photoAlbumView.photoViewBackgroundColor = [UIColor blackColor];
	
	[self.photoAlbumView reloadData];
	[self.photoAlbumView moveToPageAtIndex:index animated:NO];
	
	[appDelegate checkNetworkReachable:YES];
	
	disappearForSubview = NO;
	
	sharing = NO;
	
	self.titleLabelBar.hidden = YES;
	self.titleLabel.hidden = YES;
	
	self.toolbarOffset = 44;
	
	[self.view bringSubviewToFront:prevPhotoButton];
	[self.view bringSubviewToFront:nextPhotoButton];
	[self.view bringSubviewToFront:fullPhotoButton];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (void)viewWillAppear:(BOOL)animated {
	if (!disappearForSubview) {
		[super viewWillAppear:YES];
	}
	
	disappearForSubview = NO;
	[self.photoAlbumView moveToPageAtIndex:self.photoAlbumView.centerPageIndex animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	[self setTitleLabelText:photo.titleString];
	self.titleLabelBar.hidden = NO;
	self.titleLabel.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	if (!disappearForSubview) {
		[super viewWillDisappear:animated];
	}
	
	if (favoriteActionSheet) {
		[favoriteActionSheet dismissWithClickedButtonIndex:favoriteActionSheet.cancelButtonIndex animated:NO];
		favoriteActionSheet = nil;
	}
	
	if (sharePopoverController) {
		[sharePopoverController dismissPopoverAnimated:YES];
		sharePopoverController = nil;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	if (!disappearForSubview) {
		sharing = NO;
	}
	
	self.titleLabelBar.hidden = YES;
	self.titleLabel.hidden = YES;

	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		[self releaseCaches];
	}
}

- (IBAction)onActionButton:(id)sender {
	if (favoriteActionSheet) {
		[favoriteActionSheet dismissWithClickedButtonIndex:favoriteActionSheet.cancelButtonIndex animated:YES];
		favoriteActionSheet = nil;
	}
	
	if (sharePopoverController) {
		[sharePopoverController dismissPopoverAnimated:YES];
		sharePopoverController = nil;
	}
	
	if (sharing)
		return;
	
	sharing = YES;
	sharingIndex = self.photoAlbumView.centerPageIndex;
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];
	
	[self requestImageFromSource:photo.urlString photoSize:NIPhotoScrollViewPhotoSizeOriginal photoIndex:sharingIndex];
}

// UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex)
		return;
	
	if (actionSheet.tag == 101) {
		NSInteger currentIndex = self.photoAlbumView.centerPageIndex;
		PhotoItem *photo = [subReddit.photosArray objectAtIndex:currentIndex];
		if ([appDelegate removeFromFavorites:photo]) {
			if (subReddit.photosArray.count == 0) {
				[self.navigationController popToRootViewControllerAnimated:YES];
				return;
			}
			
			if (currentIndex == subReddit.photosArray.count)
				currentIndex = subReddit.photosArray.count - 1;
			
			[activeRequests removeAllObjects];
			[queue cancelAllOperations];
			
			[self.photoAlbumView reloadData];
			[self.photoAlbumView moveToPageAtIndex:currentIndex animated:NO];
			[self pagingScrollViewDidChangePages:self.photoAlbumView];
		}
	}
	
	favoriteActionSheet = nil;
}

- (void)requestImageFromSource:(NSString *)source photoSize:(NIPhotoScrollViewPhotoSize)photoSize photoIndex:(NSInteger)photoIndex {
//	if (![appDelegate checkNetworkReachable:NO])
//		return;
	
	if (photoIndex >= subReddit.photosArray.count)
		return;
	
	NSInteger identifier = photoIndex;
	NSNumber *identifierKey = [NSNumber numberWithInteger:identifier];
	
	if ([activeRequests containsObject:identifierKey]) {
		return;
	}
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:photoIndex];
	
	BOOL isFullImage = YES;
	if (![appDelegate isFullImage:source] && ![photo isGif]) {
		NSString *hugeSource = [appDelegate getHugeImage:source];
		if (![hugeSource isEqualToString:source]) {
			source = hugeSource;
			isFullImage = NO;
		}
	}
	
	NSURL *url = [NSURL URLWithString:source];
	
	__block NIHTTPRequest __weak *readOp = [NIHTTPRequest requestWithURL:url usingCache:[ASIDownloadCache sharedCache]];
	readOp.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
	readOp.timeOutSeconds = 30;
	readOp.tag = photoIndex;
	
	[readOp setCompletionBlock:^{
		NSData *data = [readOp responseData];
		UIImage *image = [UIImage imageWithData:data];
		
		size_t imageCount = 1;
		if (image && subReddit.photosArray.count > photoIndex) {
			[self.photoAlbumView didLoadPhoto:image atIndex:photoIndex photoSize:photoSize error:NO];

			if (photoIndex == self.photoAlbumView.centerPageIndex) {
				CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
				if (imageSource) {
					imageCount = CGImageSourceGetCount(imageSource);
					if (imageCount > 1) {
						uint8_t c;
						[data getBytes:&c length:1];
						if (c == 0x47) {
							[self.photoAlbumView didLoadGif:data atIndex:photoIndex];
						}
					}
					CFRelease(imageSource);
				}
				
				if (!isFullImage && (image.size.width >= 1024 || image.size.height >= 1024)) {
					fullPhotoButton.enabled = YES;
				}
				else {
					fullPhotoButton.enabled = NO;
				}
			}
		}
		else {
			[self.photoAlbumView didLoadPhoto:[UIImage imageNamed:@"Error.png"] atIndex:photoIndex photoSize:photoSize error:YES];
			
			if (photoIndex == self.photoAlbumView.centerPageIndex) {
				fullPhotoButton.enabled = NO;
			}
		}
		
		if (photoIndex == self.photoAlbumView.centerPageIndex) {
			PhotoItem *photo = [subReddit.photosArray objectAtIndex:photoIndex];
			
			if (![photo isShowed]) {
				[appDelegate.showedSet addObject:photo.idString];
				subReddit.unshowedCount --;
			}
			
			if (sharing && photoIndex == sharingIndex && image) {
				[self shareImage:image];
			}
			else {
				sharing = NO;
			}
		}
		else {
			sharing = NO;
		}
		
		[activeRequests removeObject:identifierKey];
	}];
	
	[readOp setFailedBlock:^{
		[self.photoAlbumView didLoadPhoto:[UIImage imageNamed:@"Error.png"] atIndex:photoIndex photoSize:photoSize error:YES];
		
		if (photoIndex == self.photoAlbumView.centerPageIndex) {
			PhotoItem *photo = [subReddit.photosArray objectAtIndex:photoIndex];
			
			if (![photo isShowed]) {
				[appDelegate.showedSet addObject:photo.idString];
				subReddit.unshowedCount --;
			}
			
			fullPhotoButton.enabled = NO;
		}
		
		sharing = NO;
		
		[activeRequests removeObject:identifierKey];
	}];
	
	[readOp setQueuePriority:NSOperationQueuePriorityNormal];
	
	[activeRequests addObject:identifierKey];
	[queue addOperation:readOp];
}

// NIPhotoAlbumScrollViewDataSource
- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
	return subReddit.photosArray.count;
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
	PhotoView *photoView = nil;
	NSString *reuseIdentifier = @"PHOTO_VIEW";
	photoView = (PhotoView *)[pagingScrollView dequeueReusablePageWithIdentifier:reuseIdentifier];
	if (nil == photoView) {
		photoView = [[PhotoView alloc] init];
		photoView.reuseIdentifier = reuseIdentifier;
		photoView.zoomingAboveOriginalSizeIsEnabled = YES;
	}
	
	photoView.photoScrollViewDelegate = self.photoAlbumView;
	
	return photoView;
}

- (UIImage *)photoAlbumScrollView:(NIPhotoAlbumScrollView *)photoAlbumScrollView
					 photoAtIndex:(NSInteger)photoIndex
						photoSize:(NIPhotoScrollViewPhotoSize *)photoSize
						isLoading:(BOOL *)isLoading
		  originalPhotoDimensions:(CGSize *)originalPhotoDimensions {
	
	if (photoIndex >= subReddit.photosArray.count)
		return nil;
	
	UIImage *image = nil;
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:photoIndex];
	
	[self requestImageFromSource:photo.urlString photoSize:NIPhotoScrollViewPhotoSizeOriginal photoIndex:photoIndex];
	
	*isLoading = YES;
	
	return image;
}

- (void)photoAlbumScrollView:(NIPhotoAlbumScrollView *)photoAlbumScrollView stopLoadingPhotoAtIndex:(NSInteger)photoIndex {
	for (ASIHTTPRequest *op in [queue operations]) {
		if (op.tag == photoIndex) {
			[op cancel];
			NSNumber *identifierKey = [NSNumber numberWithInteger:photoIndex];
			[activeRequests removeObject:identifierKey];
		}
	}
}

- (void)pagingScrollViewDidChangePages:(NIPhotoAlbumScrollView *)photoAlbumScrollView {
	if (self.photoAlbumView.centerPageIndex >= subReddit.photosArray.count)
		return;
	
	[super pagingScrollViewDidChangePages:photoAlbumScrollView];
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	[self setTitleLabelText:photo.titleString];
	
	if (sharing && self.photoAlbumView.centerPageIndex != sharingIndex) {
		sharing = NO;
	}

	fullPhotoButton.enabled = NO;

	[self requestImageFromSource:photo.urlString photoSize:NIPhotoScrollViewPhotoSizeOriginal photoIndex:self.photoAlbumView.centerPageIndex];
	
	if (!bFavorites) {
		if ([appDelegate isFavorite:photo]) {
			self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteRedItem, actionItem, commentItem, nil];
		}
		else {
			self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteWhiteItem, actionItem, commentItem, nil];
		}
	}
}

- (void)shareImage:(UIImage *)image {
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:sharingIndex];
	
	NSArray *activityItems = @[image, photo.titleString, [NSURL URLWithString:[NSString stringWithFormat:@"http://redd.it/%@", photo.idString]]];
	NSArray *applicationActivities = nil;
	NSArray *excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList];
	
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
	activityViewController.excludedActivityTypes = excludedActivityTypes;
	
	sharePopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
	sharePopoverController.delegate = self;
	[sharePopoverController presentPopoverFromBarButtonItem:actionItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	sharing = NO;
}

// UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	if (popoverController == sharePopoverController) {
		sharePopoverController = nil;
	}
}

- (IBAction)onFavoriteButton:(id)sender {
	if (favoriteActionSheet) {
		[favoriteActionSheet dismissWithClickedButtonIndex:favoriteActionSheet.cancelButtonIndex animated:YES];
		favoriteActionSheet = nil;
	}
	
	if (sharePopoverController) {
		[sharePopoverController dismissPopoverAnimated:YES];
		sharePopoverController = nil;
	}
	
	if (bFavorites) {
		favoriteActionSheet = [[UIActionSheet alloc] initWithTitle:nil
														  delegate:self
												 cancelButtonTitle:@"Cancel"
											destructiveButtonTitle:@"Remove from Favorites"
												 otherButtonTitles:nil];
		favoriteActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		favoriteActionSheet.tag = 101;
		[favoriteActionSheet showFromBarButtonItem:favoriteRedItem animated:YES];
	}
	else {
		PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
		if ([appDelegate isFavorite:photo]) {
			if ([appDelegate removeFromFavorites:photo]) {
				self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteWhiteItem, actionItem, commentItem, nil];
			}
		}
		else {
			if ([appDelegate addToFavorites:photo]) {
				self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favoriteRedItem, actionItem, commentItem, nil];
			}
		}
	}
}

- (IBAction)onPrevPhotoButton:(id)sender {
	[self.photoAlbumView moveToPreviousAnimated:self.animateMovingToNextAndPreviousPhotos];
}

- (IBAction)onNextPhotoButton:(id)sender {
	[self.photoAlbumView moveToNextAnimated:self.animateMovingToNextAndPreviousPhotos];
}

- (IBAction)onCommentButton:(id)sender {
	if (favoriteActionSheet) {
		[favoriteActionSheet dismissWithClickedButtonIndex:favoriteActionSheet.cancelButtonIndex animated:YES];
		favoriteActionSheet = nil;
	}
	
	if (sharePopoverController) {
		[sharePopoverController dismissPopoverAnimated:YES];
		sharePopoverController = nil;
	}
	
	disappearForSubview = YES;
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	CommentViewControllerPad *commentViewController = [[CommentViewControllerPad alloc] initWithNibName:@"CommentViewControllerPad" bundle:nil];
	commentViewController.urlString = photo.permalinkString;
	UINavigationController *commentNavigationController = [[UINavigationController alloc] initWithRootViewController:commentViewController];
	[self presentViewController:commentNavigationController animated:YES completion:nil];
}

- (IBAction)onFullPhotoButton:(id)sender {
	NSInteger identifier = self.photoAlbumView.centerPageIndex;
	NSNumber *identifierKey = [NSNumber numberWithInteger:identifier];
	[activeRequests removeObject:identifierKey];
	
	PhotoItem *photo = [subReddit.photosArray objectAtIndex:self.photoAlbumView.centerPageIndex];
	[appDelegate addToFullImagesSet:photo.urlString];
	fullPhotoButton.enabled = NO;
	[self.photoAlbumView reloadData];
}

@end
