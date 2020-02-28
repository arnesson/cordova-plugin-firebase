interface IChannelOptions {
    id: string
    name?: string
    description?: string
    sound?: string
    vibration?: boolean | number[]
    light?: boolean
    lightColor?: string
    importance?: 0 | 1 | 2 | 3 | 4
    badge?: boolean
    visibility?: -1 | 0 | 1
}

interface FirebasePlugin {
    getId(
        success: (value: string) => void,
        error: (err: string) => void
    ): void
    getToken(
        success: (value: string) => void,
        error: (err: string) => void
    ): void
    onTokenRefresh(
        success: (value: string) => void,
        error: (err: string) => void): void
    getAPNSToken(
        success: (value: string) => void,
        error: (err: string) => void
    ): void
    onApnsTokenReceived(
        success: (value: string) => void,
        error: (err: string) => void
    ): void
    onMessageReceived(
        success: (value: object) => void,
        error: (err: string) => void
    ): void
    grantPermission(
        success: (value: boolean) => void,
        error: (err: string) => void
    ): void
    hasPermission(
        success: (value: boolean) => void,
        error: (err: string) => void
    ): void
    unregister(): void
    setBadgeNumber(
        badgeNumber: number
    ): void
    getBadgeNumber(
        success: (badgeNumber: number) => void,
        error: (err: string) => void
    ): void
    clearAllNotifications(): void
    subscribe(
        topic: string
    ): void
    unsubscribe(
        topic: string
    ): void
    isAutoInitEnabled(
        success: (enabled: boolean) => void,
        error?: (err: string) => void
    ): void
    setAutoInitEnabled(
        enabled: boolean,
        success?: () => void,
        error?: (err: string) => void
    ): void
    createChannel(
        channel: IChannelOptions,
        success: () => void,
        error: (err: string) => void
    ): void
    setDefaultChannel(
        channel: IChannelOptions,
        success: () => void,
        error: (err: string) => void
    ): void
    deleteChannel(
        channel: string,
        success: () => void,
        error: (err: string) => void
    ): void
    listChannels(
        success: (list: { id: string; name: string }[]) => void,
        error: (err: string) => void
    ): void
    setAnalyticsCollectionEnabled(
        setEnabled: boolean
    ): void
    logEvent(
        eventName: string,
        eventProperties: object
    ): void
    setScreenName(
        screenName: string
    ): void
    setUserId(
        userId: string
    ): void
    setUserProperty(
        userName: string,
        userValue: string
    ): void
    setCrashlyticsCollectionEnabled(): void
    setCrashlyticsUserId(
        userId: string
    ): void
    sendCrash(): void
    logMessage(
        message: string
    ): void
    logError(
        errorMessage: string,
        stackTrace?: object,
        success?: () => void,
        error?: (err: string) => void
    )
    verifyPhoneNumber(
        success: (value: object) => void,
        error: (err: string) => void,
        phoneNumber: string,
        timeOutDuration: number,
        fakeVerificationCode?: string
    ): void
    createUserWithEmailAndPassword(
        email: string,
        password: string,
        success?: () => void,
        error?: (err: string) => void
    ): void
    signInUserWithEmailAndPassword(
        email: string,
        password: string,
        success?: () => void,
        error?: (err: string) => void
    ): void
    authenticateUserWithGoogle(
        clientId: string,
        success?: () => void,
        error?: (err: string) => void
    ): void
    authenticateUserWithApple(
        success?: () => void,
        error?: (err: string) => void,
        locale?: string,
    ): void
    signInWithCredential(
        credential: object,
        success?: () => void,
        error?: (err: string) => void
    ): void
    linkUserWithCredential(
        credential: object,
        success?: () => void,
        error?: (err: string) => void
    ): void
    reauthenticateWithCredential(
        credential: object,
        success?: () => void,
        error?: (err: string) => void
    ): void
    isUserSignedIn(
        success: (isSignedIn: boolean) => void,
        error?: (err: string) => void
    ): void
    signOutUser(
        success?: () => void,
        error?: (err: string) => void
    ): void
    getCurrentUser(
        success: (user: object) => void,
        error?: (err: string) => void
    ): void
    updateUserProfile(
        profile: {
            name: string,
            photoUri: string
        },
        success?: () => void,
        error?: (err: string) => void
    ): void
    updateUserEmail(
        email: string,
        success?: () => void,
        error?: (err: string) => void
    ): void
    sendUserEmailVerification(
        success?: () => void,
        error?: (err: string) => void
    ): void
    updateUserPassword(
        password: string,
        success?: () => void,
        error?: (err: string) => void
    ): void
    sendUserPasswordResetEmail(
        email: string,
        success?: () => void,
        error?: (err: string) => void
    ): void
    deleteUser(
        success?: () => void,
        error?: (err: string) => void
    ): void
    registerAuthStateChangeListener(
        fn: (userSignedIn: boolean) => void,
    ): void
    fetch(
        cacheExpirationSeconds: number,
        success: () => void,
        error: (err: string) => void
    ): void
    fetch(
        success: () => void,
        error: (err: string) => void
    ): void
    activateFetched(
        success: (activated: boolean) => void,
        error: (err: string) => void
    ): void
    getValue(
        key: string,
        success: (value: string) => void,
        error: (err: string) => void
    ): void
    getByteArray(
        key: string,
        success: (value: object) => void,
        error: (err: string) => void
    ): void
    getInfo(
        success: (info: object) => void,
        error: (err: string) => void
    ): void
    setConfigSettings(
        configSettings: object,
        success: (info: object) => void,
        error: (err: string) => void
    ): void
    setDefaults(
        defaultSettings: object,
        success: (info: object) => void,
        error: (err: string) => void
    ): void
    setPerformanceCollectionEnabled(
        setEnabled: boolean
    ): void
    startTrace(
        name: string,
        success: () => void,
        error: (err: string) => void
    ): void
    incrementCounter(
        name: string,
        counterName: string,
        success: () => void,
        error: (err: string) => void
    ): void
    stopTrace(
        name: string
    ): void
    addDocumentToFirestoreCollection(
        document: object,
        collection: string,
        success: () => void,
        error: (err: string) => void
    ): void
    setDocumentInFirestoreCollection(
        documentId: string,
        document: object,
        collection: string,
        success: () => void,
        error: (err: string) => void
    ): void
    updateDocumentInFirestoreCollection(
        documentId: string,
        document: object,
        collection: string,
        success: () => void,
        error: (err: string) => void
    ): void
    deleteDocumentFromFirestoreCollection(
        documentId: string,
        collection: string,
        success: () => void,
        error: (err: string) => void
    ): void
    fetchDocumentInFirestoreCollection(
        documentId: string,
        collection: string,
        success: (document: object) => void,
        error: (err: string) => void
    ): void
    fetchFirestoreCollection(
        collection: string,
        success: (collection: object) => void,
        error: (err: string) => void
    ): void
}
declare var FirebasePlugin: FirebasePlugin;
