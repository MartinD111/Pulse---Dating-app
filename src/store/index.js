import { configureStore } from '@reduxjs/toolkit';
import userReducer from './slices/userSlice';
import preferencesReducer from './slices/preferencesSlice';
import matchesReducer from './slices/matchesSlice';
import appReducer from './slices/appSlice';

export const store = configureStore({
    reducer: {
        user: userReducer,
        preferences: preferencesReducer,
        matches: matchesReducer,
        app: appReducer,
    },
    middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware({
            serializableCheck: {
                // Ignore these action types
                ignoredActions: ['user/setProfileImages'],
                // Ignore these field paths in all actions
                ignoredActionPaths: ['payload.images'],
                // Ignore these paths in the state
                ignoredPaths: ['user.profileImages'],
            },
        }),
});

export default store;
