part of dart_force_mvc_lib;

class SimpleWebServer {
  final Logger log = new Logger('SimpleServer');
  
  Router router;
  
  var host;
  var port;
  var wsPath;
  var staticFiles;
  var clientFiles;
  var clientServe;
  var virDir;
  var bind_address = InternetAddress.ANY_IP_V6;
  
  Completer _completer = new Completer.sync();

  SimpleWebServer(this.host,    
                  this.port,
                  this.wsPath,
                  this.staticFiles,
                  this.clientFiles,
                  this.clientServe) {
    init();
  }
  
  void init() {
    if (host != null) {
      this.bind_address = host;
    }
    
    if(clientServe == true) {
       String clientFilesPath = Platform.script.resolve(clientFiles).toFilePath();
               
       _exists(clientFilesPath);
    }
  }
     
  void _exists(dir) {
     try {
       if (!new Directory(dir).existsSync()) {
          log.severe("The '$dir' directory was not found.");
       }
     } on FileSystemException {
       log.severe("The '$dir' directory was not found.");
     }
  }
  
  /**
     * This method helps to start your webserver.
     * 
     * You can add a [WebSocketHandler].
     */
  
  Future start([WebSocketHandler handleWs]) {
    HttpServer.bind(bind_address, port).then((server) { 
      _onStartComplete(server, handleWs);
    }).catchError(_errorOnStart);
    
    return _completer.future;
  }
  
  /**
     * This method helps to start your webserver in a secure way.
     * 
     * You can add a [WebSocketHandler], certificateName,
     * 
     * The optional argument [backlog] can be used to specify the listen
     * backlog for the underlying OS listen setup. If [backlog] has the
     * value of [:0:] (the default) a reasonable value will be chosen by
     * the system.
     *
     * The certificate with nickname or distinguished name (DN) [certificateName]
     * is looked up in the certificate database, and is used as the server
     * certificate. If [requestClientCertificate] is true, the server will
     * request clients to authenticate with a client certificate. 
     */
  
  Future startSecure({WebSocketHandler handleWs: null, String certificateName, bool requestClientCertificate: false,
    int backlog: 0}) {
      HttpServer.bindSecure(bind_address, port, certificateName: certificateName,
          requestClientCertificate: requestClientCertificate,
          backlog: backlog).then((server) { 
        _onStartComplete(server, handleWs);
      }).catchError(_errorOnStart);
      
      return _completer.future;
    }
  
  void _onStartComplete(server, [WebSocketHandler handleWs]) {
    _onStart(server, handleWs);
    _completer.complete(const []);
  }
  
  void _errorOnStart(e) {
    log.warning("Could not startup the web server ... $e");
    log.info("Is your port already in use?");
  }

  Stream<HttpRequest> serve(String name) {
    return router.serve(name);
  }
  
  void setupConsoleLog([Level level = Level.INFO]) {
      Logger.root.level = level;
      Logger.root.onRecord.listen((LogRecord rec) {
        if (rec.level >= Level.SEVERE) {
          var stack = rec.stackTrace != null ? rec.stackTrace : "";
          print('${rec.level.name}: ${rec.time}: ${rec.message} - ${rec.error} $stack');
        } else {
          print('${rec.level.name}: ${rec.time}: ${rec.message}');
        }
      });
  }
 
  _onStart(server, [WebSocketHandler handleWs]) {}
}

