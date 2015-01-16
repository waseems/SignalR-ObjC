#import "SRHubProxy.h"

// parameters: connection ID, hub name, data
typedef void (^ProxyCallback)(NSString *, NSString *, NSString *);

@interface HubProxy : NSObject

@property SRHubProxy *proxy;

@property NSString *hubName;
@property NSString *connectionId;

@property (copy) ProxyCallback eventReceived;
@property (copy) ProxyCallback serverMethodInvoked;

- (void)receiveEvent:(NSString *)eventName
				withParams:(NSString*)params;

- (void)receiveInvokedServerMethod:(id)invokeData;

@end