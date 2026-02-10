import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import { createGlassCard } from '../../theme/glassmorphism';

const GlassCard = ({ children, size = 'medium', style, intensity = 'medium' }) => {
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const cardStyle = createGlassCard(theme, size);

    return (
        <View style={[cardStyle, style]}>
            {children}
        </View>
    );
};

export default GlassCard;
