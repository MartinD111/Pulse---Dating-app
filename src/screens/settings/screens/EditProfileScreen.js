import React, { useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    StatusBar,
    TouchableOpacity,
    Image,
} from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import { getThemeColors } from '../../../theme/colors';
import { setProfile } from '../../../store/slices/userSlice';
import GlassCard from '../../../components/common/GlassCard';
import PillButton from '../../../components/common/PillButton';
import PillInput from '../../../components/common/PillInput';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import Slider from '@react-native-community/slider';

const EditProfileScreen = ({ navigation }) => {
    const dispatch = useDispatch();
    const user = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(user.gender, isDarkMode, rainbowMode);

    const [form, setForm] = useState({
        name: user.name || '',
        age: user.age ? String(user.age) : '',
        height: user.height || 170,
        hairColor: user.hairColor || 'brown',
        jobStatus: user.jobStatus || 'employed',
        education: user.education || 'bachelors',
    });

    const handleUpdate = (key, value) => {
        setForm(prev => ({ ...prev, [key]: value }));
    };

    const handleSave = () => {
        dispatch(setProfile({
            name: form.name,
            age: parseInt(form.age, 10),
            height: form.height,
            hairColor: form.hairColor,
            jobStatus: form.jobStatus,
            education: form.education,
        }));
        navigation.goBack();
    };

    const renderOption = (key, value, label) => (
        <PillButton
            key={value}
            title={label}
            onPress={() => handleUpdate(key, value)}
            variant={form[key] === value ? 'primary' : 'outline'}
            style={styles.smallPill}
            textStyle={styles.smallPillText}
        />
    );

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
                <Text style={[styles.title, { color: theme.text }]}>Edit Profile</Text>
                <View style={styles.placeholder} />
            </View>

            <ScrollView
                style={styles.scrollView}
                contentContainerStyle={styles.scrollContent}
                showsVerticalScrollIndicator={false}
            >
                <GlassCard style={styles.card}>
                    <View style={styles.section}>
                        <Text style={[styles.label, { color: theme.textSecondary }]}>Name</Text>
                        <PillInput
                            placeholder="Your Name"
                            value={form.name}
                            onChangeText={text => handleUpdate('name', text)}
                        />
                    </View>

                    <View style={styles.row}>
                        <View style={[styles.section, { flex: 1, marginRight: 8 }]}>
                            <Text style={[styles.label, { color: theme.textSecondary }]}>Age</Text>
                            <PillInput
                                placeholder="Age"
                                value={form.age}
                                onChangeText={text => handleUpdate('age', text)}
                                keyboardType="numeric"
                            />
                        </View>
                        <View style={[styles.section, { flex: 1, marginLeft: 8 }]}>
                            <Text style={[styles.label, { color: theme.textSecondary }]}>Height (cm)</Text>
                            <Text style={[styles.heightValue, { color: theme.text }]}>{form.height}</Text>
                        </View>
                    </View>

                    <View style={styles.section}>
                        <Slider
                            style={styles.slider}
                            minimumValue={140}
                            maximumValue={220}
                            value={form.height}
                            onValueChange={(value) => handleUpdate('height', Math.round(value))}
                            minimumTrackTintColor={theme.primary}
                            maximumTrackTintColor={theme.border}
                            thumbTintColor={theme.primary}
                        />
                    </View>

                    <View style={styles.section}>
                        <Text style={[styles.label, { color: theme.textSecondary }]}>Hair Color</Text>
                        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.optionsScroll}>
                            {renderOption('hairColor', 'black', 'Black')}
                            {renderOption('hairColor', 'brown', 'Brown')}
                            {renderOption('hairColor', 'blonde', 'Blonde')}
                            {renderOption('hairColor', 'red', 'Red')}
                            {renderOption('hairColor', 'gray', 'Gray')}
                            {renderOption('hairColor', 'other', 'Other')}
                        </ScrollView>
                    </View>

                    <View style={styles.section}>
                        <Text style={[styles.label, { color: theme.textSecondary }]}>Job Status</Text>
                        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.optionsScroll}>
                            {renderOption('jobStatus', 'student', 'Student')}
                            {renderOption('jobStatus', 'employed', 'Employed')}
                            {renderOption('jobStatus', 'unemployed', 'Unemployed')}
                        </ScrollView>
                    </View>

                    <View style={styles.section}>
                        <Text style={[styles.label, { color: theme.textSecondary }]}>Education</Text>
                        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.optionsScroll}>
                            {renderOption('education', 'highSchool', 'High School')}
                            {renderOption('education', 'bachelors', 'Bachelors')}
                            {renderOption('education', 'masters', 'Masters')}
                            {renderOption('education', 'phd', 'PhD')}
                        </ScrollView>
                    </View>
                </GlassCard>
            </ScrollView>

            <View style={styles.footer}>
                <PillButton
                    title="Save Changes"
                    onPress={handleSave}
                    disabled={!form.name || !form.age}
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
        paddingBottom: 20,
    },
    card: {
        padding: 20,
    },
    section: {
        marginBottom: 24,
    },
    row: {
        flexDirection: 'row',
    },
    label: {
        fontSize: 16,
        marginBottom: 8,
        marginLeft: 4,
    },
    heightValue: {
        fontSize: 32,
        fontWeight: 'bold',
        textAlign: 'center',
        marginTop: 8,
    },
    slider: {
        width: '100%',
        height: 40,
    },
    optionsScroll: {
        flexDirection: 'row',
    },
    smallPill: {
        marginRight: 8,
        paddingHorizontal: 16,
        paddingVertical: 10,
        minWidth: 80,
    },
    smallPillText: {
        fontSize: 14,
    },
    footer: {
        padding: 24,
        paddingBottom: 40,
    },
    button: {
        width: '100%',
        paddingVertical: 18,
    },
});

export default EditProfileScreen;
