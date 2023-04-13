#include <opencv2/opencv.hpp>
#include <opencv2/core.hpp>
#include <opencv2/core/cuda.hpp>
#include <opencv2/imgcodecs/ios.h>
#include "OpenCVWrapper.h"

using namespace cv;
using namespace std;

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

Mat applyMedianBlur(Mat inputImage, int kernelSize) {
    Mat blurredMat;
    medianBlur(inputImage, blurredMat, kernelSize);
    return blurredMat;
}

Mat applyErosionMultipleTimes(Mat inputImage, int kernelSize, int iterations) {
    Mat erodedMat;
    Mat kernel = getStructuringElement(MORPH_RECT, cv::Size(kernelSize, kernelSize));
    erode(inputImage, erodedMat, kernel, cv::Point(-1, -1), iterations);
    return erodedMat;
}

Mat preprocessImage(Mat inputImage) {
    Mat grayMat;
    cvtColor(inputImage, grayMat, COLOR_BGR2GRAY);
    
    // Increase the brightness of the image
    double alpha = 1.2; // Contrast control (1.0 - 3.0)
    int beta = 30; // Brightness control (0 - 100)
    Mat brightMat = increaseBrightness(grayMat, alpha, beta);
    
    // Apply Gaussian blur
    int blurKernelSize = 1;
    Mat blurredMat = applyGaussianBlur(brightMat, blurKernelSize);
    
    // Add median blur to reduce salt-and-pepper noise
    int medianBlurKernelSize = 3;
    Mat medianBlurredMat = applyMedianBlur(blurredMat, medianBlurKernelSize);
    
    // Binarize the image
    Mat binaryMat = binarizeImage(medianBlurredMat);
    
    // Apply erosion to thin out the letters
    int erosionKernelSize = 1;
    int erosionIterations = 3;
    Mat erodedMat = applyErosionMultipleTimes(binaryMat, erosionKernelSize, erosionIterations);
    
    // Apply dilation to better preserve the structure of the characters
    Mat dilatedMat;
    Mat dilationKernel = getStructuringElement(MORPH_RECT, cv::Size(2, 2)); dilate(erodedMat, dilatedMat, dilationKernel);
    
    // Apply morphological operations to remove small noise
    // and connect broken characters
    Mat morphedMat;
    Mat kernel = getStructuringElement(MORPH_RECT, cv::Size(3, 3)); morphologyEx(dilatedMat, morphedMat, MORPH_CLOSE, kernel);
    
    // Check if the text is black on white
    Scalar avgPixelIntensity = mean(morphedMat);
    if (avgPixelIntensity[0] > 200) {
        // Invert the image
        Mat invertedMat; bitwise_not(morphedMat, invertedMat); return invertedMat;
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
            vector<cv::Point> tmp; convexHull(contours[i], tmp, true); mContours.push_back(tmp);
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
std::optional<UIImage*> processImage(UIImage* inputImage) {
    if (inputImage.size.width == 0 || inputImage.size.height == 0) { return std::nullopt;
    }
    cv::Mat mat;
    UIImageToMat(inputImage, mat);
    Mat combinedImage = getCombinedImage(vector<Mat>{mat}); UIImage* outputImage = MatToUIImage(combinedImage); return outputImage;
}

// Process multiple images
std::optional<UIImage*> processImages(NSArray<UIImage*>* inputImages) {
    if (inputImages.count == 0) { return std::nullopt; }
    vector<Mat> mats;
    for (UIImage* inputImage: inputImages) {
        if (inputImage.size.width == 0 || inputImage.size.height == 0) { return std::nullopt; }
        cv::Mat mat; UIImageToMat(inputImage, mat); mats.push_back(mat);
    }
    Mat combinedImage = getCombinedImage(mats); UIImage* outputImage = MatToUIImage(combinedImage);
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
