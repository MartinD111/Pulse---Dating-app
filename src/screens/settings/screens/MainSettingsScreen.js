import React from 'react';
import { View, Text, StyleSheet, ScrollView, StatusBar, TouchableOpacity } from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import { getThemeColors } from '../../../theme/colors';
import { toggleDarkMode, toggleRainbowMode } from '../../../store/slices/appSlice';
import { logout } from '../../../store/slices/userSlice';
import GlassCard from '../../../components/common/GlassCard';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const MainSettingsScreen = ({ navigation }) => {
    const dispatch = useDispatch();
    const { gender, isPremium } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const renderMenuItem = (icon, title, subtitle, onPress, showBadge = false) => (
        <TouchableOpacity onPress={onPress} activeOpacity={0.7}>
            <GlassCard style={styles.menuItem}>
                <View style={styles.menuLeft}>
                    <View style={[styles.iconContainer, { backgroundColor: theme.primary + '20' }]}>
                        <Icon name={icon} size={24} color={theme.primary} />
                    </View>
                    <View style={styles.menuText}>
                        <Text style={[styles.menuTitle, { color: theme.text }]}>{title}</Text>
                        {subtitle && (
                            <Text style={[styles.menuSubtitle, { color: theme.textSecondary }]}>
                                {subtitle}
                            </Text>
                        )}
                    </View>
                </View>
                <View style={styles.menuRight}>
                    {showBadge && (
                        <View style={[styles.badge, { backgroundColor: theme.accent }]}>
                            <Text style={styles.badgeText}>PRO</Text>
                        </View>
                    )}
                    <Icon name="chevron-right" size={24} color={theme.textSecondary} />
                </View>
            </GlassCard>
        </TouchableOpacity>
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
                {renderMenuItem(
                    'account-edit',
                    'Edit Profile',
                    'Update your personal information',
                    () => navigation.navigate('EditProfile')
                )}

                {renderMenuItem(
                    'tune',
                    'Preferences',
                    'Set your matching preferences',
                    () => navigation.navigate('Preferences')
                )}

                {renderMenuItem(
                    'crown',
                    'Upgrade to Premium',
                    'Unlock exclusive features',
                    () => console.log('Premium'),
                    !isPremium
                )}

                <View style={styles.section}>
                    <Text style={[styles.sectionTitle, { color: theme.textSecondary }]}>Display</Text>

                    <GlassCard style={styles.toggleCard}>
                        <View style={styles.toggleRow}>
                            <View style={styles.toggleLeft}>
                                <Icon name="theme-light-dark" size={24} color={theme.primary} />
                                <Text style={[styles.toggleLabel, { color: theme.text }]}>Dark Mode</Text>
                            </View>
                            <TouchableOpacity
                                style={[
                                    styles.toggle,
                                    { backgroundColor: isDarkMode ? theme.primary : theme.surface }
                                ]}
                                onPress={() => dispatch(toggleDarkMode())}
                            >
                                <View style={[
                                    styles.toggleThumb,
                                    {
                                        backgroundColor: theme.common.white,
                                        transform: [{ translateX: isDarkMode ? 20 : 0 }]
                                    }
                                ]} />
                            </TouchableOpacity>
                        </View>

                        <View style={[styles.toggleRow, styles.toggleRowBorder]}>
                            <View style={styles.toggleLeft}>
                                <Icon name="rainbow" size={24} color={theme.primary} />
                                <Text style={[styles.toggleLabel, { color: theme.text }]}>Rainbow Mode</Text>
                            </View>
                            <TouchableOpacity
                                style={[
                                    styles.toggle,
                                    { backgroundColor: rainbowMode ? theme.primary : theme.surface }
                                ]}
                                onPress={() => dispatch(toggleRainbowMode())}
                            >
                                <View style={[
                                    styles.toggleThumb,
                                    {
                                        backgroundColor: theme.common.white,
                                        transform: [{ translateX: rainbowMode ? 20 : 0 }]
                                    }
                                ]} />
                            </TouchableOpacity>
                        </View>
                    </GlassCard>
                </View>

                <TouchableOpacity onPress={() => dispatch(logout())} activeOpacity={0.7}>
                    <GlassCard style={[styles.menuItem, styles.logoutButton]}>
                        <Icon name="logout" size={24} color={theme.common.error} />
                        <Text style={[styles.logoutText, { color: theme.common.error }]}>Log Out</Text>
                    </GlassCard>
                </TouchableOpacity>
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
    menuItem: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: 16,
        marginBottom: 12,
    },
    menuLeft: {
        flexDirection: 'row',
        alignItems: 'center',
        flex: 1,
    },
    iconContainer: {
        width: 48,
        height: 48,
        borderRadius: 24,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 16,
    },
    menuText: {
        flex: 1,
    },
    menuTitle: {
        fontSize: 16,
        fontWeight: '600',
        marginBottom: 2,
    },
    menuSubtitle: {
        fontSize: 13,
    },
    menuRight: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
    },
    badge: {
        paddingHorizontal: 8,
        paddingVertical: 4,
        borderRadius: 8,
    },
    badgeText: {
        color: '#FFF',
        fontSize: 11,
        fontWeight: 'bold',
    },
    section: {
        marginTop: 24,
        marginBottom: 12,
    },
    sectionTitle: {
        fontSize: 14,
        fontWeight: '600',
        marginBottom: 12,
        marginLeft: 4,
        textTransform: 'uppercase',
        letterSpacing: 1,
    },
    toggleCard: {
        padding: 16,
    },
    toggleRow: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingVertical: 12,
    },
    toggleRowBorder: {
        borderTopWidth: 1,
        borderTopColor: 'rgba(255, 255, 255, 0.1)',
    },
    toggleLeft: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 12,
    },
    toggleLabel: {
        fontSize: 16,
    },
    toggle: {
        width: 50,
        height: 30,
        borderRadius: 15,
        padding: 2,
        justifyContent: 'center',
    },
    toggleThumb: {
        width: 26,
        height: 26,
        borderRadius: 13,
    },
    logoutButton: {
        marginTop: 24,
        justifyContent: 'center',
        gap: 12,
    },
    logoutText: {
        fontSize: 16,
        fontWeight: '600',
    },
});

export default MainSettingsScreen;
