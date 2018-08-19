import UIKit

class UploadManager: NSObject, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    var buffer: Data?
    var uploadProgressHandler: ((Float) -> ())?
    var completionHandler: ((Data, Int?, Error?) -> ())?
    
    func executeTask(_ task: URLSessionUploadTask, uploadProgressHandler: ((Float) -> ())? = nil,
                     completionHandler: ((Data, Int?, Error?) -> ())? = nil) {
        
        if buffer == nil {
            buffer = Data()
        } else {
            buffer!.removeAll()
        }
        
//        task.taskIdentifier
        
        self.uploadProgressHandler = uploadProgressHandler
        self.completionHandler = completionHandler
        
        task.resume()
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress: Float = Float(bytesSent) / Float(totalBytesExpectedToSend)
        uploadProgressHandler?(uploadProgress)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer?.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let theResponse = task.response else {
            completionHandler?(buffer!, nil, error)
            return
        }
        
        let responseCode = (theResponse as! HTTPURLResponse).statusCode
        completionHandler?(buffer!, responseCode, error)
    }
    
}
