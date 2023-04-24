// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum S {
  internal enum AlertAction {
    /// Cancel
    internal static let cancel = S.tr("Localizable", "AlertAction.cancel", fallback: "Cancel")
    /// OK
    internal static let ok = S.tr("Localizable", "AlertAction.ok", fallback: "OK")
    /// Settings
    internal static let settings = S.tr("Localizable", "AlertAction.settings", fallback: "Settings")
  }
  internal enum Screens {
    internal enum ContainerList {
      /// All
      internal static let allFilterButtonTitle = S.tr("Localizable", "Screens.ContainerList.allFilterButtonTitle", fallback: "All")
      /// Scanned Containers
      internal static let navigationTitle = S.tr("Localizable", "Screens.ContainerList.navigationTitle", fallback: "Scanned Containers")
      /// Not Identified
      internal static let notIdentifiedButtonTitle = S.tr("Localizable", "Screens.ContainerList.notIdentifiedButtonTitle", fallback: "Not Identified")
      /// Not Send
      internal static let notSendButtonTitle = S.tr("Localizable", "Screens.ContainerList.notSendButtonTitle", fallback: "Not Send")
      /// Send to server
      internal static let rightSwipeActionTitle = S.tr("Localizable", "Screens.ContainerList.rightSwipeActionTitle", fallback: "Send to server")
      /// START SCANNING
      internal static let scanButtonTitle = S.tr("Localizable", "Screens.ContainerList.scanButtonTitle", fallback: "START SCANNING")
      /// Please enter a valid URL.
      internal static let textFieldAlertPlaceholder = S.tr("Localizable", "Screens.ContainerList.textFieldAlertPlaceholder", fallback: "Please enter a valid URL.")
      /// Enter a valid URL
      internal static let textFieldDefaultPlaceholder = S.tr("Localizable", "Screens.ContainerList.textFieldDefaultPlaceholder", fallback: "Enter a valid URL")
    }
    internal enum EndpointsList {
      /// Delete
      internal static let deleteSwipeActionTitle = S.tr("Localizable", "Screens.EndpointsList.deleteSwipeActionTitle", fallback: "Delete")
    }
    internal enum Scan {
      internal enum CameraPermissionDenied {
        /// Camera permissions have been denied for this app. You can change this by going to Settings
        internal static let allertMessage = S.tr("Localizable", "Screens.Scan.CameraPermissionDenied.allertMessage", fallback: "Camera permissions have been denied for this app. You can change this by going to Settings")
        /// Camera Permissions Denied
        internal static let allertTitle = S.tr("Localizable", "Screens.Scan.CameraPermissionDenied.allertTitle", fallback: "Camera Permissions Denied")
      }
      internal enum LocationPermissionDenied {
        /// Location permissions have been denied for this app. You can change this by going to Settings
        internal static let allertMessage = S.tr("Localizable", "Screens.Scan.LocationPermissionDenied.allertMessage", fallback: "Location permissions have been denied for this app. You can change this by going to Settings")
        /// Location Permissions Denied
        internal static let allertTitle = S.tr("Localizable", "Screens.Scan.LocationPermissionDenied.allertTitle", fallback: "Location Permissions Denied")
      }
      internal enum PresentVideoError {
        /// Configuration of camera has failed
        internal static let allertMessage = S.tr("Localizable", "Screens.Scan.PresentVideoError.allertMessage", fallback: "Configuration of camera has failed")
        /// Configuration Failed
        internal static let allertTitle = S.tr("Localizable", "Screens.Scan.PresentVideoError.allertTitle", fallback: "Configuration Failed")
      }
    }
    internal enum Views {
      internal enum ScannedContainerCell {
        /// isIdentified:
        internal static let isIdentifiedLabel = S.tr("Localizable", "Screens.Views.ScannedContainerCell.isIdentifiedLabel", fallback: "isIdentified:")
        /// lat: 
        internal static let latitudeLabel = S.tr("Localizable", "Screens.Views.ScannedContainerCell.latitudeLabel", fallback: "lat: ")
        /// lon: 
        internal static let longitudeLabel = S.tr("Localizable", "Screens.Views.ScannedContainerCell.longitudeLabel", fallback: "lon: ")
        /// sent to server:
        internal static let sentToServerLabel = S.tr("Localizable", "Screens.Views.ScannedContainerCell.sentToServerLabel", fallback: "sent to server:")
      }
    }
    internal enum Welcome {
      /// Please enable camera and location permissions in the app settings.
      internal static let allertMessage = S.tr("Localizable", "Screens.Welcome.allertMessage", fallback: "Please enable camera and location permissions in the app settings.")
      /// Permissions Required
      internal static let allertTitle = S.tr("Localizable", "Screens.Welcome.allertTitle", fallback: "Permissions Required")
      /// CONTAINERS
      internal static let containersButtonTitle = S.tr("Localizable", "Screens.Welcome.containersButtonTitle", fallback: "CONTAINERS")
      /// Enter a URL endpoint where scans be sent
      internal static let instructionsLabelText = S.tr("Localizable", "Screens.Welcome.instructionsLabelText", fallback: "Enter a URL endpoint where scans be sent")
      /// SCAN
      internal static let scanButtonTitle = S.tr("Localizable", "Screens.Welcome.scanButtonTitle", fallback: "SCAN")
      /// This field must be filled with URL
      internal static let textFieldAlertPlaceholder = S.tr("Localizable", "Screens.Welcome.textFieldAlertPlaceholder", fallback: "This field must be filled with URL")
      /// Enter a valid URL
      internal static let textFieldDefaultPlaceholder = S.tr("Localizable", "Screens.Welcome.textFieldDefaultPlaceholder", fallback: "Enter a valid URL")
      /// Welcome to Containers App
      internal static let title = S.tr("Localizable", "Screens.Welcome.title", fallback: "Welcome to Containers App")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension S {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
