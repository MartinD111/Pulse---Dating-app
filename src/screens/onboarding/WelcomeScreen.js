import React from 'react';
import { View, Text, StyleSheet, Image } from 'react-native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import PillButton from '../../components/common/PillButton';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import auth from '@react-native-firebase/auth';

const WelcomeScreen = ({ navigation }) => {
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const onGoogleButtonPress = async () => {
        try {
            // Get the users ID token
            const { idToken } = await GoogleSignin.signIn();

            // Create a Google credential with the token
            const googleCredential = auth.GoogleAuthProvider.credential(idToken);

            // Sign-in the user with the credential
            // TODO: Ensure user exists in Firestore or handle creating new user here
            // Sign-in the user with the credential
            await auth().signInWithCredential(googleCredential);
            // Google Sign-In skips password/email but needs profile setup
            // We'll navigate to ProfileDetails to ensure name/age/etc are set if missing
            // But AppNavigator might auto-direct based on onboardingCompleted.
            // Let's force navigation to Gender or ProfileDetails just in case.
            navigation.navigate('Gender');
        } catch (error) {
            console.error(error);
        }
    };

    React.useEffect(() => {
        GoogleSignin.configure({
            webClientId: 'YOUR_WEB_CLIENT_ID', // TODO: Add webClientId
        });
    }, []);

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
                    title="Sign In"
                    onPress={() => navigation.navigate('Gender')} // TODO: Change this to Login Screen if implemented, or keep as is for "Sign In" flow which seems to default to Gender/Profile check?
                    // User said: "če ga imamo pa naj ostane tako kot je sign in" (If we have it, keep it as is sign in)
                    // Currently "Get Started" went to Gender. I'll keep it pointing there but change text.
                    variant="primary"
                    style={styles.button}
                />

                <View style={{ height: 16 }} />

                <PillButton
                    title="I don't have an account"
                    onPress={() => navigation.navigate('Register')}
                    variant="outline"
                    style={styles.button}
                />

                <View style={{ height: 16 }} />

                <PillButton
                    title="Sign in with Google"
                    onPress={onGoogleButtonPress}
                    variant="glass"
                    icon="google"
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
