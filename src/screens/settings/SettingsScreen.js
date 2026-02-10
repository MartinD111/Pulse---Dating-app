import React, { useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    StatusBar,
    Switch,
    TouchableOpacity,
    Image,
} from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import { toggleDarkMode, toggleRainbowMode, toggleSonarMode } from '../../store/slices/appSlice';
import { setProfile } from '../../store/slices/userSlice';
import {
    setGenderPreference,
    setAgeRange,
    setDistanceRadius,
    setLifestylePreference,
} from '../../store/slices/preferencesSlice';
import GlassCard from '../../components/common/GlassCard';
import PillButton from '../../components/common/PillButton';
import PillInput from '../../components/common/PillInput';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import Slider from '@react-native-community/slider';

const SettingsScreen = () => {
    const dispatch = useDispatch();
    const user = useSelector(state => state.user);
    const preferences = useSelector(state => state.preferences);
    const { isDarkMode, rainbowMode, sonarEnabled } = useSelector(state => state.app);
    const theme = getThemeColors(user.gender, isDarkMode, rainbowMode);

    const [name, setName] = useState(user.name);
    const [age, setAge] = useState(user.age?.toString() || '');

    const handleSaveProfile = () => {
        dispatch(setProfile({
            name,
            age: parseInt(age, 10),
        }));
    };

    const renderSection = (title, children) => (
        <View style={styles.section}>
            <Text style={[styles.sectionTitle, { color: theme.text }]}>{title}</Text>
            <GlassCard style={styles.sectionCard}>{children}</GlassCard>
        </View>
    );

    const renderSettingRow = (icon, label, control) => (
        <View style={styles.settingRow}>
            <View style={styles.settingLeft}>
                <Icon name={icon} size={24} color={theme.primary} style={styles.settingIcon} />
                <Text style={[styles.settingLabel, { color: theme.text }]}>{label}</Text>
            </View>
            {control}
        </View>
    );

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <StatusBar
                barStyle={isDarkMode ? 'light-content' : 'dark-content'}
                backgroundColor={theme.background}
            />

            <View style={styles.header}>
                <Text style={[styles.title, { color: theme.text }]}>Settings</Text>
            </View>

            <ScrollView
                style={styles.scrollView}
                contentContainerStyle={styles.scrollContent}
                showsVerticalScrollIndicator={false}
            >
                {/* Profile Section */}
                {renderSection(
                    'Profile',
                    <>
                        <View style={styles.photoSection}>
                            <Text style={[styles.photoLabel, { color: theme.textSecondary }]}>
                                Photos (max 3)
                            </Text>
                            <View style={styles.photoGrid}>
                                {[0, 1, 2].map((index) => (
                                    <TouchableOpacity
                                        key={index}
                                        style={[styles.photoSlot, { borderColor: theme.border }]}
                                    >
                                        {user.profileImages[index] ? (
                                            <Image
                                                source={{ uri: user.profileImages[index] }}
                                                style={styles.photoImage}
                                            />
                                        ) : (
                                            <Icon name="camera-plus" size={32} color={theme.textSecondary} />
                                        )}
                                    </TouchableOpacity>
                                ))}
                            </View>
                        </View>

                        <PillInput
                            value={name}
                            onChangeText={setName}
                            placeholder="Name"
                            style={styles.input}
                        />

                        <PillInput
                            value={age}
                            onChangeText={setAge}
                            placeholder="Age"
                            keyboardType="numeric"
                            style={styles.input}
                        />

                        <View style={styles.sliderContainer}>
                            <Text style={[styles.sliderLabel, { color: theme.text }]}>
                                Height: {user.height} cm
                            </Text>
                            <Slider
                                style={styles.slider}
                                minimumValue={140}
                                maximumValue={220}
                                value={user.height}
                                onValueChange={(value) =>
                                    dispatch(setProfile({ height: Math.round(value) }))
                                }
                                minimumTrackTintColor={theme.primary}
                                maximumTrackTintColor={theme.border}
                                thumbTintColor={theme.primary}
                            />
                        </View>

                        <View style={styles.sliderContainer}>
                            <Text style={[styles.sliderLabel, { color: theme.text }]}>
                                Personality: {user.personality < 50 ? 'Introvert' : 'Extrovert'}
                            </Text>
                            <View style={styles.personalityLabels}>
                                <Text style={[styles.personalityLabel, { color: theme.textSecondary }]}>
                                    Introvert
                                </Text>
                                <Text style={[styles.personalityLabel, { color: theme.textSecondary }]}>
                                    Extrovert
                                </Text>
                            </View>
                            <Slider
                                style={styles.slider}
                                minimumValue={0}
                                maximumValue={100}
                                value={user.personality}
                                onValueChange={(value) =>
                                    dispatch(setProfile({ personality: Math.round(value) }))
                                }
                                minimumTrackTintColor={theme.primary}
                                maximumTrackTintColor={theme.border}
                                thumbTintColor={theme.primary}
                            />
                        </View>

                        <PillButton title="Save Profile" onPress={handleSaveProfile} />
                    </>
                )}

                {/* Preferences Section */}
                {renderSection(
                    'Preferences',
                    <>
                        <View style={styles.sliderContainer}>
                            <Text style={[styles.sliderLabel, { color: theme.text }]}>
                                Age Range: {preferences.ageRange.min} - {preferences.ageRange.max}
                            </Text>
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

                        <View style={styles.sliderContainer}>
                            <Text style={[styles.sliderLabel, { color: theme.text }]}>
                                Distance: {preferences.distanceRadius}m
                            </Text>
                            <Slider
                                style={styles.slider}
                                minimumValue={50}
                                maximumValue={100}
                                step={10}
                                value={preferences.distanceRadius}
                                onValueChange={(value) => dispatch(setDistanceRadius(value))}
                                minimumTrackTintColor={theme.primary}
                                maximumTrackTintColor={theme.border}
                                thumbTintColor={theme.primary}
                            />
                        </View>

                        {renderSettingRow(
                            'heart',
                            'Relationship',
                            <TouchableOpacity
                                onPress={() =>
                                    dispatch(
                                        setLifestylePreference({
                                            key: 'relationshipType',
                                            value:
                                                preferences.lifestyle.relationshipType === 'longTerm'
                                                    ? 'shortTerm'
                                                    : 'longTerm',
                                        })
                                    )
                                }
                            >
                                <Text style={[styles.settingValue, { color: theme.primary }]}>
                                    {preferences.lifestyle.relationshipType === 'longTerm'
                                        ? 'Long-term'
                                        : 'Short-term'}
                                </Text>
                            </TouchableOpacity>
                        )}

                        {renderSettingRow(
                            'smoking',
                            'Smoking',
                            <Switch
                                value={preferences.lifestyle.smoking === 'smoking'}
                                onValueChange={(value) =>
                                    dispatch(
                                        setLifestylePreference({
                                            key: 'smoking',
                                            value: value ? 'smoking' : 'nonSmoking',
                                        })
                                    )
                                }
                                trackColor={{ false: theme.border, true: theme.primary }}
                                thumbColor={theme.common.white}
                            />
                        )}

                        {renderSettingRow(
                            'run',
                            'Active Lifestyle',
                            <Switch
                                value={preferences.lifestyle.activity === 'active'}
                                onValueChange={(value) =>
                                    dispatch(
                                        setLifestylePreference({
                                            key: 'activity',
                                            value: value ? 'active' : 'inactive',
                                        })
                                    )
                                }
                                trackColor={{ false: theme.border, true: theme.primary }}
                                thumbColor={theme.common.white}
                            />
                        )}

                        {renderSettingRow(
                            preferences.lifestyle.petPreference === 'cat' ? 'cat' : 'dog',
                            'Pet Preference',
                            <TouchableOpacity
                                onPress={() =>
                                    dispatch(
                                        setLifestylePreference({
                                            key: 'petPreference',
                                            value: preferences.lifestyle.petPreference === 'cat' ? 'dog' : 'cat',
                                        })
                                    )
                                }
                            >
                                <Text style={[styles.settingValue, { color: theme.primary }]}>
                                    {preferences.lifestyle.petPreference === 'cat' ? 'Cat' : 'Dog'}
                                </Text>
                            </TouchableOpacity>
                        )}
                    </>
                )}

                {/* Display Section */}
                {renderSection(
                    'Display',
                    <>
                        {renderSettingRow(
                            'theme-light-dark',
                            'Dark Mode',
                            <Switch
                                value={isDarkMode}
                                onValueChange={() => dispatch(toggleDarkMode())}
                                trackColor={{ false: theme.border, true: theme.primary }}
                                thumbColor={theme.common.white}
                            />
                        )}

                        {renderSettingRow(
                            'rainbow',
                            'Rainbow Accents',
                            <Switch
                                value={rainbowMode}
                                onValueChange={() => dispatch(toggleRainbowMode())}
                                trackColor={{ false: theme.border, true: theme.primary }}
                                thumbColor={theme.common.white}
                            />
                        )}

                        {renderSettingRow(
                            'radar',
                            'Sonar Mode',
                            <Switch
                                value={sonarEnabled}
                                onValueChange={() => dispatch(toggleSonarMode())}
                                trackColor={{ false: theme.border, true: theme.primary }}
                                thumbColor={theme.common.white}
                            />
                        )}
                    </>
                )}
            </ScrollView>
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
        paddingBottom: 20,
    },
    title: {
        fontSize: 32,
        fontWeight: 'bold',
    },
    scrollView: {
        flex: 1,
    },
    scrollContent: {
        paddingHorizontal: 24,
        paddingBottom: 40,
    },
    section: {
        marginBottom: 24,
    },
    sectionTitle: {
        fontSize: 20,
        fontWeight: '600',
        marginBottom: 12,
    },
    sectionCard: {
        padding: 20,
    },
    photoSection: {
        marginBottom: 16,
    },
    photoLabel: {
        fontSize: 14,
        marginBottom: 12,
    },
    photoGrid: {
        flexDirection: 'row',
        justifyContent: 'space-between',
    },
    photoSlot: {
        width: '30%',
        aspectRatio: 1,
        borderRadius: 16,
        borderWidth: 2,
        borderStyle: 'dashed',
        justifyContent: 'center',
        alignItems: 'center',
        overflow: 'hidden',
    },
    photoImage: {
        width: '100%',
        height: '100%',
    },
    input: {
        marginBottom: 12,
    },
    sliderContainer: {
        marginBottom: 20,
    },
    sliderLabel: {
        fontSize: 16,
        marginBottom: 8,
    },
    slider: {
        width: '100%',
        height: 40,
    },
    personalityLabels: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 4,
    },
    personalityLabel: {
        fontSize: 12,
    },
    settingRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingVertical: 12,
        borderBottomWidth: 1,
        borderBottomColor: 'rgba(255, 255, 255, 0.1)',
    },
    settingLeft: {
        flexDirection: 'row',
        alignItems: 'center',
        flex: 1,
    },
    settingIcon: {
        marginRight: 12,
    },
    settingLabel: {
        fontSize: 16,
    },
    settingValue: {
        fontSize: 16,
        fontWeight: '600',
    },
});

export default SettingsScreen;
