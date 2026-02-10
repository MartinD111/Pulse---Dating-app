import React from 'react';
import { View, Text, StyleSheet, Image } from 'react-native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import PillButton from '../../components/common/PillButton';

const WelcomeScreen = ({ navigation }) => {
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <View style={styles.content}>
                <View style={styles.logoContainer}>
                    <Text style={[styles.title, { color: theme.primary }]}>Pulse</Text>
                    <Text style={[styles.subtitle, { color: theme.textSecondary }]}>
                        Find your rhythm.
                    </Text>
                </View>

                <View style={styles.cardsContainer}>
                    {/* Placeholder for cool graphic/animation */}
                    <View style={[styles.card, { backgroundColor: theme.surfaceGlass, borderColor: theme.border }]}>
                        <Text style={[styles.cardText, { color: theme.text }]}>
                            Connect with people nearby who match your vibe.
                        </Text>
                    </View>
                </View>
            </View>

            <View style={styles.footer}>
                <PillButton
                    title="Get Started"
                    onPress={() => navigation.navigate('Gender')}
                    variant="primary"
                    style={styles.button}
                />
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'space-between',
    },
    content: {
        flex: 1,
        justifyContent: 'center',
        paddingHorizontal: 24,
    },
    logoContainer: {
        alignItems: 'center',
        marginBottom: 48,
    },
    title: {
        fontSize: 48,
        fontWeight: 'bold',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 18,
        letterSpacing: 2,
    },
    cardsContainer: {
        alignItems: 'center',
    },
    card: {
        padding: 24,
        borderRadius: 24,
        borderWidth: 1,
        width: '100%',
    },
    cardText: {
        fontSize: 16,
        textAlign: 'center',
        lineHeight: 24,
    },
    footer: {
        padding: 24,
        paddingBottom: 48,
    },
    button: {
        width: '100%',
        paddingVertical: 18,
    },
});

export default WelcomeScreen;
