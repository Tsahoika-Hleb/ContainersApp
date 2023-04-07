#include <opencv2/opencv.hpp>
#include <opencv2/core.hpp>
#include <opencv2/core/cuda.hpp>
#include <opencv2/imgcodecs/ios.h>
#include "OpenCVWrapper.h"

using namespace cv;
using namespace std;

Mat preprocessImage(Mat inputImage) {
    Mat grayMat;
    cvtColor(inputImage, grayMat, COLOR_BGR2GRAY);
    Mat dst;
    bitwise_not(grayMat, dst);
    return dst;
}

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
        thrash--;
    }
    return thrash;
}

Mat createDilatedMask(Mat dst, int thrash) {
    int i1 = static_cast<int>(thrash / 1.2);
    Mat dilatedMask;
    adaptiveThreshold(dst, dilatedMask, 255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY_INV, thrash, i1);
    return dilatedMask;
}

vector<vector<cv::Point>> findContoursAndHull(Mat dilatedMask) {
    vector<vector<cv::Point>> contours;
    findContours(dilatedMask, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    vector<vector<cv::Point>> mContours;
    for (size_t i = 0; i < contours.size(); i++) {
        if (contourArea(contours[i]) > 50) {
            vector<cv::Point> tmp;
            convexHull(contours[i], tmp, true);

            mContours.push_back(tmp);
        }
    }
    return mContours;
}

vector<Mat> extractBoxes(Mat grayMat, vector<vector<cv::Point>> mContours) {
    vector<Mat> boxes;
    int padding = 5;
    for (size_t i = 0; i < mContours.size(); i++) {
        cv::Rect rect = boundingRect(mContours[i]);
        rect.x -= padding;
        rect.y -= padding;
        rect.width += 2 * padding;
        rect.height += 2 * padding;
        rect.x = max(rect.x, 0);
        rect.y = max(rect.y, 0);
        rect.width = min(rect.width, grayMat.cols - rect.x);
        rect.height = min(rect.height, grayMat.rows - rect.y);
        Mat tmp = grayMat(rect).clone();
        if (tmp.empty()) {
            continue;
        }
        boxes.push_back(tmp);
    }
    return boxes;
}

Mat combineSpacedBoxes(vector<Mat> spacedBoxes, bool isVertical) {
    if (isVertical) { reverse(spacedBoxes.begin(), spacedBoxes.end()); }
    Mat horizontalImage;
    hconcat(spacedBoxes, horizontalImage);
    return horizontalImage;
}

// Function to extract symbols from an image and resize them
vector<Mat> extractSymbols(Mat grayMat,
                           vector<vector<cv::Point>> mContours,
                           cv::Size standardSize) {
    vector<Mat> symbols;
    int padding = 3;
    for (size_t i = 0; i < mContours.size(); i++) {
        cv::Rect rect = boundingRect(mContours[i]);
        rect.x -= padding;
        rect.y -= padding;
        rect.width += 2 * padding;
        rect.height += 2 * padding;
        rect.x = max(rect.x, 0);
        rect.y = max(rect.y, 0);
        rect.width = min(rect.width, grayMat.cols - rect.x);
        rect.height = min(rect.height, grayMat.rows - rect.y);
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
Mat getCombinedImage(vector<Mat> inputImages, bool isVertical) {
    cv::Size standardSize(80, 80);
    vector<Mat> allSymbols;
    for (Mat inputImage : inputImages) {
        Mat dst = preprocessImage(inputImage);
        int thrash = calculateThrash(dst);
        Mat dilatedMask = createDilatedMask(dst, thrash);
        vector<vector<cv::Point>> mContours = findContoursAndHull(dilatedMask);
        vector<Mat> symbols = extractSymbols(dst, mContours, standardSize);
        allSymbols.insert(allSymbols.end(), symbols.begin(), symbols.end());
    }
    Mat combinedImage = combineSpacedBoxes(allSymbols, isVertical);
    return combinedImage;
}

// Process single image
UIImage* processImage(UIImage* inputImage, bool isVertical) {
    cv::Mat mat;
    UIImageToMat(inputImage, mat);
    Mat combinedImage = getCombinedImage(vector<Mat>{mat}, isVertical);
    UIImage* outputImage = MatToUIImage(combinedImage);
    return outputImage;
}

// Process multiple images
UIImage* processImages(NSArray<UIImage*>* inputImages, bool isVertical) {
    vector<Mat> mats;
    for (UIImage* inputImage: inputImages) {
        cv::Mat mat;
        UIImageToMat(inputImage, mat);
        mats.push_back(mat);
    }
    Mat combinedImage = getCombinedImage(mats, isVertical);
    UIImage* outputImage = MatToUIImage(combinedImage);
    return outputImage;

}

@implementation OpenCVWrapper

+(UIImage*)processImage:(UIImage*)inputImage isVertical:(BOOL)isVertical {
    UIImage* outputImage = processImage(inputImage, isVertical);
    return outputImage;
}

+(UIImage*)processImages:(NSArray<UIImage*>*)inputImages isVertical:(BOOL)isVertical {
    UIImage* outputImage = processImages(inputImages, isVertical);
    return outputImage;
}

@end
