//
//  ImageFrameScheduler.h
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/09/2025.
//
//  Many thanks to this blog post
// 	https://augmentedcode.io/2019/09/01/animating-gifs-and-apngs-with-cganimateimageaturlwithblock-in-swift/

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface ImageFrameScheduler: NSObject
- (instancetype)initWithURL:(NSURL *)imageURL;
@property (readonly) NSURL *imageURL;
- (BOOL)startWithFrameHandler:(void (^)(NSInteger, CGImageRef))handler;
- (void)stop;
@end
NS_ASSUME_NONNULL_END
