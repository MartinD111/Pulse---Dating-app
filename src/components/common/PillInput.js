import React from 'react';
import { TextInput, StyleSheet } from 'react-native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import { createGlassInput } from '../../theme/glassmorphism';

const PillInput = ({
    value,
    onChangeText,
    placeholder,
    secureTextEntry = false,
    keyboardType = 'default',
    autoCapitalize = 'sentences',
    style,
    ...props
}) => {
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const inputStyle = createGlassInput(theme);

    return (
        <TextInput
            style={[inputStyle, style]}
            value={value}
            onChangeText={onChangeText}
            placeholder={placeholder}
            placeholderTextColor={theme.textSecondary}
            secureTextEntry={secureTextEntry}
            keyboardType={keyboardType}
            autoCapitalize={autoCapitalize}
            {...props}
        />
    );
};

export default PillInput;
