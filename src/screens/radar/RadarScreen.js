import React from 'react';
import { View, Text, StyleSheet, StatusBar, TouchableOpacity } from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import { toggleSearching } from '../../store/slices/appSlice';
import PillButton from '../../components/common/PillButton';
import RadarAnimation from '../../components/radar/RadarAnimation';

const RadarScreen = () => {
    const dispatch = useDispatch();
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode, isSearching } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const handleToggleSearch = () => {
        dispatch(toggleSearching());
        // TODO: Start/stop background BLE and location services
    };

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <StatusBar
                barStyle={isDarkMode ? 'light-content' : 'dark-content'}
                backgroundColor={theme.background}
            />

            <View style={styles.header}>
                <Text style={[styles.title, { color: theme.text }]}>Pulse</Text>
                <Text style={[styles.subtitle, { color: theme.textSecondary }]}>
                    {isSearching ? 'Searching for matches...' : 'Ready to discover'}
                </Text>
            </View>

            <TouchableOpacity
                style={styles.radarContainer}
                onPress={handleToggleSearch}
                activeOpacity={0.9}
            >
                <RadarAnimation isActive={isSearching} />
            </TouchableOpacity>

            <View style={styles.buttonContainer}>
                <PillButton
                    title={isSearching ? 'Stop Searching' : 'Start Searching'}
                    onPress={handleToggleSearch}
                    variant="primary"
                    icon={isSearching ? 'stop-circle' : 'radar'}
                    style={styles.mainButton}
                />
            </View>

            {isSearching && (
                <View style={styles.statusContainer}>
                    <Text style={[styles.statusText, { color: theme.textSecondary }]}>
                        Scanning nearby... Keep your phone with you
                    </Text>
                </View>
            )}
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    header: {
        paddingTop: 60,
        paddingHorizontal: 24,
        alignItems: 'center',
    },
    title: {
        fontSize: 32,
        fontWeight: 'bold',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 16,
    },
    radarContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    buttonContainer: {
        paddingHorizontal: 24,
        paddingBottom: 40,
    },
    mainButton: {
        paddingVertical: 18,
    },
    statusContainer: {
        paddingHorizontal: 24,
        paddingBottom: 20,
        alignItems: 'center',
    },
    statusText: {
        fontSize: 14,
        textAlign: 'center',
    },
});

export default RadarScreen;
