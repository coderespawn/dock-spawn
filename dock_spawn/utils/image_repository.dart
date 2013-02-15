part of dock_spawn;

/**
 * Downloads and caches all the images used by the application during startup.
 * Images can be queried through a user-friendly name rather than a URL
 */
class ImageRepository {
  Map<String, ImageElement> images;
  
  ImageRepository() {
    images = new Map<String, ImageElement>();
  }
  
  /**
   * Initiates the download of the images.  The function returns immediately.
   */
  Future downloadImage(String name, String url) {
    var completer = new Completer();
    ImageElement image = new ImageElement();
    image.src = url;
    image.on.load.add((e) {
      completer.complete(image);
    });
    return completer.future;
  }
  
  /**
   * Specify multiple images to be downloaded in the following format
   * [ "name1", "url1", "name2", "url2", ... "urlN", "nameN" ]
   */
  Future downloadImages(List<String> imageList) {
    var futures = [];
    for (int i = 0; i < imageList.length; i += 2) {
      String name = imageList[i];
      String url = imageList[i + 1];
      futures.add(downloadImage(name, url));
    }
    
    // Wait for all the images to download
    return Future.wait(futures);
  }

}
