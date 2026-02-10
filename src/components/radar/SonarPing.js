import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, Easing } from 'react-native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';

const SonarPing = ({ isActive, progress }) => {
    // progress: 0 (far) -> 1 (near/arrived)
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    // Multiple ripple animations for the "ping" effect
    const ripple1 = useRef(new Animated.Value(0)).current;
    const ripple2 = useRef(new Animated.Value(0)).current;
    const ripple3 = useRef(new Animated.Value(0)).current;

    const targetAnim = useRef(new Animated.Value(0)).current;

    useEffect(() => {
        if (isActive) {
            // Staggered ripple animation
            const createRipple = (anim, delay) => {
                return Animated.loop(
                    Animated.sequence([
                        Animated.delay(delay),
                        Animated.timing(anim, {
                            toValue: 1,
                            duration: 2000,
                            easing: Easing.out(Easing.ease),
                            useNativeDriver: true,
                        }),
                        Animated.timing(anim, {
                            toValue: 0,
                            duration: 0,
                            useNativeDriver: true,
                        }),
                    ])
                );
            };

            const anim1 = createRipple(ripple1, 0);
            const anim2 = createRipple(ripple2, 600);
            const anim3 = createRipple(ripple3, 1200);

            anim1.start();
            anim2.start();
            anim3.start();
        } else {
            ripple1.setValue(0);
            ripple2.setValue(0);
            ripple3.setValue(0);
        }
    }, [isActive]);

    useEffect(() => {
        // Smoothly animate the target position based on progress prop
        Animated.timing(targetAnim, {
            toValue: progress, // 0 = edge, 1 = center
            duration: 500,
            useNativeDriver: true,
        }).start();
    }, [progress]);

    const getRippleStyle = (anim) => {
        return {
            opacity: anim.interpolate({
                inputRange: [0, 0.7, 1],
                outputRange: [0.8, 0.4, 0],
            }),
            transform: [{
                scale: anim.interpolate({
                    inputRange: [0, 1],
                    outputRange: [0, 4], // Expand outward
                })
            }],
        };
    };

    // Calculate target position
    // 0 progress = 100px away (edge), 1 progress = 0px away (center)
    const targetTranslate = targetAnim.interpolate({
        inputRange: [0, 1],
        outputRange: [100, 20], // Still slightly offset at "arrived" so it doesn't overlap user dot completely or looks like a collision
    });

    // Rotate the target to come from a specific angle (e.g., 45 degrees)
    // In a real app this would depend on bearing
    const angle = '45deg';

    if (!isActive) return null;

    return (
        <View style={styles.container}>
            {/* Ripples emitting from center (User) */}
            {[ripple1, ripple2, ripple3].map((r, i) => (
                <Animated.View
                    key={i}
                    style={[
                        styles.ripple,
                        {
                            borderColor: theme.primary,
                            backgroundColor: theme.primary + '20', // Low opacity fill
                        },
                        getRippleStyle(r)
                    ]}
                />
            ))}

            {/* User Dot (Center) */}
            <View style={[styles.centerDot, { backgroundColor: theme.primary }]} />

            {/* Approaching Target Dot */}
            <Animated.View
                style={[
                    styles.targetContainer,
                    { transform: [{ rotate: angle }] }
                ]}
            >
                <Animated.View
                    style={[
                        styles.targetDot,
                        {
                            backgroundColor: theme.accent,
                            shadowColor: theme.accent,
                            transform: [{ translateY: Animated.multiply(targetTranslate, -1) }] // Move inwards
                        }
                    ]}
                />
            </Animated.View>
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
        borderWidth: 2,
    },
    centerDot: {
        width: 20,
        height: 20,
        borderRadius: 10,
        zIndex: 10,
        borderWidth: 2,
        borderColor: '#FFF',
    },
    targetContainer: {
        position: 'absolute',
        width: '100%',
        height: '100%',
        justifyContent: 'center',
        alignItems: 'center',
    },
    targetDot: {
        width: 16,
        height: 16,
        borderRadius: 8,
        shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 0.8,
        shadowRadius: 10,
        elevation: 5,
        borderWidth: 1,
        borderColor: '#FFF',
    },
});

export default SonarPing;
