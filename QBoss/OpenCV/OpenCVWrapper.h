#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (UIImage *)processImage:(UIImage *)inputImage isVertical:(BOOL)isVertical;
+ (UIImage *)processImages:(NSArray<UIImage *> *)inputImages isVertical:(BOOL)isVertical;

@end

NS_ASSUME_NONNULL_END
