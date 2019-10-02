interface IChannelOptions {
    id: string
    name?: string
    sound?: string
    vibration?: boolean | number[]
    light?: boolean
    lightColor?: string
    importance?: 0 | 1 | 2 | 3 | 4
    badge?: boolean
    visibility?: -1 | 0 | 1
}

interface FirebasePlugin {
    getToken(success: (value: string) => void, error: (err: string) => void): void
    onTokenRefresh(success: (value: string) => void, error: (err: string) => void): void
    getAPNSToken(success: (value: string) => void, error: (err: string) => void): void
    onMessageReceived(success: (value: object) => void, error: (err: string) => void): void
    grantPermission(success: (value: boolean) => void, error: (err: string) => void): void
    hasPermission(success: (value: boolean) => void, error: (err: string) => void): void
    unregister(): void
    setBadgeNumber(badgeNumber: number): void
    getBadgeNumber(success: (badgeNumber: number) => void, error: (err: string) => void): void
    clearAllNotifications(): void
    subscribe(topic: string): void
    unsubscribe(topic: string): void
    createChannel(channel: IChannelOptions, success: () => void, error: (err: string) => void): void
    setDefaultChannel(channel: IChannelOptions, success: () => void, error: (err: string) => void): void
    deleteChannel(channel: string, success: () => void, error: (err: string) => void): void
    listChannels(success: (list: { id: string; name: string }[]) => void, error: (err: string) => void): void
    setAnalyticsCollectionEnabled(setEnabled: boolean): void
    logEvent(eventName: string, eventProperties: object): void
    setScreenName(screenName: string): void
    setUserId(userId: string): void
    setUserProperty(userName: string, userValue: string): void
    setCrashlyticsCollectionEnabled(): void
    setCrashlyticsUserId(userId: string): void
    sendCrash(): void
    logMessage(message: string): void
    logError(errorMessage: string): void
    verifyPhoneNumber(
        phoneNumber: string,
        timeOutDuration: number,
        success: (value: string | object) => void,
        error: (err: string) => void
    ): void
    fetch(cacheExpirationSeconds: number, success: () => void, error: (err: string) => void): void
    fetch(success: () => void, error: (err: string) => void): void
    activateFetched(success: (activated: boolean) => void, error: (err: string) => void): void
    getValue(key: string, success: (value: string) => void, error: (err: string) => void): void
    getByteArray(key: string, success: (value: object) => void, error: (err: string) => void): void
    getInfo(success: (info: object) => void, error: (err: string) => void): void
    setConfigSettings(configSettings: object, success: (info: object) => void, error: (err: string) => void): void
    setDefaults(defaultSettings: object, success: (info: object) => void, error: (err: string) => void): void
    setPerformanceCollectionEnabled(setEnabled: boolean): void
    startTrace(name: string, success: () => void, error: (err: string) => void): void
    incrementCounter(name: string, counterName: string, success: () => void, error: (err: string) => void): void
    stopTrace(name: string): void
}
declare var FirebasePlugin: FirebasePlugin; 
