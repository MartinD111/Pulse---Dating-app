import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import WelcomeScreen from './WelcomeScreen';
import RegisterStep1Screen from './RegisterStep1Screen';
import RegisterStep2Screen from './RegisterStep2Screen';
import RegisterStep3Screen from './RegisterStep3Screen';
import TermsScreen from './TermsScreen';

const Stack = createStackNavigator();

const OnboardingNavigator = () => {
    return (
        <Stack.Navigator
            screenOptions={{
                headerShown: false,
                cardStyle: { backgroundColor: 'transparent' },
                animationEnabled: true,
            }}
        >
            <Stack.Screen name="Welcome" component={WelcomeScreen} />
            <Stack.Screen name="Terms" component={TermsScreen} options={{ presentation: 'modal' }} />
            <Stack.Screen name="RegisterStep1" component={RegisterStep1Screen} />
            <Stack.Screen name="RegisterStep2" component={RegisterStep2Screen} />
            <Stack.Screen name="RegisterStep3" component={RegisterStep3Screen} />
        </Stack.Navigator>
    );
};

export default OnboardingNavigator;
