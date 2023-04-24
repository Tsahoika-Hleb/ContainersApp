#include <opencv2/opencv.hpp>
#include <opencv2/core.hpp>
#include <opencv2/core/cuda.hpp>
#include <opencv2/imgcodecs/ios.h>
#include "OpenCVWrapper.h"

using namespace cv;
using namespace std;

Mat resizeImageToFixedHeight(Mat inputImage, int fixedHeight) {
    float aspectRatio = static_cast<float>(inputImage.cols) / static_cast<float>(inputImage.rows);
    int resizedWidth = static_cast<int>(aspectRatio * fixedHeight);
    cv::Size newSize(resizedWidth, fixedHeight);
    Mat resizedImage;
    cv::resize(inputImage, resizedImage, newSize);
    return resizedImage;
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

Mat applyGaussianBlur(Mat inputImage, int kernelSize) {
    Mat blurredMat;
    GaussianBlur(inputImage, blurredMat, cv::Size(kernelSize, kernelSize), 0);
    return blurredMat;
}

Mat applyErosion(Mat inputImage, int kernelSize) {
    Mat erodedMat;
    Mat kernel = getStructuringElement(MORPH_RECT, cv::Size(kernelSize, kernelSize));
    erode(inputImage, erodedMat, kernel, cv::Point(-1, -1), 1);
    return erodedMat;
}

Mat preprocessImage(Mat inputImage) {
    Mat grayMat;
    cvtColor(inputImage, grayMat, COLOR_BGR2GRAY);
    
    // Resize the image to a fixed height while maintaining the aspect ratio
    int fixedHeight = 600;
    Mat resizedGrayMat = resizeImageToFixedHeight(grayMat, fixedHeight);
    
    // Increase the brightness of the image
    double alpha = 1.2; // Contrast control (1.0 - 3.0)
    int beta = 30; // Brightness control (0 - 100)
    Mat brightMat = increaseBrightness(resizedGrayMat, alpha, beta);
    
    // Apply Gaussian blur
    int blurKernelSize = 5;
    Mat blurredMat = applyGaussianBlur(brightMat, blurKernelSize);
    
    // Binarize the image
    Mat binaryMat = binarizeImage(blurredMat);
    
    // Apply erosion to thin out the letters
    int erosionKernelSize = 1;
    Mat erodedMat = applyErosion(binaryMat, erosionKernelSize);
    
    // Apply dilation to better preserve the structure of the characters
    Mat dilatedMat;
    Mat dilationKernel = getStructuringElement(MORPH_RECT, cv::Size(2, 2));
    dilate(erodedMat, dilatedMat, dilationKernel);
    
    // Apply morphological operations to remove small noise
    // and connect broken characters
    Mat morphedMat;
    Mat kernel = getStructuringElement(MORPH_RECT, cv::Size(3, 3)); morphologyEx(dilatedMat, morphedMat, MORPH_CLOSE, kernel);
    
    // Check if the text is black on white
    Scalar avgPixelIntensity = mean(morphedMat);
    if (avgPixelIntensity[0] > 200) {
        // Invert the image
        Mat invertedMat;
        bitwise_not(morphedMat, invertedMat);
        return invertedMat;
    } else {
        return morphedMat;
    }
}

vector<vector<cv::Point>> findContoursAndHull(Mat dilatedMask) {
    vector<vector<cv::Point>> contours;
    findContours(dilatedMask, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    vector<vector<cv::Point>> mContours;
    for (size_t i = 0; i < contours.size(); i++) {
        cv::Rect rect = boundingRect(contours[i]);
        float aspectRatio = static_cast<float>(rect.width) / rect.height;
        
        // Filter out contours with small areas or extreme aspect ratios
        if (contourArea(contours[i]) > 50 && aspectRatio < 5.0 && aspectRatio > 0.2) {
            vector<cv::Point> tmp;
            convexHull(contours[i], tmp, true);
            mContours.push_back(tmp);
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

bool compareContourRects(const cv::Rect &a, const cv::Rect &b) {
    cv::Point a_center = a.tl() + cv::Point(a.width / 2, a.height / 2);
    cv::Point b_center = b.tl() + cv::Point(b.width / 2, b.height / 2);
    
    if (abs(a_center.y - b_center.y) <= 20) {
        return a_center.x > b_center.x;
    }
    return a_center.y > b_center.y;
}

vector<Mat> extractSymbols(Mat grayMat, vector<vector<cv::Point>> mContours, cv::Size standardSize, int padding) {
    vector<cv::Rect> sortedRects;
    for (size_t i = 0; i < mContours.size(); i++) {
        sortedRects.push_back(boundingRect(mContours[i]));
    }
    
    sort(sortedRects.begin(), sortedRects.end(), compareContourRects);
    
    vector<Mat> symbols;
    for (const auto &rect : sortedRects) {
        cv::Rect adjustedRect;
        adjustedRect.x = max(rect.x - padding, 0);
        adjustedRect.y = max(rect.y - padding, 0);
        adjustedRect.width = min(rect.width + padding * 2, grayMat.cols - rect.x);
        adjustedRect.height = min(rect.height + padding * 2, grayMat.rows - rect.y);
        Mat tmp = grayMat(adjustedRect).clone();
        if (tmp.empty()) { continue; }
        
        Mat resizedSymbol;
        resize(tmp, resizedSymbol, standardSize);
        
        // Perform a final thresholding step to make the resized symbols binary
        Mat binarySymbol;
        threshold(resizedSymbol, binarySymbol, 0, 255, THRESH_BINARY_INV | THRESH_OTSU);
        symbols.push_back(binarySymbol);
    }
    return symbols;
}

// Function to extract symbols from an array of images and concatenate them horizontally or vertically
Mat getCombinedImage(vector<Mat> inputImages) {
    cv::Size standardSize(64, 96);
    vector<Mat> allSymbols;
    for (Mat inputImage : inputImages) {
        Mat dst = preprocessImage(inputImage);
        vector<vector<cv::Point>> mContours = findContoursAndHull(dst);
        vector<Mat> symbols = extractSymbols(dst, mContours, standardSize, 3);
        allSymbols.insert(allSymbols.end(), symbols.begin(), symbols.end());
    }
    Mat combinedImage = combineSpacedBoxes(allSymbols);
    return combinedImage;
}

// Process single image
std::optional<UIImage *> processImage(UIImage *inputImage) {
    if (inputImage.size.width == 0 || inputImage.size.height == 0) { return std::nullopt;
    }
    cv::Mat mat;
    UIImageToMat(inputImage, mat);
    Mat combinedImage = getCombinedImage(vector<Mat>{mat});
    UIImage* outputImage = MatToUIImage(combinedImage);
    return outputImage;
}

void resizeImages(std::vector<cv::Mat>& allMats, NSArray<UIImage*>* inputImages, bool isVertical) {
    int maxDimension = 0;
    
    // Find the max dimension (width for vertical or height for horizontal)
    for (UIImage* inputImage: inputImages) {
        cv::Mat matImage;
        UIImageToMat(inputImage, matImage);
        maxDimension = std::max(maxDimension, isVertical ? matImage.cols : matImage.rows);
    }
    
    // Resize the images while maintaining the aspect ratio
    for (UIImage* inputImage: inputImages) {
        cv::Mat matImage, resizedMatImage;
        UIImageToMat(inputImage, matImage);
        
        float aspectRatio = isVertical
        ? static_cast<float>(matImage.rows) / static_cast<float>(matImage.cols)
        : static_cast<float>(matImage.cols) / static_cast<float>(matImage.rows);
        
        int newDimension = static_cast<int>(aspectRatio * maxDimension);
        cv::Size newSize = isVertical ? cv::Size(maxDimension, newDimension) : cv::Size(newDimension, maxDimension);
        
        cv::resize(matImage, resizedMatImage, newSize);
        allMats.push_back(resizedMatImage);
    }
}

std::optional<UIImage*> processImages(NSArray<UIImage*>* inputImages, bool isVertical) {
    if (inputImages.count == 0) { return std::nullopt; }
    
    // create a vector to store Mat images for all input images
    std::vector<cv::Mat> allMats;
    
    resizeImages(allMats, inputImages, isVertical);
    
    // concatenate all images into a single image
    cv::Mat combinedImage;
    if (isVertical) {
        cv::vconcat(allMats, combinedImage);
    } else {
        cv::hconcat(allMats, combinedImage);
    }
    UIImage *concatenatedImage = MatToUIImage(combinedImage);
    // process the concatenated image
    std::optional<UIImage*> outputImage = processImage(concatenatedImage);
    return outputImage;
}

@implementation OpenCVWrapper
+ (UIImage *_Nullable)processImage:(UIImage *)inputImage {
    std::optional<UIImage *> outputImage = processImage(inputImage);
    return outputImage ? *outputImage : nil;
}

+ (UIImage* _Nullable)processImages:(NSArray<UIImage*>*)inputImages isVerticalText:(BOOL)isVertical {
    std::optional<UIImage*> outputImage = processImages(inputImages, isVertical);
    return outputImage ? *outputImage : nil;
}
@end
