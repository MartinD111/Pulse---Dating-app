import React, { useEffect } from 'react';
import { Provider } from 'react-redux';
import { useColorScheme } from 'react-native';
import { store } from './store';
import { setDarkMode } from './store/slices/appSlice';
import { setAuthenticated } from './store/slices/userSlice';
import auth from '@react-native-firebase/auth';
import AppNavigator from './navigation/AppNavigator';

const App = () => {
    const colorScheme = useColorScheme();

    useEffect(() => {
        // Set initial dark mode based on system preference
        store.dispatch(setDarkMode(colorScheme === 'dark'));

        // Listen for authentication state changes
        const subscriber = auth().onAuthStateChanged((user) => {
            if (user) {
                store.dispatch(setAuthenticated({
                    isAuthenticated: true,
                    uid: user.uid,
                    email: user.email,
                }));
            } else {
                store.dispatch(setAuthenticated({
                    isAuthenticated: false,
                    uid: null,
                    email: null,
                }));
            }
        });

        // Unsubscribe on unmount
        return subscriber;
    }, [colorScheme]);

    return (
        <Provider store={store}>
            <AppNavigator />
        </Provider>
    );
};

export default App;
