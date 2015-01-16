
// parameters: state ID, state data
typedef void __stdcall SRCConnectionStateChangeCallback(const char*, int, const char*);
// parameters: connection ID, data
typedef void __stdcall SRCConnectionCallback(const char*, const char*);
// parameters: connection ID, hub name, data
typedef void __stdcall SRCProxyCallback(const char*, const char*, const char*);

typedef enum srcConnectionStates
{
	RSC_CONN_STATE_NONE,
	RSC_CONN_STATE_STARTED,
	RSC_CONN_STATE_ERROR,
	RSC_CONN_STATE_CLOSED,
	RSC_CONN_STATE_RECONNECTED
} SRCConnectionState;

typedef enum srcTransportTypes
{
	SRC_TRANSPORT_AUTO,
	SRC_TRANSPORT_WEB_SOCKETS,
	SRC_TRANSPORT_SERVER_SENT_EVENTS,
	SRC_TRANSPORT_LONG_POLLING
} SRCTransportType;


@interface SignalRClient : NSObject

@property (strong, nonatomic) NSMutableDictionary *connections;

@property SRCConnectionStateChangeCallback *connectionStateChanged;
@property SRCConnectionCallback *messageSent;
@property SRCConnectionCallback *messageReceived;
@property SRCProxyCallback *serverMethodInvoked;
@property SRCProxyCallback *eventReceived;


#pragma mark Initialization

- (id)init;


#pragma mark Called from Unity - hub connection methods

- (void)createConnection:(NSString *)connectionId
                   toUrl:(NSString *)url
               withQuery:(NSString *)query;

- (void)createProxy:(NSString *)hubName
       inConnection:(NSString *)connectionId;

- (void)startConnection:(NSString *)connectionId
          withTransport:(SRCTransportType)transport;

- (void)stopConnection:(NSString *)connectionId;

- (void)sendMessage:(NSString *)data
             withId:(NSString *)requestId
       inConnection:(NSString *)connectionId;


#pragma mark Called from Unity - hub proxy methods

- (void)callServerMethod:(NSString *)methodName
                withArgs:(NSString *)params
                  withId:(NSString *)requestId
                   inHub:(NSString *)hubName
            inConnection:(NSString *)connectionId;

- (void)subscribeToEvent:(NSString *)eventName
                   inHub:(NSString *)hubName
            inConnection:(NSString *)connectionId;


#pragma mark Called from Unity - callback setters
			
- (void)setConnectionStateChangeCallback:(SRCConnectionStateChangeCallback *)callback;

- (void)setMessageSentCallback:(SRCConnectionCallback *)callback;

- (void)setMessageReceivedCallback:(SRCConnectionCallback *)callback;

- (void)setServerMethodInvokedCallback:(SRCProxyCallback *)callback;

- (void)setEventReceivedCallback:(SRCProxyCallback *)callback;


#pragma mark Utils

+ (NSString *)jsonSerialize:(id)toSerialize;

@end