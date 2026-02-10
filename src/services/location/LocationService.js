import Geolocation from 'react-native-geolocation-service';
import { Platform, PermissionsAndroid } from 'react-native';

/**
 * Location Service
 * Handles geofencing and proximity detection
 */

class LocationService {
    constructor() {
        this.watchId = null;
        this.currentLocation = null;
        this.onLocationUpdate = null;
        this.isAdvancedTier = false; // Track user tier for navigation features
        this.lastDatabaseUpdate = null; // Track last database ping
    }

    /**
     * Set user tier (for advanced navigation features)
     * @param {boolean} isAdvanced - Whether user has advanced tier
     */
    setUserTier(isAdvanced) {
        this.isAdvancedTier = isAdvanced;
    }

    /**
     * Request location permissions
     */
    async requestPermissions() {
        if (Platform.OS === 'android') {
            const granted = await PermissionsAndroid.request(
                PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
                {
                    title: 'Pulse Location Permission',
                    message: 'Pulse needs access to your location to find nearby matches',
                    buttonNeutral: 'Ask Me Later',
                    buttonNegative: 'Cancel',
                    buttonPositive: 'OK',
                }
            );

            if (granted === PermissionsAndroid.RESULTS.GRANTED) {
                // Also request background location for Android 10+
                if (Platform.Version >= 29) {
                    await PermissionsAndroid.request(
                        PermissionsAndroid.PERMISSIONS.ACCESS_BACKGROUND_LOCATION,
                        {
                            title: 'Pulse Background Location Permission',
                            message: 'Allow Pulse to access location in the background to detect matches',
                            buttonNeutral: 'Ask Me Later',
                            buttonNegative: 'Cancel',
                            buttonPositive: 'OK',
                        }
                    );
                }
                return true;
            }
            return false;
        }

        // iOS
        return new Promise((resolve) => {
            Geolocation.requestAuthorization('always').then((result) => {
                resolve(result === 'granted');
            });
        });
    }

    /**
     * Get current location
     */
    async getCurrentLocation() {
        return new Promise((resolve, reject) => {
            Geolocation.getCurrentPosition(
                (position) => {
                    this.currentLocation = {
                        latitude: position.coords.latitude,
                        longitude: position.coords.longitude,
                        accuracy: position.coords.accuracy,
                        timestamp: position.timestamp,
                    };
                    resolve(this.currentLocation);
                },
                (error) => {
                    console.error('Location error:', error);
                    reject(error);
                },
                {
                    enableHighAccuracy: false, // Battery optimization
                    timeout: 15000,
                    maximumAge: 10000,
                }
            );
        });
    }

    /**
     * Start watching location changes
     * @param {Function} callback - Called when location updates
     */
    startWatching(callback) {
        this.onLocationUpdate = callback;

        // Battery Optimization:
        // Basic tier: Get location ONCE when they start searching
        // Advanced tier: Continuous updates for navigation
        
        if (!this.isAdvancedTier) {
            console.log('[LocationService] Basic tier: Getting single location update');
            this.getCurrentLocation().then(location => {
                if (this.onLocationUpdate) {
                    this.onLocationUpdate(location);
                }
            }).catch(err => {
                console.error('[LocationService] Single update failed', err);
            });
            return; // Don't start continuous watcher
        }

        console.log('[LocationService] Advanced tier: Starting continuous location watch');
        this.watchId = Geolocation.watchPosition(
            (position) => {
                this.currentLocation = {
                    latitude: position.coords.latitude,
                    longitude: position.coords.longitude,
                    accuracy: position.coords.accuracy,
                    timestamp: position.timestamp,
                };

                if (this.onLocationUpdate) {
                    this.onLocationUpdate(this.currentLocation);
                }
            },
            (error) => {
                console.error('Location watch error:', error);
            },
            {
                enableHighAccuracy: true, // Better accuracy for navigation
                distanceFilter: 10,
                interval: 5000,
                fastestInterval: 2000,
                showLocationDialog: true,
            }
        );
    }

    /**
     * Stop watching location changes
     */
    stopWatching() {
        if (this.watchId !== null) {
            Geolocation.clearWatch(this.watchId);
            this.watchId = null;
        }
    }

    /**
     * Calculate distance between two coordinates (Haversine formula)
     * @returns {number} Distance in meters
     */
    calculateDistance(lat1, lon1, lat2, lon2) {
        const R = 6371e3; // Earth's radius in meters
        const φ1 = (lat1 * Math.PI) / 180;
        const φ2 = (lat2 * Math.PI) / 180;
        const Δφ = ((lat2 - lat1) * Math.PI) / 180;
        const Δλ = ((lon2 - lon1) * Math.PI) / 180;

        const a =
            Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
            Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return R * c;
    }

    /**
     * Check if a location is within radius
     */
    isWithinRadius(targetLat, targetLon, radiusMeters) {
        if (!this.currentLocation) return false;

        const distance = this.calculateDistance(
            this.currentLocation.latitude,
            this.currentLocation.longitude,
            targetLat,
            targetLon
        );

        return distance <= radiusMeters;
    }
}

export default new LocationService();
