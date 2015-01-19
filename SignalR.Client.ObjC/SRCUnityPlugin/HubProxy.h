#import "SRHubProxy.h"

// parameters: connection ID, hub name, data
typedef void (^ProxyCallback)(NSString *, NSString *, NSString *);

/**
 * A `HubProxy` object handles received events and invoked server methods from a references `SRHubProxy` object.
 */
@interface HubProxy : NSObject

/**
 * Reference to `SRHubProxy` object this instance's callbacks listen to.
 */
@property SRHubProxy *proxy;

/**
 * The name of the hub this instance's `SRHubProxy` proxies.
 */
@property NSString *hubName;

/**
 * The ID of the `HubConnection` object this instance belongs to.
 * This is passed as parameter for this instance's ProxyCallbacks.
 */
@property NSString *connectionId;

/**
 * A block to be called when an event is received.
 */
@property (copy) ProxyCallback eventReceived;

/**
 * A block to be called when a server method is invoked.
 */
@property (copy) ProxyCallback serverMethodInvoked;

/**
 * Block assigned to every `SRHubProxy` on:perform:selector call.
 */
- (void)receiveEvent:(NSString *)eventData;

/**
 * Block assigned to every `SRHubProxy` invoke:withArgs:completionHandler call.
 */
- (void)receiveInvokedServerMethod:(id)invokeData
                            withId:(NSString *)requestId;

@end