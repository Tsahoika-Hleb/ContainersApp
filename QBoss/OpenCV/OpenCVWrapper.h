#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (UIImage *_Nullable)processImage:(UIImage *)inputImage;
+ (UIImage* _Nullable)processImages:(NSArray<UIImage*>*)inputImages isVerticalText:(BOOL)isVertical;

@end

NS_ASSUME_NONNULL_END
