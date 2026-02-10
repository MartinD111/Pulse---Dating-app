import React from 'react';
import { View, Text, StyleSheet, ScrollView, StatusBar, TouchableOpacity } from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import { getThemeColors } from '../../../theme/colors';
import {
    setGenderPreference,
    setAgeRange,
    setDistanceRadius,
} from '../../../store/slices/preferencesSlice';
import GlassCard from '../../../components/common/GlassCard';
import PillButton from '../../../components/common/PillButton';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import Slider from '@react-native-community/slider';

const PreferencesScreen = ({ navigation }) => {
    const dispatch = useDispatch();
    const { gender, isPremium } = useSelector(state => state.user);
    const preferences = useSelector(state => state.preferences);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    // Premium users: 10-100m, Free users: 10-50m
    const maxRadius = isPremium ? 100 : 50;

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <StatusBar
                barStyle={isDarkMode ? 'light-content' : 'dark-content'}
                backgroundColor={theme.background}
            />

            <View style={styles.header}>
                <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
                    <Icon name="arrow-left" size={24} color={theme.text} />
                </TouchableOpacity>
                <Text style={[styles.title, { color: theme.text }]}>Preferences</Text>
                <View style={styles.placeholder} />
            </View>

            <ScrollView
                style={styles.scrollView}
                contentContainerStyle={styles.scrollContent}
                showsVerticalScrollIndicator={false}
            >
                <GlassCard style={styles.card}>
                    <View style={styles.section}>
                        <Text style={[styles.sectionTitle, { color: theme.text }]}>Matching Preferences</Text>

                        <View style={styles.preferenceItem}>
                            <Text style={[styles.label, { color: theme.textSecondary }]}>Gender Preference</Text>
                            <View style={styles.optionsRow}>
                                <PillButton
                                    title="Female"
                                    onPress={() => dispatch(setGenderPreference('female'))}
                                    variant={preferences.genderPreference === 'female' ? 'primary' : 'outline'}
                                    style={styles.optionPill}
                                    textStyle={styles.optionText}
                                />
                                <PillButton
                                    title="Male"
                                    onPress={() => dispatch(setGenderPreference('male'))}
                                    variant={preferences.genderPreference === 'male' ? 'primary' : 'outline'}
                                    style={styles.optionPill}
                                    textStyle={styles.optionText}
                                />
                                <PillButton
                                    title="All"
                                    onPress={() => dispatch(setGenderPreference('all'))}
                                    variant={preferences.genderPreference === 'all' ? 'primary' : 'outline'}
                                    style={styles.optionPill}
                                    textStyle={styles.optionText}
                                />
                            </View>
                        </View>

                        <View style={styles.preferenceItem}>
                            <Text style={[styles.label, { color: theme.textSecondary }]}>
                                Age Range: {preferences.ageRange.min} - {preferences.ageRange.max}
                            </Text>
                            <View style={styles.sliderLabels}>
                                <Text style={[styles.sliderLabelText, { color: theme.textSecondary }]}>
                                    Min: {preferences.ageRange.min}
                                </Text>
                                <Text style={[styles.sliderLabelText, { color: theme.textSecondary }]}>
                                    Max: {preferences.ageRange.max}
                                </Text>
                            </View>
                            <Slider
                                style={styles.slider}
                                minimumValue={18}
                                maximumValue={80}
                                value={preferences.ageRange.min}
                                onValueChange={(value) =>
                                    dispatch(
                                        setAgeRange({
                                            ...preferences.ageRange,
                                            min: Math.round(value),
                                        })
                                    )
                                }
                                minimumTrackTintColor={theme.primary}
                                maximumTrackTintColor={theme.border}
                                thumbTintColor={theme.primary}
                            />
                            <Slider
                                style={styles.slider}
                                minimumValue={18}
                                maximumValue={80}
                                value={preferences.ageRange.max}
                                onValueChange={(value) =>
                                    dispatch(
                                        setAgeRange({
                                            ...preferences.ageRange,
                                            max: Math.round(value),
                                        })
                                    )
                                }
                                minimumTrackTintColor={theme.primary}
                                maximumTrackTintColor={theme.border}
                                thumbTintColor={theme.primary}
                            />
                        </View>

                        <View style={styles.preferenceItem}>
                            <View style={styles.radiusHeader}>
                                <Text style={[styles.label, { color: theme.textSecondary }]}>
                                    Search Radius: {preferences.distanceRadius}m
                                </Text>
                                {!isPremium && (
                                    <View style={[styles.premiumBadge, { backgroundColor: theme.accent }]}>
                                        <Icon name="crown" size={12} color="#FFF" />
                                        <Text style={styles.premiumText}>Premium: up to 100m</Text>
                                    </View>
                                )}
                            </View>
                            <Slider
                                style={styles.slider}
                                minimumValue={10}
                                maximumValue={maxRadius}
                                step={10}
                                value={Math.min(preferences.distanceRadius, maxRadius)}
                                onValueChange={(value) => dispatch(setDistanceRadius(value))}
                                minimumTrackTintColor={theme.primary}
                                maximumTrackTintColor={theme.border}
                                thumbTintColor={theme.primary}
                            />
                            <View style={styles.sliderLabels}>
                                <Text style={[styles.sliderLabelText, { color: theme.textSecondary }]}>10m</Text>
                                <Text style={[styles.sliderLabelText, { color: theme.textSecondary }]}>
                                    {maxRadius}m
                                </Text>
                            </View>
                        </View>
                    </View>
                </GlassCard>
            </ScrollView>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingTop: 60,
        paddingHorizontal: 24,
        paddingBottom: 20,
    },
    backButton: {
        width: 40,
        height: 40,
        justifyContent: 'center',
        alignItems: 'flex-start',
    },
    title: {
        fontSize: 20,
        fontWeight: 'bold',
    },
    placeholder: {
        width: 40,
    },
    scrollView: {
        flex: 1,
    },
    scrollContent: {
        paddingHorizontal: 24,
        paddingBottom: 40,
    },
    card: {
        padding: 20,
    },
    section: {
        marginBottom: 12,
    },
    sectionTitle: {
        fontSize: 18,
        fontWeight: '600',
        marginBottom: 20,
    },
    preferenceItem: {
        marginBottom: 32,
    },
    label: {
        fontSize: 16,
        marginBottom: 12,
        marginLeft: 4,
    },
    optionsRow: {
        flexDirection: 'row',
        gap: 8,
    },
    optionPill: {
        flex: 1,
        paddingVertical: 12,
    },
    optionText: {
        fontSize: 14,
    },
    slider: {
        width: '100%',
        height: 40,
    },
    sliderLabels: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginTop: 4,
    },
    sliderLabelText: {
        fontSize: 12,
    },
    radiusHeader: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        marginBottom: 12,
    },
    premiumBadge: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 8,
        paddingVertical: 4,
        borderRadius: 12,
        gap: 4,
    },
    premiumText: {
        color: '#FFF',
        fontSize: 11,
        fontWeight: '600',
    },
});

export default PreferencesScreen;
