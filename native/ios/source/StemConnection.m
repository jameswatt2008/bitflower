#import "StemConnection.h"
#import "HTTPMessage.h"
#import "HTTPResponse.h"
#import "GCDAsyncSocket.h"
#import "WebSocket.h"
#import "StemDelegate.h"
#import "AppDelegate.h"

@implementation StemConnection

- (WebSocket *)webSocketForURI:(NSString *)path {  
  if([path isEqualToString:@"/stem"]) {
    WebSocket* ws = [[WebSocket alloc] initWithRequest:request socket:asyncSocket];
    
    AppDelegate* ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    StemDelegate* sd = [ad stemDelegate];

    [ws setDelegate:sd];

    return ws;
  }
  
  return [super webSocketForURI:path];
}


@end
