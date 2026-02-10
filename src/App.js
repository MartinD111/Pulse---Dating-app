import React, { useEffect } from 'react';
import { Provider } from 'react-redux';
import { useColorScheme } from 'react-native';
import { store } from './store';
import { setDarkMode } from './store/slices/appSlice';
import AppNavigator from './navigation/AppNavigator';

const App = () => {
    const colorScheme = useColorScheme();

    useEffect(() => {
        // Set initial dark mode based on system preference
        store.dispatch(setDarkMode(colorScheme === 'dark'));
    }, [colorScheme]);

    return (
        <Provider store={store}>
            <AppNavigator />
        </Provider>
    );
};

export default App;
