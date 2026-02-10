import PushNotification from 'react-native-push-notification';
import { Platform } from 'react-native';

/**
 * Notification Service
 * Handles push notifications for match alerts
 */

class NotificationService {
    constructor() {
        this.configure();
    }

    configure() {
        PushNotification.configure({
            // Called when a remote or local notification is opened or received
            onNotification: function (notification) {
                console.log('NOTIFICATION:', notification);

                // Handle notification actions
                if (notification.action === 'greet') {
                    // TODO: Dispatch action to add match
                    console.log('User greeted the match');
                } else if (notification.action === 'ignore') {
                    // TODO: Dispatch action to ignore match
                    console.log('User ignored the match');
                }
            },

            // Android only
            senderID: 'YOUR_SENDER_ID', // TODO: Replace with actual sender ID

            // iOS only
            permissions: {
                alert: true,
                badge: true,
                sound: true,
            },

            popInitialNotification: true,
            requestPermissions: Platform.OS === 'ios',
        });

        // Create notification channel for Android
        if (Platform.OS === 'android') {
            PushNotification.createChannel(
                {
                    channelId: 'pulse-matches',
                    channelName: 'Match Notifications',
                    channelDescription: 'Notifications for nearby matches',
                    playSound: true,
                    soundName: 'default',
                    importance: 4,
                    vibrate: true,
                },
                (created) => console.log(`Channel created: ${created}`)
            );
        }
    }

    /**
     * Request notification permissions
     */
    async requestPermissions() {
        if (Platform.OS === 'ios') {
            return new Promise((resolve) => {
                PushNotification.requestPermissions((permissions) => {
                    resolve(permissions);
                });
            });
        }
        return true; // Android doesn't need runtime permission for notifications
    }

    /**
     * Send match notification
     * @param {Object} match - Match data
     */
    sendMatchNotification(match) {
        PushNotification.localNotification({
            channelId: 'pulse-matches',
            title: 'Oseba po tvojem okusu je v bližini 💕',
            message: `${match.name}, ${match.age} je v radiju ${match.distance}m`,
            playSound: true,
            soundName: 'default',
            importance: 'high',
            vibrate: true,
            vibration: 300,
            actions: ['Pozdravi', 'Ignore'],
            userInfo: {
                matchId: match.id,
                matchUid: match.uid,
            },
            invokeApp: false, // Don't open app automatically
        });
    }

    /**
     * Cancel all notifications
     */
    cancelAllNotifications() {
        PushNotification.cancelAllLocalNotifications();
    }

    /**
     * Cancel specific notification
     */
    cancelNotification(notificationId) {
        PushNotification.cancelLocalNotification(notificationId);
    }

    /**
     * Get notification badge count (iOS)
     */
    getBadgeCount(callback) {
        if (Platform.OS === 'ios') {
            PushNotification.getApplicationIconBadgeNumber(callback);
        }
    }

    /**
     * Set notification badge count (iOS)
     */
    setBadgeCount(count) {
        if (Platform.OS === 'ios') {
            PushNotification.setApplicationIconBadgeNumber(count);
        }
    }
}

export default new NotificationService();
