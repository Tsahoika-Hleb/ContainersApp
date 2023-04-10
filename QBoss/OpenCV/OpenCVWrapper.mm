#include <opencv2/opencv.hpp>
#include <opencv2/core.hpp>
#include <opencv2/core/cuda.hpp>
#include <opencv2/imgcodecs/ios.h>
#include "OpenCVWrapper.h"

using namespace cv;
using namespace std;

int calculateThrash(Mat dst) {
    int total = dst.rows * dst.cols; vector<int> mGrayMatList;
    for (int col = 0; col < dst.cols; col++) {
        for (int row = 0; row < dst.rows; row++) {
            mGrayMatList.push_back(static_cast<int>(dst.at<uchar>(row, col)));
        }
    }
    sort(mGrayMatList.begin(), mGrayMatList.end());
    int thrash = mGrayMatList[static_cast<int>(0.035 * total)];
    if (thrash % 2 == 0) {
        thrash++;
    }
    return thrash;
}

Mat createDilatedMask(Mat dst, int thrash) { int i1 = static_cast<int>(thrash / 1.2);
    // Ensure that thrash is an odd number greater than 1
    if (thrash <= 1) {
        thrash = 3;
    } else if (thrash % 2 == 0) {
        thrash++;
    }
    Mat dilatedMask;
    adaptiveThreshold(dst, dilatedMask, 255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY_INV, thrash, i1 - 2);
    return dilatedMask;
}

Mat increaseBrightness(Mat inputImage, double alpha, int beta) { Mat brightMat;
    convertScaleAbs(inputImage, brightMat, alpha, beta);
    return brightMat;
}

Mat binarizeImage(Mat inputImage) { Mat binaryMat;
    threshold(inputImage, binaryMat, 0, 255, THRESH_BINARY_INV | THRESH_OTSU);
    return binaryMat;
}

Mat preprocessImage(Mat inputImage) { Mat grayMat;
    cvtColor(inputImage, grayMat, COLOR_BGR2GRAY);
    // Calculate the average pixel intensity
    Scalar avgPixelIntensity = mean(grayMat);
    // Increase the brightness of the image
    double alpha = 1.0; // Contrast control (1.0 - 3.0)
    int beta = 40; // Brightness control (0 - 100)
    Mat brightMat = increaseBrightness(grayMat, alpha, beta);
    if (avgPixelIntensity[0] > 128) {
        // Apply Otsu's binarization method
        Mat binaryMat = binarizeImage(brightMat);
        return binaryMat;
    } else {
        Mat dst;
        bitwise_not(brightMat, dst);
        Mat binaryMat = binarizeImage(dst);
        return binaryMat;
    }
}

vector<vector<cv::Point>> findContoursAndHull(Mat dilatedMask) { vector<vector<cv::Point>> contours;
    findContours(dilatedMask, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    vector<vector<cv::Point>> mContours;
    for (size_t i = 0; i < contours.size(); i++) {
        if (contourArea(contours[i]) > 50) {
            cv::Rect rect = boundingRect(contours[i]);
            float aspectRatio = static_cast<float>(rect.width) / rect.height;
            // Filter out contours with aspect ratios that are too high or too low
            if (aspectRatio < 5.0 && aspectRatio > 0.2) {
                vector<cv::Point> tmp; convexHull(contours[i], tmp, true); mContours.push_back(tmp);
            }
        }
    }
    return mContours;
}

Mat combineSpacedBoxes(vector<Mat> spacedBoxes, bool isVertical) {
    if (isVertical) {
        reverse(spacedBoxes.begin(), spacedBoxes.end());
    }
    Mat horizontalImage;
    hconcat(spacedBoxes, horizontalImage);
    return horizontalImage;
}

vector<Mat> extractSymbols(Mat grayMat, vector<vector<cv::Point>> mContours, cv::Size maxSize, int padding) {
    vector<Mat> symbols; float scalingFactor = 0.8;
    for (size_t i = 0; i < mContours.size(); i++) {
        cv::Rect rect = boundingRect(mContours[i]);
        rect.x = max(rect.x - padding, 0);
        rect.y = max(rect.y - padding, 0);
        rect.width = min(rect.width + padding * 2, grayMat.cols - rect.x); rect.height = min(rect.height + padding * 2, grayMat.rows - rect.y); Mat tmp = grayMat(rect).clone();
        if (tmp.empty()) {
            continue;
        }
        // Calculate new dimensions while preserving the aspect ratio
        float aspectRatio = static_cast<float>(tmp.cols) / tmp.rows; int newWidth, newHeight;
        if (tmp.cols >= tmp.rows) {
            newWidth = maxSize.width;
            newHeight = static_cast<int>(newWidth / aspectRatio);
        } else {
            newHeight = maxSize.height;
            newWidth = static_cast<int>(newHeight * aspectRatio);
        }
        // Apply scaling factor to height
        newHeight = static_cast<int>(newHeight * scalingFactor); cv::Size newSize(newWidth, newHeight);
        
        Mat resizedSymbol;
        resize(tmp, resizedSymbol, newSize);
        
        // Add padding to make all symbols have the same height
        int top = (maxSize.height - resizedSymbol.rows) / 2;
        int bottom = maxSize.height - resizedSymbol.rows - top;
        copyMakeBorder(resizedSymbol, resizedSymbol, top, bottom, 0, 0, BORDER_CONSTANT, Scalar(0));
        
        symbols.push_back(resizedSymbol);
    }
    return symbols;
}

// Function to extract symbols from an array of images and concatenate them horizontally or vertically
Mat getCombinedImage(vector<Mat> inputImages, bool isVertical) {
    cv::Size standardSize(50, 60); vector<Mat> allSymbols;
    for (Mat inputImage : inputImages) {
        Mat dst = preprocessImage(inputImage);
        vector<vector<cv::Point>> mContours = findContoursAndHull(dst); vector<Mat> symbols = extractSymbols(dst, mContours, standardSize, 2); allSymbols.insert(allSymbols.end(), symbols.begin(), symbols.end());
    }
    Mat combinedImage = combineSpacedBoxes(allSymbols, isVertical); return combinedImage;
}

// Process single image
UIImage* processImage(UIImage* inputImage, bool isVertical) {
    cv::Mat mat;
    UIImageToMat(inputImage, mat);
    Mat combinedImage = getCombinedImage(vector<Mat>{mat}, isVertical); UIImage* outputImage = MatToUIImage(combinedImage);
    return outputImage;
}

// Process multiple images
UIImage* processImages(NSArray<UIImage*>* inputImages, bool isVertical) {
    vector<Mat> mats;
    for (UIImage* inputImage: inputImages) {
        cv::Mat mat; UIImageToMat(inputImage, mat); mats.push_back(mat);
    }
    Mat combinedImage = getCombinedImage(mats, isVertical); UIImage* outputImage = MatToUIImage(combinedImage);
    return outputImage;
}

@implementation OpenCVWrapper

+(UIImage*)processImage:(UIImage*)inputImage isVertical:(BOOL)isVertical { UIImage* outputImage = processImage(inputImage, isVertical);
    return outputImage;
}
+(UIImage*)processImages:(NSArray<UIImage*>*)inputImages isVertical:(BOOL)isVertical { UIImage* outputImage = processImages(inputImages, isVertical);
    return outputImage;
}
@end
