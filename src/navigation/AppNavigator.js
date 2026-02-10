import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { useSelector } from 'react-redux';
import OnboardingNavigator from '../screens/onboarding/OnboardingNavigator';
import BottomTabNavigator from './BottomTabNavigator';
import ProfileDetailScreen from '../screens/profile/ProfileDetailScreen';
// TODO: Import auth screens when created

const Stack = createStackNavigator();

const AppNavigator = () => {
    const { isAuthenticated } = useSelector(state => state.user);
    const { onboardingCompleted } = useSelector(state => state.app);

    return (
        <NavigationContainer>
            <Stack.Navigator screenOptions={{ headerShown: false }}>
                {!isAuthenticated ? (
                    <Stack.Screen name="Auth" component={BottomTabNavigator} />
                ) : !onboardingCompleted ? (
                    <Stack.Screen name="Onboarding" component={OnboardingNavigator} />
                ) : (
                    <>
                        <Stack.Screen name="Main" component={BottomTabNavigator} />
                        <Stack.Screen name="ProfileDetail" component={ProfileDetailScreen} />
                    </>
                )}
            </Stack.Navigator>
        </NavigationContainer>
    );
};

export default AppNavigator;
