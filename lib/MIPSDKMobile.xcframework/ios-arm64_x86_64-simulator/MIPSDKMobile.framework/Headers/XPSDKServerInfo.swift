import Foundation

/**
 Class that represents a server info, setup by the user, with its settings
 */
@objcMembers open class XPSDKServerInfo: NSObject {
    
    ///Server name or IP Address
    open var serverHost:String?
    ///Server port
    open var serverPort:NSNumber = 8081
    ///Flag set to YES when the connection is secure
    open var isSecureConnection:Bool = false
    ///Service alias
    open var serviceAlias:String?
    ///Communication Path
    open var communicationPath:String?
    ///Server UUID
    open var serverUUID:String?
    
    /**
     init: Init server info with host and port
     
     - parameter host: the server host
     - parameter port: the server port
     */
    public convenience init(host:String, port: NSNumber) {
        self.init()
        self.serverHost = host
        self.serverPort = port
        self.serviceAlias = XPSDKConstants.XPSDKMilestoneXProtectServiceAlias
        self.communicationPath = XPSDKConstants.XPSDKMilestoneXProtectEndPoint
    }
    
    /**
     init: Init server info with urlString
     
     - parameter urlString: the url
     */
    public convenience init(withUrlString urlString: String, uuid: String?, serviceAlias: String? = XPSDKConstants.XPSDKMilestoneXProtectServiceAlias) {
        self.init()
        
        guard let url = URL(string: urlString), let port = url.port else {
            return;
        }
        
        self.isSecureConnection = urlString.hasPrefix("https")
        self.serverHost = url.host ?? ""
        self.serverPort = NSNumber(value: port)
        self.serviceAlias = serviceAlias
        self.communicationPath = XPSDKConstants.XPSDKMilestoneXProtectEndPoint
        self.serverUUID = uuid
    }
    
    /**
     communicationURL: Returns the communication url for server connection
     
     - returns url: the server connection url
     */
    public func communicationURL() -> URL? {
        guard let host = serverHost, let path = communicationPath else {
            return nil
        }
        
        let urlPrefix = isSecureConnection ? "https" : "http"
        return URL(string: "\(urlPrefix)://\(host):\(serverPort)\(path)")
    }
    
}

