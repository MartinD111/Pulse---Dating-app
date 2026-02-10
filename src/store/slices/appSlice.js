import { createSlice } from '@reduxjs/toolkit';
import { useColorScheme } from 'react-native';

const initialState = {
    isDarkMode: false, // Will be set based on system preference
    rainbowMode: false,
    isSearching: false,
    onboardingCompleted: false,
    sonarEnabled: true,
};

const appSlice = createSlice({
    name: 'app',
    initialState,
    reducers: {
        setDarkMode: (state, action) => {
            state.isDarkMode = action.payload;
        },
        toggleDarkMode: (state) => {
            state.isDarkMode = !state.isDarkMode;
        },
        setRainbowMode: (state, action) => {
            state.rainbowMode = action.payload;
        },
        toggleRainbowMode: (state) => {
            state.rainbowMode = !state.rainbowMode;
        },
        setSearching: (state, action) => {
            state.isSearching = action.payload;
        },
        toggleSearching: (state) => {
            state.isSearching = !state.isSearching;
        },
        setOnboardingCompleted: (state, action) => {
            state.onboardingCompleted = action.payload;
        },
        toggleSonarMode: (state) => {
            state.sonarEnabled = !state.sonarEnabled;
        },
    },
});

export const {
    setDarkMode,
    toggleDarkMode,
    setRainbowMode,
    toggleRainbowMode,
    setSearching,
    toggleSearching,
    setOnboardingCompleted,
    toggleSonarMode,
} = appSlice.actions;

export default appSlice.reducer;
