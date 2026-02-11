import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { setOnboardingCompleted } from '../../store/slices/appSlice';
import { getThemeColors } from '../../theme/colors';
import PillButton from '../../components/common/PillButton';
import PillInput from '../../components/common/PillInput'; // Using PillInput for text entry of prompt if needed
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import Slider from '@react-native-community/slider';

const RegisterStep3Screen = ({ navigation }) => {
    const dispatch = useDispatch();
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const [preferences, setPreferences] = useState({
        minAge: 18,
        maxAge: 35,
        maxDistance: 50, // km
    });

    const handleUpdate = (key, value) => {
        setPreferences(prev => ({ ...prev, [key]: value }));
    };

    const handleFinish = () => {
        // Save preferences if we had a slice for it (e.g., setPreferences in userSlice or preferencesSlice)
        // For now, we assume userSlice handles profile data, and preferences might be separate.
        // But the immediate goal is to finish onboarding.

        dispatch(setOnboardingCompleted(true));
        // AppNavigator should automatically switch to Main stack
    };

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <View style={styles.header}>
                <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
                    <Icon name="arrow-left" size={24} color={theme.text} />
                </TouchableOpacity>
                <Text style={[styles.title, { color: theme.text }]}>Ideal Match</Text>
                <Text style={[styles.subtitle, { color: theme.textSecondary }]}>
                    Who are you looking for?
                </Text>
            </View>

            <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>

                {/* Age Range */}
                <View style={styles.section}>
                    <Text style={[styles.label, { color: theme.text }]}>
                        Age Range: {preferences.minAge} - {preferences.maxAge}
                    </Text>
                    <View style={styles.sliderContainer}>
                        <Text style={[styles.sliderLabel, { color: theme.textSecondary }]}>Min Age</Text>
                        <Slider
                            style={{ width: '100%', height: 40 }}
                            minimumValue={18}
                            maximumValue={60}
                            step={1}
                            value={preferences.minAge}
                            onValueChange={val => {
                                if (val > preferences.maxAge) handleUpdate('maxAge', val);
                                handleUpdate('minAge', val);
                            }}
                            minimumTrackTintColor={theme.primary}
                            maximumTrackTintColor={theme.textSecondary}
                            thumbTintColor={theme.primary}
                        />
                    </View>
                    <View style={styles.sliderContainer}>
                        <Text style={[styles.sliderLabel, { color: theme.textSecondary }]}>Max Age</Text>
                        <Slider
                            style={{ width: '100%', height: 40 }}
                            minimumValue={18}
                            maximumValue={60}
                            step={1}
                            value={preferences.maxAge}
                            onValueChange={val => {
                                if (val < preferences.minAge) handleUpdate('minAge', val);
                                handleUpdate('maxAge', val);
                            }}
                            minimumTrackTintColor={theme.primary}
                            maximumTrackTintColor={theme.textSecondary}
                            thumbTintColor={theme.primary}
                        />
                    </View>
                </View>

                {/* Distance */}
                <View style={styles.section}>
                    <Text style={[styles.label, { color: theme.text }]}>
                        Max Distance: {preferences.maxDistance} km
                    </Text>
                    <View style={styles.sliderContainer}>
                        <Slider
                            style={{ width: '100%', height: 40 }}
                            minimumValue={5}
                            maximumValue={150}
                            step={5}
                            value={preferences.maxDistance}
                            onValueChange={val => handleUpdate('maxDistance', val)}
                            minimumTrackTintColor={theme.primary}
                            maximumTrackTintColor={theme.textSecondary}
                            thumbTintColor={theme.primary}
                        />
                    </View>
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
        marginBottom: 32,
    },
    backButton: {
        marginBottom: 16,
        padding: 4,
        alignSelf: 'flex-start',
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
        paddingBottom: 20,
    },
    section: {
        marginBottom: 32,
    },
    label: {
        fontSize: 18,
        fontWeight: '600',
        marginBottom: 16,
    },
    sliderContainer: {
        marginBottom: 16,
    },
    sliderLabel: {
        fontSize: 12,
        marginBottom: 4,
    },
    footer: {
        paddingTop: 16,
    },
    button: {
        width: '100%',
        paddingVertical: 18,
    },
});

export default RegisterStep3Screen;
