import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../theme/colors';
import { createPillStyle } from '../theme/glassmorphism';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

import RadarScreen from '../screens/radar/RadarScreen';
import MatchesScreen from '../screens/matches/MatchesScreen';
import SettingsNavigator from '../screens/settings/SettingsNavigator';

const Tab = createBottomTabNavigator();

const BottomTabNavigator = () => {
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    return (
        <Tab.Navigator
            screenOptions={{
                headerShown: false,
                tabBarStyle: {
                    backgroundColor: theme.surfaceGlass,
                    borderTopWidth: 1,
                    borderTopColor: theme.border,
                    height: 70,
                    paddingBottom: 10,
                    paddingTop: 10,
                    ...createPillStyle('large'),
                    borderBottomLeftRadius: 0,
                    borderBottomRightRadius: 0,
                },
                tabBarActiveTintColor: theme.primary,
                tabBarInactiveTintColor: theme.textSecondary,
                tabBarLabelStyle: {
                    fontSize: 12,
                    fontWeight: '600',
                },
            }}
        >
            <Tab.Screen
                name="Radar"
                component={RadarScreen}
                options={{
                    tabBarIcon: ({ color, size }) => (
                        <Icon name="radar" size={size} color={color} />
                    ),
                }}
            />
            <Tab.Screen
                name="People"
                component={MatchesScreen}
                options={{
                    tabBarIcon: ({ color, size }) => (
                        <Icon name="account-group" size={size} color={color} />
                    ),
                }}
            />
            <Tab.Screen
                name="Settings"
                component={SettingsNavigator}
                options={{
                    tabBarIcon: ({ color, size }) => (
                        <Icon name="cog" size={size} color={color} />
                    ),
                }}
            />
        </Tab.Navigator>
    );
};

export default BottomTabNavigator;
