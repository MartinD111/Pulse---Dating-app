import React from 'react';
import { TouchableOpacity, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import { createGlassButton } from '../../theme/glassmorphism';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const PillButton = ({
    title,
    onPress,
    variant = 'primary',
    icon,
    iconSize = 20,
    disabled = false,
    loading = false,
    style,
    textStyle,
}) => {
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const buttonStyle = createGlassButton(theme, variant);

    return (
        <TouchableOpacity
            style={[
                buttonStyle,
                disabled && styles.disabled,
                style,
            ]}
            onPress={onPress}
            disabled={disabled || loading}
            activeOpacity={0.7}
        >
            {loading ? (
                <ActivityIndicator color={variant === 'primary' ? theme.text : theme.primary} />
            ) : (
                <>
                    {icon && (
                        <Icon
                            name={icon}
                            size={iconSize}
                            color={variant === 'primary' ? theme.text : theme.primary}
                            style={styles.icon}
                        />
                    )}
                    <Text
                        style={[
                            styles.text,
                            { color: variant === 'primary' ? theme.text : theme.primary },
                            textStyle,
                        ]}
                    >
                        {title}
                    </Text>
                </>
            )}
        </TouchableOpacity>
    );
};

const styles = StyleSheet.create({
    text: {
        fontSize: 16,
        fontWeight: '600',
    },
    icon: {
        marginRight: 8,
    },
    disabled: {
        opacity: 0.5,
    },
});

export default PillButton;
