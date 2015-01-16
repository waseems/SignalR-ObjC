#import "SRHubConnection.h"
#import "SignalRClient.h"
#import "HubProxy.h"

// parameters: connection ID, state, data
typedef void (^ConnectionStateChangeCallback)(NSString *, SRCConnectionState, NSString *);
// parameters: connection ID, data
typedef void (^ConnectionCallback)(NSString *, NSString *);

@interface HubConnection : NSObject

@property NSString *connectionId;
@property(setter = setConnection:, getter = getConnection) SRHubConnection *connection;
@property (strong, nonatomic) NSMutableDictionary *proxies;

@property (copy) ConnectionStateChangeCallback stateChanged;
@property (copy) ConnectionCallback messageSent;
@property (copy) ConnectionCallback messageReceived;


#pragma mark Initialization

- (id)init;

- (SRHubConnection *)getConnection;
- (void)setConnection:(SRHubConnection *)connection;

#pragma mark Exposed methods

- (void)sendMessage:(NSString *)message;


#pragma mark Connection callbacks

/** 
 *  Block assigned to Connection.started
 */
- (void)onStarted;

/** 
 *  Block assigned to Connection.error
 */
- (void)onError:(NSError *)error;

/** 
 *  Block assigned to Connection.closed
 */
- (void)onClosed;

/** 
 *  Block assigned to Connection.reconnected
 */
- (void)onReconnected;

/** 
 *  completionHandler assigned to every send:completionHandler call
 */
- (void)onMessageSent:(id)response
				withError:(NSError *)error;

/** 
 *  Block assigned to Connection.received
 */
- (void)onMessageReceived:(id)message;


#pragma mark Utils

- (HubProxy *)getHubProxyWithId:(NSString *)hubName;

@end