import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, Easing } from 'react-native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';

const RadarAnimation = ({ isActive }) => {
    const { gender } = useSelector(state => state.user);
    const { isDarkMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode);

    const pulseAnim = useRef(new Animated.Value(0)).current;
    const rotateAnim = useRef(new Animated.Value(0)).current;

    useEffect(() => {
        if (isActive) {
            // Pulse animation
            Animated.loop(
                Animated.sequence([
                    Animated.timing(pulseAnim, {
                        toValue: 1,
                        duration: 2000,
                        easing: Easing.out(Easing.ease),
                        useNativeDriver: true,
                    }),
                    Animated.timing(pulseAnim, {
                        toValue: 0,
                        duration: 0,
                        useNativeDriver: true,
                    }),
                ])
            ).start();

            // Rotation animation
            Animated.loop(
                Animated.timing(rotateAnim, {
                    toValue: 1,
                    duration: 3000,
                    easing: Easing.linear,
                    useNativeDriver: true,
                })
            ).start();
        } else {
            pulseAnim.setValue(0);
            rotateAnim.setValue(0);
        }
    }, [isActive]);

    const pulseScale = pulseAnim.interpolate({
        inputRange: [0, 1],
        outputRange: [1, 2.5],
    });

    const pulseOpacity = pulseAnim.interpolate({
        inputRange: [0, 1],
        outputRange: [0.6, 0],
    });

    const rotation = rotateAnim.interpolate({
        inputRange: [0, 1],
        outputRange: ['0deg', '360deg'],
    });

    if (!isActive) {
        return (
            <View style={styles.container}>
                <View style={[styles.centerDot, { backgroundColor: theme.textSecondary }]} />
            </View>
        );
    }

    return (
        <View style={styles.container}>
            {/* Pulse waves */}
            <Animated.View
                style={[
                    styles.pulse,
                    {
                        backgroundColor: theme.primary,
                        opacity: pulseOpacity,
                        transform: [{ scale: pulseScale }],
                    },
                ]}
            />

            {/* Rotating scanner line */}
            <Animated.View
                style={[
                    styles.scanner,
                    {
                        transform: [{ rotate: rotation }],
                    },
                ]}
            >
                <View style={[styles.scannerLine, { backgroundColor: theme.accent }]} />
            </Animated.View>

            {/* Center dot */}
            <View style={[styles.centerDot, { backgroundColor: theme.primary }]} />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        width: 200,
        height: 200,
        justifyContent: 'center',
        alignItems: 'center',
    },
    pulse: {
        position: 'absolute',
        width: 80,
        height: 80,
        borderRadius: 40,
    },
    scanner: {
        position: 'absolute',
        width: 200,
        height: 200,
    },
    scannerLine: {
        position: 'absolute',
        width: 2,
        height: 100,
        left: '50%',
        top: 0,
        marginLeft: -1,
    },
    centerDot: {
        width: 16,
        height: 16,
        borderRadius: 8,
        zIndex: 10,
    },
});

export default RadarAnimation;
