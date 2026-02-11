import { createSlice } from '@reduxjs/toolkit';

const initialState = {
    isAuthenticated: false,
    uid: null,
    email: null,
    gender: 'neutral', // 'male' | 'female' | 'neutral'
    name: '',
    age: null,
    profileImages: [], // Array of image URIs (max 3)
    hobbies: [], // Array of hobby IDs (exactly 3)
    personality: 50, // 0-100 slider: 0 = introvert, 100 = extrovert
    height: 170, // in cm
    jobStatus: 'employed', // 'student' | 'employed' | 'unemployed' | 'preferNotToSay'
    education: 'bachelors', // 'highSchool' | 'bachelors' | 'masters' | 'phd' | 'files'
    hairColor: 'brown', // 'black' | 'brown' | 'blonde' | 'red' | 'gray' | 'other'
    location: {
        country: '',
        city: '',
        latitude: null,
        longitude: null,
    },
    isPremium: false,
    interestedIn: 'both', // 'male' | 'female' | 'both'
};

const userSlice = createSlice({
    name: 'user',
    initialState,
    reducers: {
        setAuthenticated: (state, action) => {
            state.isAuthenticated = action.payload.isAuthenticated;
            state.uid = action.payload.uid;
            state.email = action.payload.email;
        },
        setGender: (state, action) => {
            state.gender = action.payload;
        },
        setProfile: (state, action) => {
            const { name, age, hobbies, personality, height, jobStatus, education, hairColor, location, isPremium, interestedIn } = action.payload;
            if (name !== undefined) state.name = name;
            if (age !== undefined) state.age = age;
            if (hobbies !== undefined) state.hobbies = hobbies;
            if (personality !== undefined) state.personality = personality;
            if (height !== undefined) state.height = height;
            if (jobStatus !== undefined) state.jobStatus = jobStatus;
            if (education !== undefined) state.education = education;
            if (hairColor !== undefined) state.hairColor = hairColor;
            if (location !== undefined) state.location = { ...state.location, ...location };
            if (isPremium !== undefined) state.isPremium = isPremium;
            if (interestedIn !== undefined) state.interestedIn = interestedIn;
        },
        setProfileImages: (state, action) => {
            state.profileImages = action.payload.slice(0, 3); // Max 3 images
        },
        addProfileImage: (state, action) => {
            if (state.profileImages.length < 3) {
                state.profileImages.push(action.payload);
            }
        },
        removeProfileImage: (state, action) => {
            state.profileImages = state.profileImages.filter((_, index) => index !== action.payload);
        },
        logout: (state) => {
            return initialState;
        },
    },
});

export const {
    setAuthenticated,
    setGender,
    setProfile,
    setProfileImages,
    addProfileImage,
    removeProfileImage,
    logout,
} = userSlice.actions;

export default userSlice.reducer;
