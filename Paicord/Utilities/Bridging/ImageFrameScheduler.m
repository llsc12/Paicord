//
//  ImageFrameScheduler.m
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/09/2025.
//
//  Many thanks to this blog post
// 	https://augmentedcode.io/2019/09/01/animating-gifs-and-apngs-with-cganimateimageaturlwithblock-in-swift/

#import "ImageFrameScheduler.h"
#import "ImageIO/CGImageAnimation.h" // Xcode 11 beta 7 - CGImageAnimation.h is not in umbrella header IOImage.h

@interface ImageFrameScheduler()
@property (readwrite) NSURL *imageURL;
@property (getter=isStopping) BOOL stopping;
@end

@implementation ImageFrameScheduler

- (instancetype)initWithURL:(NSURL *)imageURL {
		if (self = [super init]) {
				self.imageURL = imageURL;
		}
		return self;
}

- (BOOL)startWithFrameHandler:(void (^)(NSInteger, CGImageRef))handler {
		__weak ImageFrameScheduler *weakSelf = self;
		OSStatus status = CGAnimateImageAtURLWithBlock((CFURLRef)self.imageURL, nil, ^(size_t index, CGImageRef _Nonnull image, bool* _Nonnull stop) {
				handler(index, image);
				*stop = weakSelf.isStopping;
		});
		// See CGImageAnimationStatus for errors
		return status == noErr;
}

- (void)stop {
		self.stopping = YES;
}

@end
