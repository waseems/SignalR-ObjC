/**
 * Delegates that match those in Unity C# to allow C-to-C# calls.
 */
// parameters: state ID, state data
typedef void __stdcall SRCConnectionStateChangeCallback(const char*, int, const char*);
// parameters: connection ID, data
typedef void __stdcall SRCConnectionCallback(const char*, const char*);
// parameters: connection ID, hub name, data
typedef void __stdcall SRCProxyCallback(const char*, const char*, const char*);

// SignalR Client hub connection states that match those in Unity code
typedef enum srcConnectionStates
{
	RSC_CONN_STATE_NONE,
	RSC_CONN_STATE_STARTED,
	RSC_CONN_STATE_ERROR,
	RSC_CONN_STATE_CLOSED,
	RSC_CONN_STATE_RECONNECTED
} SRCConnectionState;

// SignalR Client transport types that match those in Unity code
typedef enum srcTransportTypes
{
	SRC_TRANSPORT_AUTO,
	SRC_TRANSPORT_WEB_SOCKETS,
	SRC_TRANSPORT_SERVER_SENT_EVENTS,
	SRC_TRANSPORT_LONG_POLLING
} SRCTransportType;


/**
 * A `SignalRClient` object handles the creation and management of connections and proxies and allows
 * related operations such as event subscription, server method invocation, and message sending.
 * It also exposes callbacks that are triggered when some operations finish and
 * triggered by events, messages, and connection state changes received.
 */
@interface SignalRClient : NSObject

/**
 * The dictionary of (Unity-generated) hub connection IDs and `HubConnection` instances that match the `SRHubConnection` instances created.
 */
@property (strong, nonatomic) NSMutableDictionary *connections;

/**
 * Unity C# callback triggered when a hub connection's state changes.
 */
@property SRCConnectionStateChangeCallback *connectionStateChanged;

/**
 * Unity C# callback triggered when a message is sent.
 */
@property SRCConnectionCallback *messageSent;

/**
 * Unity C# callback triggered when a message is received.
 */
@property SRCConnectionCallback *messageReceived;

/**
 * Unity C# callback triggered when a server method is invoked.
 */
@property SRCProxyCallback *serverMethodInvoked;

/**
 * Unity C# callback triggered when an event is received.
 */
@property SRCProxyCallback *eventReceived;


#pragma mark Initialization

/**
 * Init
 */
- (id)init;


#pragma mark Called from Unity - hub connection methods

/**
 * Creates a connection with the given connection ID (only locally generated and used, different from client connection ID),
 * connects to the given url with the given optional query.
 */
- (void)createConnection:(NSString *)connectionId
                   toUrl:(NSString *)url
               withQuery:(NSString *)query;

/**
 * Creates a proxy for the hub with given name within given connection.
 */
- (void)createProxy:(NSString *)hubName
       inConnection:(NSString *)connectionId;

/**
 * Starts the connection with the specified transport type.
 */
- (void)startConnection:(NSString *)connectionId
          withTransport:(SRCTransportType)transport;

/**
 * Stops the connection.
 */
- (void)stopConnection:(NSString *)connectionId;

/**
 * Sends the message via the given connection.
 * The request ID is only locally generated and used.
 */
- (void)sendMessage:(NSString *)data
             withId:(NSString *)requestId
       inConnection:(NSString *)connectionId;


#pragma mark Called from Unity - hub proxy methods

/**
 * Calls the given server method with given params for the given hub via the given connection.
 * The request ID is only locally generated and used.
 */
- (void)callServerMethod:(NSString *)methodName
                withArgs:(NSString *)params
                  withId:(NSString *)requestId
                   inHub:(NSString *)hubName
            inConnection:(NSString *)connectionId;

/**
 * Creates a subscription to the given event within the given hub in the given connection.
 */
- (void)subscribeToEvent:(NSString *)eventName
                   inHub:(NSString *)hubName
            inConnection:(NSString *)connectionId;


#pragma mark Called from Unity - callback setters

/**
 * Sets the callback for connection state changes.
 */
- (void)setConnectionStateChangeCallback:(SRCConnectionStateChangeCallback *)callback;

/**
 * Sets the callback for messages sent.
 */
- (void)setMessageSentCallback:(SRCConnectionCallback *)callback;

/**
 * Sets the callback for messages received.
 */
- (void)setMessageReceivedCallback:(SRCConnectionCallback *)callback;

/**
 * Sets the callback for server methods invoked.
 */
- (void)setServerMethodInvokedCallback:(SRCProxyCallback *)callback;

/**
 * Sets the callback for events received.
 */
- (void)setEventReceivedCallback:(SRCProxyCallback *)callback;


#pragma mark Utils

/**
 * Serializes the given object to JSON NSString.
 * Returns empty string if given object isn't serializable.
 */
+ (NSString *)jsonSerialize:(id)toSerialize;

@end