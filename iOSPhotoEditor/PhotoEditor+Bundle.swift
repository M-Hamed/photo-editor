import Foundation

extension Bundle {
    public static var iOSPhotoEditorResourceBundle: Bundle? {
        guard let resourceUrl = Bundle(for: PhotoEditorViewController.self).url(forResource: "iOSPhotoEditor", withExtension: "bundle") 
                else { return nil }
        return Bundle(url: resourceUrl)
    }
}


