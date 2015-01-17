#import "SignalRClient.h"
#import "HubConnection.h"
#import "HubProxy.h"
#import "SRWebSocketTransport.h"
#import "SRServerSentEventsTransport.h"
#import "SRLongPollingTransport.h"

#define MakeStringCopy( _x_ ) ( _x_ != NULL && [_x_ isKindOfClass:[NSString class]] ) ? strdup( [_x_ UTF8String] ) : NULL

@implementation SignalRClient

#pragma mark called from Unity

- (id)init
{
    if (self = [super init])
    {
        self.connections = [NSMutableDictionary init];
    }
    return self;
}


#pragma mark Called from Unity - hub connection methods

- (void)createConnection:(NSString *)connectionId
					toUrl:(NSString *)url
                    withQuery:(NSString *)query
{
    HubConnection *hubConn = [HubConnection init];
    
    // set ID
    hubConn.connectionId = connectionId;
    
    // set connection reference
    SRHubConnection *srHubConn = [SRHubConnection connectionWithURL:url queryString:query];
    hubConn.connection = srHubConn;
    
    // set callbacks
    hubConn.stateChanged = ^(NSString *connectionId, SRCConnectionState state, NSString *data)
    {
        [self handleConnection:connectionId state:state withData:data];
    };
    hubConn.messageSent = ^(NSString *connectionId, NSString *data)
    {
        [self handleMessageSent:data inConnection:connectionId];
    };
    hubConn.messageReceived = ^(NSString *connectionId, NSString *data)
    {
        [self handleMessageReceived:data inConnection:connectionId];
    };
    
    // add to connections dictionary
    [self.connections setObject:hubConn forKey:connectionId];
}

- (void)createProxy:(NSString *)hubName
        inConnection:(NSString *)connectionId
{
    HubConnection *hubConn = [self getHubConnectionWithId:connectionId];
    if (hubConn == nil) return;
    
    HubProxy *hubProxy = [HubProxy init];
    
    // set hub name
    hubProxy.hubName = hubName;
    
    // set connection ID
    hubProxy.connectionId = connectionId;
    
    // set proxy reference
    SRHubProxy *srHubProxy = [hubConn.connection createHubProxy:connectionId];
    hubProxy.proxy = srHubProxy;
    
    // set callbacks
    hubProxy.serverMethodInvoked = ^(NSString *connectionId, NSString *hubName, NSString *data)
    {
        [self handleInvokedServerMethod:data inHub:hubName inConnection:connectionId];
    };
    hubProxy.eventReceived = ^(NSString *connectionId, NSString *hubName, NSString *data)
    {
        [self handleEvent:data inHub:hubName inConnection:connectionId];
    };
    
    // add to proxies dictionary
    [hubConn.proxies setObject:hubProxy forKey:hubName];
}

- (void)startConnection:(NSString *)connectionId
		withTransport:(SRCTransportType)transportType;
{
    HubConnection *hubConn = [self getHubConnectionWithId:connectionId];
    if (hubConn == nil) return;
    
    switch (transportType) {
        case SRC_TRANSPORT_AUTO:
            [hubConn.connection start];
            break;
            
        case SRC_TRANSPORT_WEB_SOCKETS:
            [hubConn.connection start:[SRWebSocketTransport init]];
            break;
            
        case SRC_TRANSPORT_SERVER_SENT_EVENTS:
            [hubConn.connection start:[SRServerSentEventsTransport init]];
            break;
            
        case SRC_TRANSPORT_LONG_POLLING:
            [hubConn.connection start:[SRLongPollingTransport init]];
            break;
            
        default:
            NSLog(@"SignalRClient.startConnection: %u transport type not handled", transportType);
            break;
    }
    
    [hubConn.connection start];
}

- (void)stopConnection:(NSString *)connectionId
{
    HubConnection *hubConn = [self getHubConnectionWithId:connectionId];
    if (hubConn == nil) return;
    
    [hubConn.connection stop];
    
    // clean up
    [self.connections removeObjectForKey:connectionId];
}

- (void)sendMessage:(NSString *)data
             withId:(NSString *)requestId
       inConnection:(NSString *)connectionId;
{
    HubConnection *hubConn = [self getHubConnectionWithId:connectionId];
    if (hubConn == nil) return;
    
    __weak NSString *blockRequestId = requestId;
    
    [hubConn.connection send:data completionHandler:^(id response, NSError *error) {
        [hubConn onMessageSent:response withId:blockRequestId withError:error];
    }];
}


