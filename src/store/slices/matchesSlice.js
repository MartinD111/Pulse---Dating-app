import { createSlice } from '@reduxjs/toolkit';

const initialState = {
    matches: [], // Array of match objects
    history: [], // All interactions (greeted + ignored)
};

const matchesSlice = createSlice({
    name: 'matches',
    initialState,
    reducers: {
        addMatch: (state, action) => {
            const match = {
                id: action.payload.id,
                uid: action.payload.uid,
                name: action.payload.name,
                age: action.payload.age,
                profileImage: action.payload.profileImage,
                timestamp: new Date().toISOString(),
                status: 'greeted', // 'greeted' | 'ignored'
                distance: action.payload.distance,
            };
            state.matches.unshift(match);
            state.history.unshift(match);
        },
        addIgnored: (state, action) => {
            const ignored = {
                id: action.payload.id,
                uid: action.payload.uid,
                timestamp: new Date().toISOString(),
                status: 'ignored',
            };
            state.history.unshift(ignored);
        },
        removeMatch: (state, action) => {
            state.matches = state.matches.filter(match => match.id !== action.payload);
        },
        clearMatches: (state) => {
            state.matches = [];
        },
        clearHistory: (state) => {
            state.history = [];
        },
    },
});

export const {
    addMatch,
    addIgnored,
    removeMatch,
    clearMatches,
    clearHistory,
} = matchesSlice.actions;

export default matchesSlice.reducer;
