import React from 'react';
import { View, Text, StyleSheet, StatusBar, TouchableOpacity } from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import { toggleSearching } from '../../store/slices/appSlice';
import PillButton from '../../components/common/PillButton';
import RadarAnimation from '../../components/radar/RadarAnimation';
import SonarPing from '../../components/radar/SonarPing';
import MatchNotification from '../../components/notifications/MatchNotification';

const RadarScreen = ({ navigation }) => {
    const dispatch = useDispatch();
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode, isSearching, sonarEnabled } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const [matchNotificationVisible, setMatchNotificationVisible] = React.useState(false);
    const [prospectMatch, setProspectMatch] = React.useState(null);
    const [sonarMatch, setSonarMatch] = React.useState(null);
    const [sonarProgress, setSonarProgress] = React.useState(0);

    const handleToggleSearch = () => {
        dispatch(toggleSearching());
        // Reset states when stopping
        if (isSearching) {
            setMatchNotificationVisible(false);
            setSonarMatch(null);
            setSonarProgress(0);
        }
    };

    // Simulation: Find a match after random time
    React.useEffect(() => {
        let timeout;
        if (isSearching && !prospectMatch && !sonarMatch) {
            const randomDelay = Math.random() * 5000 + 2000; // 2-7 seconds
            timeout = setTimeout(() => {
                const mockMatch = {
                    id: Date.now(),
                    name: 'Sarah',
                    age: 24,
                    distance: 150,
                    hobbies: ['travel', 'music', 'photography'],
                    uid: 'mock-uid-' + Date.now(),
                };
                setProspectMatch(mockMatch);
                setMatchNotificationVisible(true);
            }, randomDelay);
        }
        return () => clearTimeout(timeout);
    }, [isSearching, prospectMatch, sonarMatch]);

    // Simulation: Sonar Progress
    React.useEffect(() => {
        let interval;
        if (sonarMatch && sonarEnabled) {
            interval = setInterval(() => {
                setSonarProgress(prev => {
                    const next = prev + 0.05; // Move 5% every 100ms
                    if (next >= 1) {
                        clearInterval(interval);
                        // Arrival logic could go here
                        return 1;
                    }
                    return next;
                });
            }, 100);
        }
        return () => clearInterval(interval);
    }, [sonarMatch, sonarEnabled]);

    const handleGreet = () => {
        setMatchNotificationVisible(false);
        // Simulate "Waiting for acceptance" -> "Accepted"
        setTimeout(() => {
            if (sonarEnabled) {
                setSonarMatch(prospectMatch);
                setProspectMatch(null);
            } else {
                // Determine what happens if sonar is disabled (e.g. just add to matches list directly)
                setProspectMatch(null);
            }
        }, 1500);
    };

    const handleIgnore = () => {
        setMatchNotificationVisible(false);
        setProspectMatch(null);
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
                {sonarMatch && sonarEnabled ? (
                    <SonarPing isActive={true} progress={sonarProgress} />
                ) : (
                    <RadarAnimation isActive={isSearching} />
                )}
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

            {isSearching && !sonarMatch && (
                <View style={styles.statusContainer}>
                    <Text style={[styles.statusText, { color: theme.textSecondary }]}>
                        Scanning nearby... Keep your phone with you
                    </Text>
                </View>
            )}

            {sonarMatch && (
                <View style={styles.statusContainer}>
                    <Text style={[styles.statusText, { color: theme.primary, fontWeight: 'bold' }]}>
                        {sonarProgress < 1 ? 'Match approaching!' : 'Match Arrived!'}
                    </Text>
                </View>
            )}

            <MatchNotification
                visible={matchNotificationVisible}
                match={prospectMatch}
                onGreet={handleGreet}
                onIgnore={handleIgnore}
                onViewProfile={() => {
                    setMatchNotificationVisible(false);
                    navigation.navigate('ProfileDetail', { match: prospectMatch, onGreet: handleGreet, onIgnore: handleIgnore, isPending: true });
                }}
            />
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
