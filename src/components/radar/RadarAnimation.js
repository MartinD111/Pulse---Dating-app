import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, Easing } from 'react-native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';

const RadarAnimation = ({ isActive }) => {
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    // Animations
    const rotateAnim = useRef(new Animated.Value(0)).current;

    // Multiple ripples for better effect
    const ripple1 = useRef(new Animated.Value(0)).current;
    const ripple2 = useRef(new Animated.Value(0)).current;
    const ripple3 = useRef(new Animated.Value(0)).current;

    useEffect(() => {
        if (isActive) {
            // Rotation
            Animated.loop(
                Animated.timing(rotateAnim, {
                    toValue: 1,
                    duration: 3000,
                    easing: Easing.linear,
                    useNativeDriver: true,
                })
            ).start();

            // Ripples
            const createRipple = (anim, delay) => {
                return Animated.loop(
                    Animated.sequence([
                        Animated.delay(delay),
                        Animated.timing(anim, {
                            toValue: 1,
                            duration: 2500,
                            easing: Easing.out(Easing.ease),
                            useNativeDriver: true,
                        }),
                    ])
                );
            };

            createRipple(ripple1, 0).start();
            createRipple(ripple2, 800).start();
            createRipple(ripple3, 1600).start();

        } else {
            rotateAnim.setValue(0);
            ripple1.setValue(0);
            ripple2.setValue(0);
            ripple3.setValue(0);
        }
    }, [isActive]);

    const rotation = rotateAnim.interpolate({
        inputRange: [0, 1],
        outputRange: ['0deg', '360deg'],
    });

    const getRippleStyle = (anim) => ({
        transform: [{ scale: anim.interpolate({ inputRange: [0, 1], outputRange: [0.1, 4] }) }],
        opacity: anim.interpolate({ inputRange: [0, 0.5, 1], outputRange: [0.8, 0.3, 0] }),
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
            {/* Ripples */}
            {[ripple1, ripple2, ripple3].map((r, i) => (
                <Animated.View
                    key={i}
                    style={[
                        styles.ripple,
                        {
                            borderColor: theme.primary,
                            borderWidth: 1.5,
                            backgroundColor: i === 0 ? theme.primary + '20' : 'transparent', // Inner one has fill
                        },
                        getRippleStyle(r)
                    ]}
                />
            ))}

            {/* Rotating Scanner */}
            <Animated.View style={[styles.scanner, { transform: [{ rotate: rotation }] }]}>
                <View style={[
                    styles.scannerBeam,
                    {
                        backgroundColor: theme.accent,
                        shadowColor: theme.accent,
                    }
                ]} />
            </Animated.View>

            {/* Center Dot */}
            <View style={[styles.centerDot, { backgroundColor: theme.primary, shadowColor: theme.primary }]} />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        width: 300,
        height: 300,
        justifyContent: 'center',
        alignItems: 'center',
    },
    ripple: {
        position: 'absolute',
        width: 80,
        height: 80,
        borderRadius: 40,
    },
    scanner: {
        position: 'absolute',
        width: 300,
        height: 300,
        justifyContent: 'center',
        alignItems: 'center',
    },
    scannerBeam: {
        position: 'absolute',
        top: 0,
        height: 150, // Half height of container
        width: 4,
        borderBottomLeftRadius: 2,
        borderBottomRightRadius: 2,
        opacity: 0.8,
        shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 0.8,
        shadowRadius: 10,
        elevation: 5,
    },
    centerDot: {
        width: 24,
        height: 24,
        borderRadius: 12,
        zIndex: 10,
        borderWidth: 3,
        borderColor: '#fff',
        shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 0.5,
        shadowRadius: 6,
        elevation: 5,
    },
});

export default RadarAnimation;
