import { BleManager } from 'react-native-ble-plx';
import { Platform, PermissionsAndroid } from 'react-native';

/**
 * BLE Service
 * Handles Bluetooth Low Energy scanning and advertising for device discovery
 */

class BLEService {
    constructor() {
        this.manager = new BleManager();
        this.isScanning = false;
        this.onDeviceFound = null;
    }

    /**
     * Request Bluetooth permissions
     */
    async requestPermissions() {
        if (Platform.OS === 'android') {
            if (Platform.Version >= 31) {
                // Android 12+ requires new permissions
                const granted = await PermissionsAndroid.requestMultiple([
                    PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,
                    PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT,
                    PermissionsAndroid.PERMISSIONS.BLUETOOTH_ADVERTISE,
                ]);

                return (
                    granted['android.permission.BLUETOOTH_SCAN'] === PermissionsAndroid.RESULTS.GRANTED &&
                    granted['android.permission.BLUETOOTH_CONNECT'] === PermissionsAndroid.RESULTS.GRANTED
                );
            } else {
                // Android 11 and below
                const granted = await PermissionsAndroid.request(
                    PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
                    {
                        title: 'Pulse Bluetooth Permission',
                        message: 'Pulse needs Bluetooth to discover nearby users',
                        buttonNeutral: 'Ask Me Later',
                        buttonNegative: 'Cancel',
                        buttonPositive: 'OK',
                    }
                );
                return granted === PermissionsAndroid.RESULTS.GRANTED;
            }
        }

        // iOS automatically handles permissions
        return true;
    }

    /**
     * Check if Bluetooth is enabled
     */
    async isBluetoothEnabled() {
        const state = await this.manager.state();
        return state === 'PoweredOn';
    }

    /**
     * Start BLE scanning for nearby devices
     * @param {Function} callback - Called when a device is found
     */
    async startScanning(callback) {
        this.onDeviceFound = callback;

        const enabled = await this.isBluetoothEnabled();
        if (!enabled) {
            console.warn('Bluetooth is not enabled');
            return false;
        }

        if (this.isScanning) {
            console.log('Already scanning');
            return true;
        }

        this.isScanning = true;

        // Battery-optimized scanning: scan for 5s, sleep for 55s
        this.scanCycle();

        return true;
    }

    /**
     * Scan cycle for battery optimization
     */
    async scanCycle() {
        if (!this.isScanning) return;

        // Scan for 5 seconds
        this.manager.startDeviceScan(
            null, // Scan for all devices
            { allowDuplicates: false },
            (error, device) => {
                if (error) {
                    console.error('BLE scan error:', error);
                    return;
                }

                if (device && device.name && device.name.startsWith('Pulse_')) {
                    // Found a Pulse user
                    if (this.onDeviceFound) {
                        this.onDeviceFound(device);
                    }
                }
            }
        );

        // Stop scanning after 5 seconds
        setTimeout(() => {
            this.manager.stopDeviceScan();

            // Wait 55 seconds before next scan (battery optimization)
            if (this.isScanning) {
                setTimeout(() => {
                    this.scanCycle();
                }, 55000);
            }
        }, 5000);
    }

    /**
     * Stop BLE scanning
     */
    stopScanning() {
        this.isScanning = false;
        this.manager.stopDeviceScan();
    }

    /**
     * Start advertising (broadcasting) user presence
     * Note: BLE advertising is limited on mobile devices
     * This is a placeholder for future implementation
     */
    async startAdvertising(userId) {
        // TODO: Implement BLE advertising
        // Note: React Native BLE PLX doesn't support peripheral mode well
        // Consider using a server-based approach for user discovery
        console.log('BLE advertising not fully supported on mobile');
    }

    /**
     * Stop advertising
     */
    stopAdvertising() {
        // TODO: Implement stop advertising
    }

    /**
     * Connect to a device to exchange data
     */
    async connectToDevice(deviceId) {
        try {
            const device = await this.manager.connectToDevice(deviceId);
            await device.discoverAllServicesAndCharacteristics();
            return device;
        } catch (error) {
            console.error('Connection error:', error);
            return null;
        }
    }

    /**
     * Disconnect from a device
     */
    async disconnectDevice(deviceId) {
        try {
            await this.manager.cancelDeviceConnection(deviceId);
        } catch (error) {
            console.error('Disconnect error:', error);
        }
    }

    /**
     * Cleanup
     */
    destroy() {
        this.stopScanning();
        this.manager.destroy();
    }
}

export default new BLEService();
