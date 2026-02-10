import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { setProfile } from '../../store/slices/userSlice';
import { getThemeColors } from '../../theme/colors';
import PillButton from '../../components/common/PillButton';
import PillInput from '../../components/common/PillInput';

const ProfileDetailsScreen = ({ navigation }) => {
    const dispatch = useDispatch();
    const { gender, name, age, height, hairColor, jobStatus, education } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const [form, setForm] = useState({
        name: name || '',
        age: age ? String(age) : '',
        height: height ? String(height) : '',
        hairColor: hairColor || 'brown',
        jobStatus: jobStatus || 'employed',
        education: education || 'bachelors',
    });

    const handleUpdate = (key, value) => {
        setForm(prev => ({ ...prev, [key]: value }));
    };

    const handleNext = () => {
        dispatch(setProfile({
            name: form.name,
            age: parseInt(form.age, 10),
            height: parseInt(form.height, 10),
            hairColor: form.hairColor,
            jobStatus: form.jobStatus,
            education: form.education,
        }));
        navigation.navigate('Interests');
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
            <View style={styles.header}>
                <Text style={[styles.title, { color: theme.text }]}>About You</Text>
            </View>

            <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
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
                        <PillInput
                            placeholder="Height"
                            value={form.height}
                            onChangeText={text => handleUpdate('height', text)}
                            keyboardType="numeric"
                        />
                    </View>
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
            </ScrollView>

            <View style={styles.footer}>
                <PillButton
                    title="Next"
                    onPress={handleNext}
                    disabled={!form.name || !form.age || !form.height}
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
    },
    content: {
        flex: 1,
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
        paddingTop: 16,
    },
    button: {
        width: '100%',
        paddingVertical: 18,
    },
});

export default ProfileDetailsScreen;
