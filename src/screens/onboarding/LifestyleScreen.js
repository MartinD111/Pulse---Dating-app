import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { setProfile, setAuthenticated } from '../../store/slices/userSlice';
import { setOnboardingCompleted } from '../../store/slices/appSlice';
import { getThemeColors } from '../../theme/colors';
import PillButton from '../../components/common/PillButton';

const LifestyleScreen = ({ navigation }) => {
    const dispatch = useDispatch();
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const [preferences, setPreferences] = useState({
        smoking: 'nonSmoking',
        drinking: 'socially',
        pets: 'none',
        workout: 'active',
    });

    const handleUpdate = (key, value) => {
        setPreferences(prev => ({ ...prev, [key]: value }));
    };

    const handleFinish = () => {
        // Save lifestyle preferences context (if we had a specific field, or just dump into profile/lifestyle)
        // For now, let's assume we save it to the user profile or just proceed.
        // The current userSlice doesn't have specific lifestyle fields in the root, but we can add them or ignore for MVP.
        // Let's just proceed to completion.

        // Mark onboarding as completed
        dispatch(setOnboardingCompleted(true));

        // If not authenticated (demo mode), set authenticated to true to show main app
        // In a real app, we'd probably have a signup step before this or during this.
        // For this MVP, we assume "Login" happened before or this IS the signup.
        // Let's assume user is authenticated if they reached here.

        // dispatch(setAuthenticated({ isAuthenticated: true, uid: '123', email: 'test@test.com' })); 
        // Logic above is handled by AppNavigator observing onboardingCompleted.
    };

    const renderOption = (key, value, label) => (
        <PillButton
            key={value}
            title={label}
            onPress={() => handleUpdate(key, value)}
            variant={preferences[key] === value ? 'primary' : 'outline'}
            style={styles.smallPill}
            textStyle={styles.smallPillText}
        />
    );

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <View style={styles.header}>
                <Text style={[styles.title, { color: theme.text }]}>Lifestyle</Text>
                <Text style={[styles.subtitle, { color: theme.textSecondary }]}>
                    Almost there! How do you live?
                </Text>
            </View>

            <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
                <View style={styles.section}>
                    <Text style={[styles.label, { color: theme.textSecondary }]}>Smoking</Text>
                    <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.optionsScroll}>
                        {renderOption('smoking', 'smoking', 'Smoker')}
                        {renderOption('smoking', 'nonSmoking', 'Non-smoker')}
                        {renderOption('smoking', 'socially', 'Socially')}
                    </ScrollView>
                </View>

                <View style={styles.section}>
                    <Text style={[styles.label, { color: theme.textSecondary }]}>Drinking</Text>
                    <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.optionsScroll}>
                        {renderOption('drinking', 'yes', 'Yes')}
                        {renderOption('drinking', 'no', 'No')}
                        {renderOption('drinking', 'socially', 'Socially')}
                    </ScrollView>
                </View>

                <View style={styles.section}>
                    <Text style={[styles.label, { color: theme.textSecondary }]}>Pets</Text>
                    <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.optionsScroll}>
                        {renderOption('pets', 'dog', 'Dog')}
                        {renderOption('pets', 'cat', 'Cat')}
                        {renderOption('pets', 'both', 'Both')}
                        {renderOption('pets', 'none', 'None')}
                    </ScrollView>
                </View>

                <View style={styles.section}>
                    <Text style={[styles.label, { color: theme.textSecondary }]}>Workout</Text>
                    <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.optionsScroll}>
                        {renderOption('workout', 'active', 'Active')}
                        {renderOption('workout', 'sometimes', 'Sometimes')}
                        {renderOption('workout', 'never', 'Never')}
                    </ScrollView>
                </View>
            </ScrollView>

            <View style={styles.footer}>
                <PillButton
                    title="Finish Setup"
                    onPress={handleFinish}
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
        padding: 24,
    },
    header: {
        marginTop: 40,
        marginBottom: 20,
    },
    title: {
        fontSize: 32,
        fontWeight: 'bold',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 16,
    },
    content: {
        flex: 1,
    },
    section: {
        marginBottom: 32,
    },
    label: {
        fontSize: 16,
        marginBottom: 12,
        marginLeft: 4,
    },
    optionsScroll: {
        flexDirection: 'row',
    },
    smallPill: {
        marginRight: 12,
        paddingHorizontal: 20,
        paddingVertical: 12,
        minWidth: 90,
    },
    smallPillText: {
        fontSize: 14,
    },
    footer: {
        paddingTop: 16,
    },
    button: {
        width: '100%',
        paddingVertical: 18,
    },
});

export default LifestyleScreen;
