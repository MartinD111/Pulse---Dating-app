import { createSlice } from '@reduxjs/toolkit';

const initialState = {
    genderPreference: 'female', // 'male' | 'female' | 'nonBinary' | 'all'
    ageRange: {
        min: 18,
        max: 35,
    },
    distanceRadius: 75, // in meters (50-100)
    lifestyle: {
        relationshipType: 'longTerm', // 'longTerm' | 'shortTerm'
        smoking: 'nonSmoking', // 'smoking' | 'nonSmoking' | 'any'
        activity: 'active', // 'active' | 'inactive' | 'any'
        petPreference: 'dog', // 'cat' | 'dog' | 'both' | 'none'
    },
};

const preferencesSlice = createSlice({
    name: 'preferences',
    initialState,
    reducers: {
        setGenderPreference: (state, action) => {
            state.genderPreference = action.payload;
        },
        setAgeRange: (state, action) => {
            state.ageRange = action.payload;
        },
        setDistanceRadius: (state, action) => {
            state.distanceRadius = action.payload;
        },
        setLifestylePreference: (state, action) => {
            const { key, value } = action.payload;
            state.lifestyle[key] = value;
        },
        setAllLifestylePreferences: (state, action) => {
            state.lifestyle = { ...state.lifestyle, ...action.payload };
        },
        resetPreferences: () => initialState,
    },
});

export const {
    setGenderPreference,
    setAgeRange,
    setDistanceRadius,
    setLifestylePreference,
    setAllLifestylePreferences,
    resetPreferences,
} = preferencesSlice.actions;

export default preferencesSlice.reducer;
