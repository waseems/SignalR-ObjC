#import "HubConnection.h"
#import "SignalRClient.h"
#import "SRCSendData.h"

@implementation HubConnection


- (id)init
{
    if (self = [super init])
    {
        self.proxies = [NSMutableDictionary init];
    }
    return self;
}

- (SRHubConnection *)getConnection
{
    return self.connection;
}

- (void)setConnection:(SRHubConnection *)connection
{
    self.connection = connection;
    
    __weak HubConnection *blockSelf = self;
    
    self.connection.started = ^() { [blockSelf onStarted]; };
    self.connection.error = ^(NSError *error) { [blockSelf onError:error]; };
    self.connection.closed = ^() { [blockSelf onClosed]; };
    self.connection.reconnected = ^() { [blockSelf onReconnected]; };
    self.connection.received = ^(id message) { [blockSelf onMessageReceived:message]; };
}


#pragma mark exposed methods

- (void)sendMessage:(NSString *)message
{
}


#pragma mark Connection callbacks

/** 
 *  Block assigned to Connection.started
 */
- (void)onStarted
{
    self.stateChanged(self.connectionId, RSC_CONN_STATE_STARTED, @"");
}

/** 
 *  Block assigned to Connection.error
 */
- (void)onError:(NSError *)error
{
    NSString *dataString = [SignalRClient jsonSerialize:error];
    self.stateChanged(self.connectionId, RSC_CONN_STATE_ERROR, dataString);
}

/** 
 *  Block assigned to Connection.closed
 */
- (void)onClosed
{
    self.stateChanged(self.connectionId, RSC_CONN_STATE_CLOSED, @"");
}

/** 
 *  Block assigned to Connection.reconnected
 */
- (void)onReconnected
{
    self.stateChanged(self.connectionId, RSC_CONN_STATE_RECONNECTED, @"");
}

/** 
 *  completionHandler assigned to every send:completionHandler call
 */
- (void)onMessageSent:(id)response
               withId:requestId
            withError:(NSError *)error
{
    if (error != nil)
    {
        NSLog(@"HubConnection.onMessageSent error: %@", error);
        return;
    }
    
    SRCSendData *dataObj = [SRCSendData init];
    dataObj.RequestId = requestId;
    dataObj.Response = [SignalRClient jsonSerialize:response];
    
    NSString *dataString = [SignalRClient jsonSerialize:dataObj];
    
    self.messageSent(self.connectionId, dataString);
}

/** 
 *  Block assigned to Connection.received
 */
- (void)onMessageReceived:(id)message
{
    NSString *dataString = [SignalRClient jsonSerialize:message];
    
    self.messageSent(self.connectionId, dataString);
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