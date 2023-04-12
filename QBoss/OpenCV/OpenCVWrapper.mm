#include <opencv2/opencv.hpp>
#include <opencv2/core.hpp>
#include <opencv2/core/cuda.hpp>
#include <opencv2/imgcodecs/ios.h>
#include "OpenCVWrapper.h"

using namespace cv;
using namespace std;

int calculateThrash(Mat dst) {
    int total = dst.rows * dst.cols;
    vector<int> mGrayMatList;
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

Mat createDilatedMask(Mat dst, int thrash) {
    int i1 = static_cast<int>(thrash / 1.2);
    
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

Mat increaseBrightness(Mat inputImage, double alpha, int beta) {
    Mat brightMat;
    convertScaleAbs(inputImage, brightMat, alpha, beta);
    return brightMat;
}

Mat binarizeImage(Mat inputImage) {
    Mat binaryMat;
    threshold(inputImage, binaryMat, 0, 255, THRESH_BINARY_INV | THRESH_OTSU);
    return binaryMat;
}

Mat preprocessImage(Mat inputImage) {
    Mat grayMat;
    cvtColor(inputImage, grayMat, COLOR_BGR2GRAY);
    
    // Increase the brightness of the image
    double alpha = 1; // Contrast control (1.0 - 3.0)
    int beta = 30; // Brightness control (0 - 100)
    Mat brightMat = increaseBrightness(grayMat, alpha, beta);
    
    // Binarize the image
    Mat binaryMat = binarizeImage(brightMat);
    
    // Check if the text is black on white
    Scalar avgPixelIntensity = mean(binaryMat);
    if (avgPixelIntensity[0] > 128) {
        
        // Invert the image
        Mat invertedMat; bitwise_not(binaryMat, invertedMat);
        return invertedMat;
    } else {
        return binaryMat;
    }
}

vector<vector<cv::Point>> findContoursAndHull(Mat dilatedMask) {
    vector<vector<cv::Point>> contours;
    findContours(dilatedMask, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    vector<vector<cv::Point>> mContours;
    for (size_t i = 0; i < contours.size(); i++) {
        if (contourArea(contours[i]) > 50) {
            cv::Rect rect = boundingRect(contours[i]);
            float aspectRatio = static_cast<float>(rect.width) / rect.height;
            
            // Filter out contours with aspect ratios that are too high or too low
            if (aspectRatio < 5.0 && aspectRatio > 0.2) {
                vector<cv::Point> tmp;
                convexHull(contours[i], tmp, true);
                mContours.push_back(tmp);
            }
        }
    }
    return mContours;
}

Mat combineSpacedBoxes(vector<Mat> spacedBoxes) {
    reverse(spacedBoxes.begin(), spacedBoxes.end());
    Mat horizontalImage;
    hconcat(spacedBoxes, horizontalImage);
    return horizontalImage;
}

vector<Mat> extractSymbols(Mat grayMat, vector<vector<cv::Point>> mContours, cv::Size standardSize, int padding) {
    vector<Mat> symbols;
    for (size_t i = 0; i < mContours.size(); i++) {
        cv::Rect rect = boundingRect(mContours[i]);
        rect.x = max(rect.x - padding, 0);
        rect.y = max(rect.y - padding, 0);
        rect.width = min(rect.width + padding * 2, grayMat.cols - rect.x);
        rect.height = min(rect.height + padding * 2, grayMat.rows - rect.y);
        Mat tmp = grayMat(rect).clone();
        if (tmp.empty()) {
            continue;
        }
        Mat resizedSymbol;
        resize(tmp, resizedSymbol, standardSize);
        symbols.push_back(resizedSymbol);
    }
    return symbols;
}

// Function to extract symbols from an array of images and concatenate them horizontally or vertically
Mat getCombinedImage(vector<Mat> inputImages) {
    cv::Size standardSize(80, 100);
    vector<Mat> allSymbols;
    for (Mat inputImage : inputImages) {
        Mat dst = preprocessImage(inputImage);
        vector<vector<cv::Point>> mContours = findContoursAndHull(dst);
        vector<Mat> symbols = extractSymbols(dst, mContours, standardSize, 2);
        allSymbols.insert(allSymbols.end(), symbols.begin(), symbols.end());
    }
    Mat combinedImage = combineSpacedBoxes(allSymbols);
    return combinedImage;
}

// Process single image
std::optional<UIImage*> processImage(UIImage* inputImage) {
    if (inputImage.size.width == 0 || inputImage.size.height == 0) {
        return std::nullopt;
    }
    cv::Mat mat;
    UIImageToMat(inputImage, mat);
    Mat combinedImage = getCombinedImage(vector<Mat>{mat});
    UIImage* outputImage = MatToUIImage(combinedImage);
    return outputImage;
}

// Process multiple images
std::optional<UIImage*> processImages(NSArray<UIImage*>* inputImages) {
    if (inputImages.count == 0) {
        return std::nullopt;
    }
    vector<Mat> mats;
    for (UIImage* inputImage: inputImages) {
        if (inputImage.size.width == 0 || inputImage.size.height == 0) {
            return std::nullopt;
        }
        cv::Mat mat; UIImageToMat(inputImage, mat); mats.push_back(mat);
    }
    Mat combinedImage = getCombinedImage(mats);
    UIImage* outputImage = MatToUIImage(combinedImage);
    return outputImage;
}

@implementation OpenCVWrapper

+(UIImage* _Nullable)processImage:(UIImage*)inputImage {
    std::optional<UIImage*> outputImage = processImage(inputImage);
    return outputImage ? *outputImage : nil;
}

+(UIImage* _Nullable)processImages:(NSArray<UIImage*>*)inputImages {
    std::optional<UIImage*> outputImage = processImages(inputImages);
    return outputImage ? *outputImage : nil;
}

@end