#pragma mark Called from Unity - hub proxy methods

- (void)callServerMethod:(NSString *)methodName
                withArgs:(NSArray *)params
                  withId:(NSString *)requestId
                   inHub:(NSString *)hubName
            inConnection:(NSString *)connectionId;
{
    HubConnection *hubConn = [self getHubConnectionWithId:connectionId];
    if (hubConn == nil) return;
    
    HubProxy *hubProxy = [hubConn getHubProxyWithId:hubName];
    if (hubProxy == nil) return;
    
    __weak NSString *blockRequestId = requestId;
    
    [hubProxy.proxy invoke:methodName withArgs:params completionHandler:^(id response) {
        [hubProxy receiveInvokedServerMethod:response withId:blockRequestId];
    }];
}

- (void)subscribeToEvent:(NSString *)eventName
                   inHub:(NSString *)hubName
            inConnection:(NSString *)connectionId
{
    HubConnection *hubConn = [self getHubConnectionWithId:connectionId];
    if (hubConn == nil) return;
    
    HubProxy *hubProxy = [hubConn getHubProxyWithId:hubName];
    if (hubProxy == nil) return;
    
    [hubProxy.proxy subscribe:eventName];
}


#pragma mark called from Unity - callback setters

- (void)setConnectionStateChangeCallback:(SRCConnectionStateChangeCallback *)callback
{
    self.connectionStateChanged = callback;
}

- (void)setMessageSentCallback:(SRCConnectionCallback *)callback
{
    self.messageSent = callback;
}

- (void)setMessageReceivedCallback:(SRCConnectionCallback *)callback
{
    self.messageReceived = callback;
}

- (void)setServerMethodInvokedCallback:(SRCProxyCallback *)callback
{
    self.serverMethodInvoked = callback;
}

- (void)setEventReceivedCallback:(SRCProxyCallback *)callback
{
    self.eventReceived = callback;
}


#pragma mark HubConnection callbacks

- (void)handleConnection:(NSString *)connectionId
                    state:(SRCConnectionState)state
                    withData:(NSString *)data
{
    self.connectionStateChanged(MakeStringCopy(connectionId), (int)state, MakeStringCopy(data));
}

- (void)handleMessageSent:(NSString *)data
             inConnection:(NSString *)connectionId
{
    self.messageSent(MakeStringCopy(connectionId), MakeStringCopy(data));
}

- (void)handleMessageReceived:(NSString *)data
                 inConnection:(NSString *)connectionId
{
    self.messageReceived(MakeStringCopy(connectionId), MakeStringCopy(data));
}


#pragma mark HubProxy callbacks

- (void)handleInvokedServerMethod:(NSString *)data
							inHub:(NSString *)hubName
                     inConnection:(NSString *)connectionId
{
    self.serverMethodInvoked(MakeStringCopy(connectionId), MakeStringCopy(hubName), MakeStringCopy(data));
}

- (void)handleEvent:(NSString *)data
              inHub:(NSString *)hubName
       inConnection:(NSString *)connectionId
{
    self.eventReceived(MakeStringCopy(connectionId), MakeStringCopy(hubName), MakeStringCopy(data));
}


#pragma mark Utils

+ (NSString *)jsonSerialize:(id)toSerialize
{
    // Convertable to JSON ?
    if ([NSJSONSerialization isValidJSONObject:toSerialize])
    {
        NSError *error;
        
        // Serialize the dictionary
        NSData *json = [NSJSONSerialization dataWithJSONObject:toSerialize options:NSJSONWritingPrettyPrinted error:&error];
        
        // If no errors, let's view the JSON
        if (json != nil && error == nil)
        {
            NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            
            NSLog(@"SignalRClient.jsonSerialize: %@", jsonString);
            return jsonString;
        }
        
        NSLog(@"SignalRClient.jsonSerialize serialization error: %@", error);
    }
    
    NSLog(@"SignalRClient.jsonSerialize: object not serializable");
    
    return @"";
}

- (HubConnection *)getHubConnectionWithId:(NSString *)connectionId
{
    HubConnection *hubConn = [self.connections objectForKey:connectionId];
    
    if (hubConn == nil)
    {
        NSLog(@"SignalRClient.createProxy: connection with ID %@ not found", connectionId);
        return nil;
    }
    
    return hubConn;
}

@end