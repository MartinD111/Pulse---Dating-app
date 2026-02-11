import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert, Platform } from 'react-native';
import { useDispatch } from 'react-redux';
import LinearGradient from 'react-native-linear-gradient';
import { setProfile, setGender, setAuthenticated } from '../../store/slices/userSlice';
import PillButton from '../../components/common/PillButton';
import PillInput from '../../components/common/PillInput';
import auth from '@react-native-firebase/auth';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const RegisterStep1Screen = ({ navigation }) => {
    const dispatch = useDispatch();

    const [form, setForm] = useState({
        name: '',
        day: '',
        month: '',
        year: '',
        gender: '', // 'male' | 'female'
        interestedIn: '', // 'male' | 'female' | 'both'
        email: '',
        password: '',
    });

    const [loading, setLoading] = useState(false);

    const handleUpdate = (key, value) => {
        setForm(prev => ({ ...prev, [key]: value }));
    };

    const validateAge = () => {
        const { day, month, year } = form;
        if (!day || !month || !year) return false;

        const birthDate = new Date(year, month - 1, day);
        const today = new Date();
        let age = today.getFullYear() - birthDate.getFullYear();
        const m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }
        return { isValid: age >= 18, age };
    };

    const handleNext = async () => {
        // Validation
        if (!form.name || !form.email || !form.password || !form.gender || !form.interestedIn) {
            Alert.alert('Missing Fields', 'Please fill in all fields.');
            return;
        }

        const { isValid, age } = validateAge();
        if (!isValid) {
            Alert.alert('Age Restriction', 'You must be at least 18 years old to use Pulse.');
            return;
        }

        setLoading(true);
        try {
            // Create Account
            await auth().createUserWithEmailAndPassword(form.email, form.password);

            // Save Profile Data
            dispatch(setGender(form.gender));
            dispatch(setProfile({
                name: form.name,
                age: age,
                interestedIn: form.interestedIn,
            }));

            // Navigate to Next Step
            // Note: Auth listener might trigger re-renders, but since we are inside Onboarding stack
            // and onboardingCompleted is false, we should remain in this stack.
            navigation.navigate('RegisterStep2');
        } catch (error) {
            console.error(error);
            let msg = error.message;
            if (error.code === 'auth/email-already-in-use') msg = 'Email already in use.';
            if (error.code === 'auth/invalid-email') msg = 'Invalid email address.';
            if (error.code === 'auth/weak-password') msg = 'Password is too weak.';
            Alert.alert('Registration Error', msg);
        } finally {
            setLoading(false);
        }
    };

    const renderGenderOption = (value, label, field) => {
        const isSelected = form[field] === value;
        return (
            <TouchableOpacity
                style={[
                    styles.genderOption,
                    isSelected && styles.genderOptionSelected,
                    { borderColor: isSelected ? '#FFF' : 'rgba(255,255,255,0.3)' }
                ]}
                onPress={() => handleUpdate(field, value)}
            >
                <Text style={[styles.genderText, { color: isSelected ? '#FFF' : 'rgba(255,255,255,0.7)' }]}>
                    {label}
                </Text>
            </TouchableOpacity>
        );
    };

    return (
        <View style={styles.container}>
            {/* Split Gradient Background: Pink (Left/Top) -> Blue (Right/Bottom) 
                User requested: "polovica roza in polovica modra, oboje gradient"
                Let's use a LinearGradient from TopLeft to BottomRight
            */}
            <LinearGradient
                colors={['#FFB3D9', '#87CEEB']} // Pink to Light Blue
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={StyleSheet.absoluteFill}
            />

            {/* Glass Overlay for Content */}
            <View style={styles.glassOverlay}>
                <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>

                    <View style={styles.header}>
                        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
                            <Icon name="arrow-left" size={24} color="#FFF" />
                        </TouchableOpacity>
                        <Text style={styles.title}>Create Account</Text>
                    </View>

                    <View style={styles.section}>
                        <Text style={styles.label}>My Name</Text>
                        <PillInput
                            placeholder="Your Name"
                            value={form.name}
                            onChangeText={text => handleUpdate('name', text)}
                            style={styles.input}
                        />
                    </View>

                    <View style={styles.section}>
                        <Text style={styles.label}>Date of Birth</Text>
                        <View style={styles.dobContainer}>
                            <PillInput
                                placeholder="DD"
                                value={form.day}
                                onChangeText={text => handleUpdate('day', text)}
                                keyboardType="numeric"
                                maxLength={2}
                                style={styles.dobInput}
                            />
                            <PillInput
                                placeholder="MM"
                                value={form.month}
                                onChangeText={text => handleUpdate('month', text)}
                                keyboardType="numeric"
                                maxLength={2}
                                style={styles.dobInput}
                            />
                            <PillInput
                                placeholder="YYYY"
                                value={form.year}
                                onChangeText={text => handleUpdate('year', text)}
                                keyboardType="numeric"
                                maxLength={4}
                                style={[styles.dobInput, { flex: 2 }]}
                            />
                        </View>
                    </View>

                    <View style={styles.section}>
                        <Text style={styles.label}>I am a...</Text>
                        <View style={styles.genderRow}>
                            {renderGenderOption('male', 'Male', 'gender')}
                            {renderGenderOption('female', 'Female', 'gender')}
                        </View>
                    </View>

                    <View style={styles.section}>
                        <Text style={styles.label}>Interested in...</Text>
                        <View style={styles.genderRow}>
                            {renderGenderOption('female', 'Women', 'interestedIn')}
                            {renderGenderOption('male', 'Men', 'interestedIn')}
                            {renderGenderOption('both', 'Both', 'interestedIn')}
                        </View>
                    </View>

                    <View style={styles.section}>
                        <Text style={styles.label}>Email</Text>
                        <PillInput
                            placeholder="email@example.com"
                            value={form.email}
                            onChangeText={text => handleUpdate('email', text)}
                            keyboardType="email-address"
                            autoCapitalize="none"
                            style={styles.input}
                        />
                    </View>

                    <View style={styles.section}>
                        <Text style={styles.label}>Password</Text>
                        <PillInput
                            placeholder="••••••••"
                            value={form.password}
                            onChangeText={text => handleUpdate('password', text)}
                            secureTextEntry
                            style={styles.input}
                        />
                    </View>

                    <View style={styles.footer}>
                        <PillButton
                            title="Next Step"
                            onPress={handleNext}
                            loading={loading}
                            variant="primary"
                            style={styles.button}
                            textStyle={styles.buttonText}
                        />
                    </View>

                </ScrollView>
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    glassOverlay: {
        flex: 1,
        backgroundColor: 'rgba(255, 255, 255, 0.2)', // Slight white tint for glass effect
        paddingTop: Platform.OS === 'android' ? 24 : 0,
    },
    scrollContent: {
        padding: 24,
        paddingTop: 40,
        paddingBottom: 40,
    },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 32,
    },
    backButton: {
        padding: 8,
        marginRight: 16,
        backgroundColor: 'rgba(255,255,255,0.2)',
        borderRadius: 20,
    },
    title: {
        fontSize: 28,
        fontWeight: 'bold',
        color: '#FFF',
        textShadowColor: 'rgba(0,0,0,0.1)',
        textShadowOffset: { width: 0, height: 1 },
        textShadowRadius: 4,
    },
    section: {
        marginBottom: 24,
    },
    label: {
        fontSize: 16,
        color: '#FFF',
        marginBottom: 8,
        marginLeft: 4,
        fontWeight: '600',
        textShadowColor: 'rgba(0,0,0,0.1)',
        textShadowOffset: { width: 0, height: 1 },
        textShadowRadius: 2,
    },
    input: {
        backgroundColor: 'rgba(255,255,255,0.25)',
        borderColor: 'rgba(255,255,255,0.4)',
        color: '#FFF',
    },
    dobContainer: {
        flexDirection: 'row',
        gap: 12,
    },
    dobInput: {
        flex: 1,
        backgroundColor: 'rgba(255,255,255,0.25)',
        borderColor: 'rgba(255,255,255,0.4)',
        color: '#FFF',
    },
    genderRow: {
        flexDirection: 'row',
        gap: 12,
    },
    genderOption: {
        flex: 1,
        paddingVertical: 14,
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: 'rgba(255,255,255,0.15)',
        borderRadius: 24,
        borderWidth: 1,
    },
    genderOptionSelected: {
        backgroundColor: 'rgba(255,255,255,0.4)',
        borderColor: '#FFF',
        borderWidth: 2,
    },
    genderText: {
        fontSize: 16,
        fontWeight: '600',
    },
    footer: {
        marginTop: 16,
    },
    button: {
        backgroundColor: 'rgba(255,255,255,0.8)',
        borderWidth: 0,
    },
    buttonText: {
        color: '#333',
        fontWeight: 'bold',
        fontSize: 16,
    },
});

export default RegisterStep1Screen;
