// Gender-based dynamic color theming
export const COLORS = {
    // Neutral theme (Introduction/Setup) - Mixed Pink/Blue
    neutral: {
        light: {
            primary: '#B19CD9', // Mixed Purple
            primaryLight: '#E6E6FA',
            primaryDark: '#9370DB',
            accent: '#8A2BE2',
            background: '#F8F8FF', // Ghost White
            surface: 'rgba(177, 156, 217, 0.15)',
            surfaceGlass: 'rgba(230, 230, 250, 0.25)',
            text: '#2E2B35',
            textSecondary: '#605C6C',
            border: 'rgba(177, 156, 217, 0.3)',
            shadow: 'rgba(138, 43, 226, 0.2)',
        },
        dark: {
            primary: '#9370DB',
            primaryLight: '#B19CD9',
            primaryDark: '#8A2BE2',
            accent: '#BA55D3',
            background: '#151019',
            surface: 'rgba(147, 112, 219, 0.12)',
            surfaceGlass: 'rgba(177, 156, 217, 0.18)',
            text: '#F0E6FA',
            textSecondary: '#C8BFE0',
            border: 'rgba(147, 112, 219, 0.25)',
            shadow: 'rgba(186, 85, 211, 0.3)',
        },
    },

    // Female theme - Light Pink Glassmorphism
    female: {
        light: {
            primary: '#FFB3D9',
            primaryLight: '#FFD6EC',
            primaryDark: '#FF8FC7',
            accent: '#FF69B4',
            background: '#FFF5FA',
            surface: 'rgba(255, 179, 217, 0.15)',
            surfaceGlass: 'rgba(255, 214, 236, 0.25)',
            text: '#2D1B2E',
            textSecondary: '#6B4C6D',
            border: 'rgba(255, 179, 217, 0.3)',
            shadow: 'rgba(255, 105, 180, 0.2)',
        },
        dark: {
            primary: '#FF8FC7',
            primaryLight: '#FFB3D9',
            primaryDark: '#FF69B4',
            accent: '#FF1493',
            background: '#1A0D1A',
            surface: 'rgba(255, 143, 199, 0.12)',
            surfaceGlass: 'rgba(255, 179, 217, 0.18)',
            text: '#FFE6F2',
            textSecondary: '#D4A5D4',
            border: 'rgba(255, 143, 199, 0.25)',
            shadow: 'rgba(255, 20, 147, 0.3)',
        },
    },

    // Male theme - Light Blue Glassmorphism
    male: {
        light: {
            primary: '#87CEEB',
            primaryLight: '#B0E0F6',
            primaryDark: '#5DADE2',
            accent: '#4A90E2',
            background: '#F0F8FF',
            surface: 'rgba(135, 206, 235, 0.15)',
            surfaceGlass: 'rgba(176, 224, 246, 0.25)',
            text: '#1A2B3D',
            textSecondary: '#4A5F7D',
            border: 'rgba(135, 206, 235, 0.3)',
            shadow: 'rgba(74, 144, 226, 0.2)',
        },
        dark: {
            primary: '#5DADE2',
            primaryLight: '#87CEEB',
            primaryDark: '#3498DB',
            accent: '#2E86DE',
            background: '#0D1A26',
            surface: 'rgba(93, 173, 226, 0.12)',
            surfaceGlass: 'rgba(135, 206, 235, 0.18)',
            text: '#E6F3FF',
            textSecondary: '#A5C9E6',
            border: 'rgba(93, 173, 226, 0.25)',
            shadow: 'rgba(46, 134, 222, 0.3)',
        },
    },

    // Rainbow theme (LGBTQ+ preference)
    rainbow: {
        gradient: [
            '#FF0018', // Red
            '#FFA52C', // Orange
            '#FFFF41', // Yellow
            '#008018', // Green
            '#0000F9', // Blue
            '#86007D', // Purple
        ],
        accentGradient: ['#FF69B4', '#FF8C00', '#FFD700', '#00FA9A', '#1E90FF', '#9370DB'],
    },

    // Common colors
    common: {
        white: '#FFFFFF',
        black: '#000000',
        error: '#FF3B30',
        success: '#34C759',
        warning: '#FF9500',
        info: '#007AFF',
        transparent: 'transparent',
    },
};

// Get theme colors based on gender and mode
export const getThemeColors = (gender, isDark = false, rainbowMode = false) => {
    const genderTheme = COLORS[gender] || COLORS.neutral || COLORS.male;
    const modeTheme = isDark ? genderTheme.dark : genderTheme.light;

    return {
        ...modeTheme,
        rainbow: rainbowMode ? COLORS.rainbow : null,
        common: COLORS.common,
    };
};

// Utility function to create gradient strings
export const createGradient = (colors) => {
    return colors;
};
