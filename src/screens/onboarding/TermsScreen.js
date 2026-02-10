import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import PillButton from '../../components/common/PillButton';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const TermsScreen = ({ navigation }) => {
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <View style={styles.header}>
                <Text style={[styles.title, { color: theme.text }]}>Terms & Conditions</Text>
                <PillButton
                    icon="close"
                    variant="glass"
                    onPress={() => navigation.goBack()}
                    style={styles.closeButton}
                />
            </View>

            <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
                <Text style={[styles.text, { color: theme.textSecondary }]}>
                    Last updated: February 10, 2026{'\n\n'}

                    Please read these terms and conditions carefully before using Our Service.{'\n\n'}

                    <Text style={{ fontWeight: 'bold', color: theme.primary }}>1. Acceptance of Terms</Text>{'\n'}
                    By accessing or using Pulse, you agree to be bound by these Terms. If you disagree with any part of the terms, then you may not access the Service.{'\n\n'}

                    <Text style={{ fontWeight: 'bold', color: theme.primary }}>2. Age Requirement</Text>{'\n'}
                    You must be at least 18 years old to use this Service. By using Pulse, you represent and warrant that you are at least 18 years of age.{'\n\n'}

                    <Text style={{ fontWeight: 'bold', color: theme.primary }}>3. Privacy Policy</Text>{'\n'}
                    Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and share your information.{'\n\n'}

                    <Text style={{ fontWeight: 'bold', color: theme.primary }}>4. User Conduct</Text>{'\n'}
                    You agree not to use the Service for any unlawful purpose or in any way that interrupts, damages, or impairs the service.{'\n\n'}

                    <Text style={{ fontWeight: 'bold', color: theme.primary }}>5. Content</Text>{'\n'}
                    You are responsible for the content you post. Pulse reserves the right to remove any content that violates these terms.{'\n\n'}

                    {/* Placeholder for legal text */}
                    [... More legal text would go here ...]{'\n\n'}
                </Text>
            </ScrollView>
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
        justifyContent: 'space-between',
        alignItems: 'center',
        marginTop: 40,
        marginBottom: 20,
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
    },
    closeButton: {
        paddingHorizontal: 0,
        width: 40,
        height: 40,
        borderRadius: 20,
    },
    content: {
        flex: 1,
    },
    text: {
        fontSize: 16,
        lineHeight: 24,
        paddingBottom: 40,
    },
});

export default TermsScreen;
