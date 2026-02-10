import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import WelcomeScreen from './WelcomeScreen';
import GenderScreen from './GenderScreen';
import ProfileDetailsScreen from './ProfileDetailsScreen';
import InterestsScreen from './InterestsScreen';
import LifestyleScreen from './LifestyleScreen';
import RegisterScreen from './RegisterScreen';
import TermsScreen from './TermsScreen';

const Stack = createStackNavigator();

const OnboardingNavigator = () => {
    return (
        <Stack.Navigator
            screenOptions={{
                headerShown: false,
                cardStyle: { backgroundColor: 'transparent' },
                // Use a simple slide animation
                animationEnabled: true,
            }}
        >
            <Stack.Screen name="Welcome" component={WelcomeScreen} />
            <Stack.Screen name="Terms" component={TermsScreen} options={{ presentation: 'modal' }} />
            <Stack.Screen name="Register" component={RegisterScreen} />
            <Stack.Screen name="Gender" component={GenderScreen} />
            <Stack.Screen name="ProfileDetails" component={ProfileDetailsScreen} />
            <Stack.Screen name="Interests" component={InterestsScreen} />
            <Stack.Screen name="Lifestyle" component={LifestyleScreen} />
        </Stack.Navigator>
    );
};

export default OnboardingNavigator;
