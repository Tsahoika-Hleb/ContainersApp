//#import <UIKit/UIKit.h>
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface OpenCVWrapper : NSObject
//
//+ (UIImage *)processImage:(UIImage *)inputImage isVertical:(BOOL)isVertical;
//+ (UIImage *)processImages:(NSArray<UIImage *> *)inputImages isVertical:(BOOL)isVertical;
//
//@end
//
//NS_ASSUME_NONNULL_END

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+(UIImage* _Nullable)processImage:(UIImage*)inputImage;
+(UIImage* _Nullable)processImages:(NSArray<UIImage*>*)inputImages;

@end

NS_ASSUME_NONNULL_END
