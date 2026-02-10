import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import MainSettingsScreen from './screens/MainSettingsScreen';
import EditProfileScreen from './screens/EditProfileScreen';
import PreferencesScreen from './screens/PreferencesScreen';

const Stack = createStackNavigator();

const SettingsNavigator = () => {
    return (
        <Stack.Navigator
            screenOptions={{
                headerShown: false,
                cardStyle: { backgroundColor: 'transparent' },
            }}
        >
            <Stack.Screen name="MainSettings" component={MainSettingsScreen} />
            <Stack.Screen name="EditProfile" component={EditProfileScreen} />
            <Stack.Screen name="Preferences" component={PreferencesScreen} />
        </Stack.Navigator>
    );
};

export default SettingsNavigator;
