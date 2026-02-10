import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import PillButton from '../../components/common/PillButton';
import PillInput from '../../components/common/PillInput';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import auth from '@react-native-firebase/auth';
import { setProfile, setAuthenticated } from '../../store/slices/userSlice';

const RegisterScreen = ({ navigation }) => {
    const dispatch = useDispatch();
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const [form, setForm] = useState({
        email: '',
        password: '',
        day: '',
        month: '',
        year: '',
    });

    const [loading, setLoading] = useState(false);
    const [termsAccepted, setTermsAccepted] = useState(false);

    const handleUpdate = (key, value) => {
        setForm(prev => ({ ...prev, [key]: value }));
    };

    const calculatePasswordStrength = (password) => {
        if (!password) return 0;
        let strength = 0;
        if (password.length >= 8) strength += 1;
        if (/[A-Z]/.test(password)) strength += 1;
        if (/[0-9]/.test(password)) strength += 1;
        if (/[^A-Za-z0-9]/.test(password)) strength += 1;
        return strength; // 0-4
    };

    const passwordStrength = calculatePasswordStrength(form.password);

    const getStrengthColor = (s) => {
        if (s <= 1) return '#ef4444'; // Red
        if (s === 2) return '#f59e0b'; // Yellow
        if (s === 3) return '#84cc16'; // Lime
        return '#22c55e'; // Green
    };

    const getStrengthLabel = (s) => {
        if (s <= 1) return 'Weak';
        if (s === 2) return 'Fair';
        if (s === 3) return 'Good';
        return 'Strong';
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

    const handleRegister = async () => {
        if (!termsAccepted) {
            Alert.alert('Terms Required', 'Please accept the Terms & Conditions to proceed.');
            return;
        }

        const { isValid, age } = validateAge();
        if (!isValid) {
            Alert.alert('Age Restriction', 'You must be at least 18 years old to use Pulse.');
            return;
        }

        if (passwordStrength < 2) {
            Alert.alert('Weak Password', 'Please choose a stronger password.');
            return;
        }

        setLoading(true);
        try {
            const userCredential = await auth().createUserWithEmailAndPassword(form.email, form.password);

            // Save initial calculated age to profile
            dispatch(setProfile({ age: age }));

            // Note: Auth listener in App.js will handle the state update, but we might want to ensure navigation happens smoothly.
            // But since onboarding is not complete, AppNavigator will keep us in Onboarding stack.
            // We should manually navigate to Gender screen to continue the flow basically "logging them in" to the onboarding process.

            // However, the Auth listener updates the store which might trigger a re-render.
            // The AppNavigator checks `isAuthenticated` and `onboardingCompleted`.
            // `isAuthenticated` will become true. `onboardingCompleted` is false.
            // So we stay in OnboardingNavigator.
            // navigating to Gender manually is safe.

            navigation.navigate('Gender');

        } catch (error) {
            console.error(error);
            if (error.code === 'auth/email-already-in-use') {
                Alert.alert('Error', 'That email address is already in use!');
            } else if (error.code === 'auth/invalid-email') {
                Alert.alert('Error', 'That email address is invalid!');
            } else {
                Alert.alert('Error', error.message);
            }
        } finally {
            setLoading(false);
        }
    };

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <View style={styles.header}>
                <PillButton
                    icon="arrow-left"
                    variant="glass"
                    onPress={() => navigation.goBack()}
                    style={styles.backButton}
                />
                <Text style={[styles.title, { color: theme.text }]}>Create Account</Text>
            </View>

            <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
                <View style={styles.section}>
                    <Text style={[styles.label, { color: theme.textSecondary }]}>Email</Text>
                    <PillInput
                        placeholder="hello@example.com"
                        value={form.email}
                        onChangeText={text => handleUpdate('email', text)}
                        keyboardType="email-address"
                        autoCapitalize="none"
                    />
                </View>

                <View style={styles.section}>
                    <Text style={[styles.label, { color: theme.textSecondary }]}>Password</Text>
                    <PillInput
                        placeholder="••••••••"
                        value={form.password}
                        onChangeText={text => handleUpdate('password', text)}
                        secureTextEntry
                    />
                    {/* Password Strength Indicator */}
                    {form.password.length > 0 && (
                        <View style={styles.strengthContainer}>
                            <View style={styles.strengthBarBg}>
                                <View
                                    style={[
                                        styles.strengthBarFill,
                                        {
                                            width: `${(passwordStrength / 4) * 100}%`,
                                            backgroundColor: getStrengthColor(passwordStrength)
                                        }
                                    ]}
                                />
                            </View>
                            <Text style={[styles.strengthLabel, { color: getStrengthColor(passwordStrength) }]}>
                                {getStrengthLabel(passwordStrength)}
                            </Text>
                        </View>
                    )}
                </View>

                <View style={styles.section}>
                    <Text style={[styles.label, { color: theme.textSecondary }]}>Date of Birth</Text>
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

                {/* Terms and Conditions */}
                <View style={styles.termsContainer}>
                    <TouchableOpacity
                        style={styles.checkbox}
                        onPress={() => setTermsAccepted(!termsAccepted)}
                    >
                        <Icon
                            name={termsAccepted ? "checkbox-marked" : "checkbox-blank-outline"}
                            size={24}
                            color={termsAccepted ? theme.primary : theme.textSecondary}
                        />
                    </TouchableOpacity>
                    <View style={styles.termsTextContainer}>
                        <Text style={[styles.termsText, { color: theme.textSecondary }]}>
                            I agree to the
                        </Text>
                        <TouchableOpacity onPress={() => navigation.navigate('Terms')}>
                            <Text style={[styles.termsLink, { color: theme.primary }]}> Terms & Conditions</Text>
                        </TouchableOpacity>
                    </View>
                </View>

            </ScrollView>

            <View style={styles.footer}>
                <PillButton
                    title="Sign Up"
                    onPress={handleRegister}
                    loading={loading}
                    disabled={loading || !form.email || !form.password || !termsAccepted || !form.day || !form.month || !form.year}
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
        flexDirection: 'row',
        alignItems: 'center',
        marginTop: 40,
        marginBottom: 32,
    },
    backButton: {
        width: 40,
        height: 40,
        paddingHorizontal: 0,
        marginRight: 16,
    },
    title: {
        fontSize: 28,
        fontWeight: 'bold',
    },
    content: {
        flex: 1,
    },
    section: {
        marginBottom: 24,
    },
    label: {
        fontSize: 16,
        marginBottom: 8,
        marginLeft: 4,
    },
    strengthContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        marginTop: 8,
        marginLeft: 4,
    },
    strengthBarBg: {
        flex: 1,
        height: 4,
        backgroundColor: 'rgba(255,255,255,0.1)',
        borderRadius: 2,
        marginRight: 12,
        overflow: 'hidden',
    },
    strengthBarFill: {
        height: '100%',
        borderRadius: 2,
    },
    strengthLabel: {
        fontSize: 12,
        fontWeight: '600',
        width: 50,
        textAlign: 'right',
    },
    dobContainer: {
        flexDirection: 'row',
        gap: 12,
    },
    dobInput: {
        flex: 1,
    },
    termsContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 32,
        paddingLeft: 4,
    },
    checkbox: {
        marginRight: 12,
    },
    termsTextContainer: {
        flexDirection: 'row',
        flexWrap: 'wrap',
    },
    termsText: {
        fontSize: 14,
    },
    termsLink: {
        fontSize: 14,
        fontWeight: 'bold',
    },
    footer: {
        paddingTop: 16,
    },
    button: {
        width: '100%',
        paddingVertical: 18,
    },
});

export default RegisterScreen;
