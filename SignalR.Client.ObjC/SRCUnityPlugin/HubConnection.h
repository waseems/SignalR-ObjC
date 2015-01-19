#import "SRHubConnection.h"
#import "SignalRClient.h"
#import "HubProxy.h"

// parameters: connection ID, state, data
typedef void (^ConnectionStateChangeCallback)(NSString *, SRCConnectionState, NSString *);
// parameters: connection ID, data
typedef void (^ConnectionCallback)(NSString *, NSString *);

/**
 * A `HubConnection` object handles state changes and sent and received messages from a referenced `SRHubConnection` object. 
 * It also holds a list of `HubProxy` instances that match the `SRHubProxy` instances referenced by the `SRHubConnection` object.
 */
@interface HubConnection : NSObject

/**
 * This connection's local ID (from Unity code); different from client's connection ID.
 */
@property NSString *connectionId;

/**
 * Reference to `SRHubConnection` object this instance's callbacks listen to.
 */
@property(setter = setConnection:, getter = getConnection) SRHubConnection *connection;

/**
 * The dictionary of hub names and `HubProxy` instances that match the `SRHubProxy` instances referenced by `SRHubConnection`.
 */
@property (strong, nonatomic) NSMutableDictionary *proxies;

/**
 * A block to be called when this connection's state changes.
 */
@property (copy) ConnectionStateChangeCallback stateChanged;

/**
 * A block to be called when a message has been sent.
 */
@property (copy) ConnectionCallback messageSent;

/**
 * A block to be called when a message is received.
 */
@property (copy) ConnectionCallback messageReceived;


#pragma mark Initialization

/**
 * Init
 */
- (id)init;

/**
 * `SRHubConnection` connection getter.
 */
- (SRHubConnection *)getConnection;

/**
 * `SRHubConnection` connection setter.
 */
- (void)setConnection:(SRHubConnection *)connection;


#pragma mark Connection callbacks

/** 
 *  Block assigned to connection.started.
 */
- (void)onStarted;

/** 
 *  Block assigned to connection.error.
 */
- (void)onError:(NSError *)error;

/** 
 *  Block assigned to connection.closed.
 */
- (void)onClosed;

/** 
 *  Block assigned to connection.reconnected.
 */
- (void)onReconnected;

/** 
 *  completionHandler assigned to every `SRHubConnection` send:completionHandler call.
 */
- (void)onMessageSent:(id)response
               withId:requestId
            withError:(NSError *)error;

/** 
 *  Block assigned to connection.received.
 */
- (void)onMessageReceived:(id)message;


#pragma mark Utils

/**
 * Gets the HubProxy instance for the given hub name.
 */
- (HubProxy *)getHubProxyWithId:(NSString *)hubName;

@end