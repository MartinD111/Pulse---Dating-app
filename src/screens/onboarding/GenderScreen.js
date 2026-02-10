import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { setGender } from '../../store/slices/userSlice';
import { getThemeColors } from '../../theme/colors';
import PillButton from '../../components/common/PillButton';

const GenderScreen = ({ navigation }) => {
    const dispatch = useDispatch();
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const handleGenderSelect = (selectedGender) => {
        dispatch(setGender(selectedGender));
        // Slight delay to show the theme change before navigating?
        // Or just navigate. Let's just set it.
    };

    const handleNext = () => {
        navigation.navigate('ProfileDetails');
    };

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <View style={styles.header}>
                <Text style={[styles.title, { color: theme.text }]}>Who are you?</Text>
                <Text style={[styles.subtitle, { color: theme.textSecondary }]}>
                    This helps us find your best matches and customize your experience.
                </Text>
            </View>

            <View style={styles.content}>
                <PillButton
                    title="Female"
                    onPress={() => handleGenderSelect('female')}
                    variant={gender === 'female' ? 'primary' : 'outline'}
                    style={styles.optionButton}
                />
                <PillButton
                    title="Male"
                    onPress={() => handleGenderSelect('male')}
                    variant={gender === 'male' ? 'primary' : 'outline'}
                    style={styles.optionButton}
                />
            </View>

            <View style={styles.footer}>
                <PillButton
                    title="Next"
                    onPress={handleNext}
                    disabled={gender === 'neutral'} // Must select a gender
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
        padding: 24,
    },
    header: {
        marginTop: 60,
    },
    title: {
        fontSize: 32,
        fontWeight: 'bold',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 16,
        lineHeight: 24,
    },
    content: {
        flex: 1,
        justifyContent: 'center',
        gap: 16,
    },
    optionButton: {
        paddingVertical: 20,
    },
    footer: {
        marginBottom: 20,
    },
    button: {
        width: '100%',
        paddingVertical: 18,
    },
});

export default GenderScreen;
