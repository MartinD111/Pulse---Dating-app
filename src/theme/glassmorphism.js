import { Platform } from 'react-native';

// Glassmorphism style generator
export const createGlassmorphism = (theme, intensity = 'medium') => {
    const intensityMap = {
        light: {
            backgroundColor: theme.surfaceGlass,
            opacity: 0.7,
            blur: 10,
        },
        medium: {
            backgroundColor: theme.surfaceGlass,
            opacity: 0.85,
            blur: 20,
        },
        strong: {
            backgroundColor: theme.surface,
            opacity: 0.95,
            blur: 30,
        },
    };

    const config = intensityMap[intensity] || intensityMap.medium;

    return {
        backgroundColor: config.backgroundColor,
        borderWidth: 1,
        borderColor: theme.border,
        ...Platform.select({
            ios: {
                shadowColor: theme.shadow,
                shadowOffset: { width: 0, height: 4 },
                shadowOpacity: 0.3,
                shadowRadius: 12,
            },
            android: {
                elevation: 8,
            },
        }),
    };
};

// Pill-shaped border radius
export const PILL_RADIUS = {
    small: 16,
    medium: 24,
    large: 32,
    full: 9999,
};

// Create pill-shaped container style
export const createPillStyle = (size = 'medium') => {
    return {
        borderRadius: PILL_RADIUS[size] || PILL_RADIUS.medium,
        overflow: 'hidden',
    };
};

// Frosted glass card style
export const createGlassCard = (theme, size = 'medium') => {
    return {
        ...createGlassmorphism(theme, 'medium'),
        ...createPillStyle(size),
        padding: 16,
    };
};

// Glassmorphism button style
export const createGlassButton = (theme, variant = 'primary') => {
    const baseStyle = {
        ...createGlassmorphism(theme, 'light'),
        ...createPillStyle('full'),
        paddingVertical: 14,
        paddingHorizontal: 24,
        alignItems: 'center',
        justifyContent: 'center',
    };

    if (variant === 'primary') {
        return {
            ...baseStyle,
            backgroundColor: theme.primary,
            borderColor: theme.primaryLight,
        };
    }

    if (variant === 'secondary') {
        return {
            ...baseStyle,
            backgroundColor: theme.surfaceGlass,
            borderColor: theme.border,
        };
    }

    return baseStyle;
};

// Text input with glassmorphism
export const createGlassInput = (theme) => {
    return {
        ...createGlassmorphism(theme, 'light'),
        ...createPillStyle('medium'),
        paddingVertical: 12,
        paddingHorizontal: 20,
        fontSize: 16,
        color: theme.text,
    };
};

// Backdrop blur effect (for modals/overlays)
export const createBackdrop = (theme) => {
    return {
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        ...Platform.select({
            ios: {
                backdropFilter: 'blur(10px)',
            },
        }),
    };
};

// Gradient overlay for rainbow mode
export const createRainbowOverlay = (rainbowColors) => {
    if (!rainbowColors) return {};

    return {
        borderWidth: 2,
        borderColor: 'transparent',
        // Note: For actual gradient borders, we'll need LinearGradient component
        // This is a placeholder for the style object
    };
};
