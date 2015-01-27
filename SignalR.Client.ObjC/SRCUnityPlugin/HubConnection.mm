#import "HubConnection.h"
#import "SignalRClient.h"
#import "SRCSendData.h"

@implementation HubConnection

@synthesize connection = _connection;

- (id)init
{
    if (self = [super init])
    {
        // init proxies dictionary
        self.proxies = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (SRHubConnection *)getConnection
{
    return _connection;
}

- (void)setConnection:(SRHubConnection *)connection
{
    _connection = connection;
    
    // set connection blocks

    __weak HubConnection *blockSelf = self;
    self.connection.started = ^() { [blockSelf onStarted]; };
    self.connection.error = ^(NSError *error) { [blockSelf onError:error]; };
    self.connection.closed = ^() { [blockSelf onClosed]; };
    self.connection.reconnected = ^() { [blockSelf onReconnected]; };
    self.connection.received = ^(id message) { [blockSelf onMessageReceived:message]; };
}


#pragma mark Connection callbacks

/** 
 *  Block assigned to Connection.started
 */
- (void)onStarted
{
    NSLog(@"HC onStarted");
    self.stateChanged(self.connectionId, RSC_CONN_STATE_STARTED, @"");
}

/** 
 *  Block assigned to Connection.error
 */
- (void)onError:(NSError *)error
{
    NSLog(@"HC onError: %@", error.description);
    NSString *dataString = [SignalRClient jsonSerialize:error];
    NSLog(@"HC onError2: %@", error.description);
    self.stateChanged(self.connectionId, RSC_CONN_STATE_ERROR, dataString);
}

/** 
 *  Block assigned to Connection.closed
 */
- (void)onClosed
{
    NSLog(@"HC onClosed");
    self.stateChanged(self.connectionId, RSC_CONN_STATE_CLOSED, @"");
}

/** 
 *  Block assigned to Connection.reconnected
 */
- (void)onReconnected
{
    NSLog(@"HC onReconnected");
    self.stateChanged(self.connectionId, RSC_CONN_STATE_RECONNECTED, @"");
}

/** 
 *  completionHandler assigned to every send:completionHandler call
 */
- (void)onMessageSent:(id)response
               withId:requestId
            withError:(NSError *)error
{
    NSLog(@"HC onMessageSent: %@", requestId);
    if (error != nil)
    {
        NSLog(@"HubConnection.onMessageSent error: %@", error);
        return;
    }
    
    SRCSendData *dataObj = [[SRCSendData alloc] init];
    dataObj.RequestId = requestId;
    dataObj.Response = [SignalRClient jsonSerialize:response];
    NSLog(@"HC onMessageSent2: %@", requestId);
    
    NSString *dataString = [SignalRClient jsonSerialize:[dataObj getDict]];
    NSLog(@"HC onMessageSent3: %@", requestId);
    
    self.messageSent(self.connectionId, dataString);
}

/** 
 *  Block assigned to Connection.received
 */
- (void)onMessageReceived:(id)message
{
    NSLog(@"onMessageReceived class: %@", [message class]);
    NSString *dataString;
    if ([message isKindOfClass:[NSString class]]) dataString = (NSString *)message;
    else dataString = [SignalRClient jsonSerialize:message];
    NSLog(@"onMessageReceived class2: %@", [message class]);
    
    self.messageReceived(self.connectionId, dataString);
}


#pragma mark Utils

- (HubProxy *)getHubProxyWithId:(NSString *)hubName
{
    HubProxy *hubProxy = [self.proxies objectForKey:hubName];
    
    if (hubProxy == nil)
    {
        NSLog(@"SignalRClient.createProxy: proxy with name %@ not found", hubName);
        return nil;
    }
    
    return hubProxy;
}

@end