import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity, Modal } from 'react-native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import { createPillStyle } from '../../theme/glassmorphism';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const HOBBY_ICONS = {
    music: 'music',
    travel: 'airplane',
    movies: 'movie',
    reading: 'book',
    sports: 'basketball',
    gaming: 'gamepad-variant',
    cooking: 'chef-hat',
    photography: 'camera',
    art: 'palette',
    fitness: 'dumbbell',
    tech: 'laptop',
    nature: 'pine-tree',
};

const MatchNotification = ({ visible, match, onGreet, onIgnore, onViewProfile }) => {
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    if (!match) return null;

    const topHobbies = match.hobbies?.slice(0, 3) || [];

    return (
        <Modal
            visible={visible}
            transparent
            animationType="slide"
            onRequestClose={onIgnore}
        >
            <TouchableOpacity
                style={styles.overlay}
                activeOpacity={1}
                onPress={onIgnore}
            >
                <TouchableOpacity
                    activeOpacity={1}
                    onPress={onViewProfile}
                    style={styles.cardContainer}
                >
                    <View style={[
                        styles.card,
                        {
                            backgroundColor: theme.surfaceGlass,
                            borderColor: theme.border,
                        },
                        createPillStyle('large')
                    ]}>
                        {/* Header with close button */}
                        <TouchableOpacity
                            style={styles.closeButton}
                            onPress={(e) => {
                                e.stopPropagation();
                                onIgnore();
                            }}
                        >
                            <Icon name="close" size={24} color={theme.textSecondary} />
                        </TouchableOpacity>

                        {/* Profile Image */}
                        <View style={styles.imageContainer}>
                            {match.profileImage ? (
                                <Image
                                    source={{ uri: match.profileImage }}
                                    style={styles.image}
                                />
                            ) : (
                                <View style={[styles.imagePlaceholder, { backgroundColor: theme.surface }]}>
                                    <Icon name="account" size={60} color={theme.textSecondary} />
                                </View>
                            )}
                            <View style={[styles.pulseBadge, { backgroundColor: theme.primary }]}>
                                <Icon name="heart-pulse" size={20} color="#FFF" />
                            </View>
                        </View>

                        {/* Name and Age */}
                        <Text style={[styles.name, { color: theme.text }]}>
                            {match.name}, {match.age}
                        </Text>

                        {/* Distance */}
                        {match.distance && (
                            <View style={styles.distanceRow}>
                                <Icon name="map-marker" size={16} color={theme.textSecondary} />
                                <Text style={[styles.distance, { color: theme.textSecondary }]}>
                                    {match.distance}m away
                                </Text>
                            </View>
                        )}

                        {/* Top 3 Hobbies */}
                        {topHobbies.length > 0 && (
                            <View style={styles.hobbiesContainer}>
                                <Text style={[styles.hobbiesTitle, { color: theme.textSecondary }]}>
                                    Interests
                                </Text>
                                <View style={styles.hobbiesGrid}>
                                    {topHobbies.map((hobby, index) => (
                                        <View
                                            key={index}
                                            style={[
                                                styles.hobbyChip,
                                                {
                                                    backgroundColor: theme.primary + '20',
                                                    borderColor: theme.primary + '40',
                                                }
                                            ]}
                                        >
                                            <Icon
                                                name={HOBBY_ICONS[hobby] || 'star'}
                                                size={18}
                                                color={theme.primary}
                                            />
                                            <Text style={[styles.hobbyText, { color: theme.primary }]}>
                                                {hobby.charAt(0).toUpperCase() + hobby.slice(1)}
                                            </Text>
                                        </View>
                                    ))}
                                </View>
                            </View>
                        )}

                        {/* Action Buttons */}
                        <View style={styles.actions}>
                            <TouchableOpacity
                                style={[
                                    styles.actionButton,
                                    styles.ignoreButton,
                                    {
                                        backgroundColor: theme.surface,
                                        borderColor: theme.border,
                                    }
                                ]}
                                onPress={(e) => {
                                    e.stopPropagation();
                                    onIgnore();
                                }}
                            >
                                <Icon name="close-circle" size={24} color={theme.textSecondary} />
                                <Text style={[styles.buttonText, { color: theme.textSecondary }]}>
                                    Ignore
                                </Text>
                            </TouchableOpacity>

                            <TouchableOpacity
                                style={[
                                    styles.actionButton,
                                    styles.greetButton,
                                    { backgroundColor: theme.primary }
                                ]}
                                onPress={(e) => {
                                    e.stopPropagation();
                                    onGreet();
                                }}
                            >
                                <Icon name="hand-wave" size={24} color="#FFF" />
                                <Text style={[styles.buttonText, { color: '#FFF' }]}>
                                    Greet
                                </Text>
                            </TouchableOpacity>
                        </View>

                        {/* Tap to view profile hint */}
                        <Text style={[styles.hint, { color: theme.textSecondary }]}>
                            Tap anywhere to view full profile
                        </Text>
                    </View>
                </TouchableOpacity>
            </TouchableOpacity>
        </Modal>
    );
};

const styles = StyleSheet.create({
    overlay: {
        flex: 1,
        backgroundColor: 'rgba(0, 0, 0, 0.7)',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 24,
    },
    cardContainer: {
        width: '100%',
        maxWidth: 400,
    },
    card: {
        padding: 24,
        borderWidth: 1,
        position: 'relative',
    },
    closeButton: {
        position: 'absolute',
        top: 16,
        right: 16,
        zIndex: 10,
        width: 40,
        height: 40,
        justifyContent: 'center',
        alignItems: 'center',
    },
    imageContainer: {
        alignItems: 'center',
        marginBottom: 16,
        position: 'relative',
    },
    image: {
        width: 120,
        height: 120,
        borderRadius: 60,
    },
    imagePlaceholder: {
        width: 120,
        height: 120,
        borderRadius: 60,
        justifyContent: 'center',
        alignItems: 'center',
    },
    pulseBadge: {
        position: 'absolute',
        bottom: 0,
        right: '35%',
        width: 40,
        height: 40,
        borderRadius: 20,
        justifyContent: 'center',
        alignItems: 'center',
        borderWidth: 3,
        borderColor: '#FFF',
    },
    name: {
        fontSize: 28,
        fontWeight: 'bold',
        textAlign: 'center',
        marginBottom: 8,
    },
    distanceRow: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        marginBottom: 20,
        gap: 4,
    },
    distance: {
        fontSize: 14,
    },
    hobbiesContainer: {
        marginBottom: 24,
    },
    hobbiesTitle: {
        fontSize: 14,
        fontWeight: '600',
        marginBottom: 12,
        textAlign: 'center',
        textTransform: 'uppercase',
        letterSpacing: 1,
    },
    hobbiesGrid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'center',
        gap: 8,
    },
    hobbyChip: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 12,
        paddingVertical: 8,
        borderRadius: 16,
        borderWidth: 1,
        gap: 6,
    },
    hobbyText: {
        fontSize: 13,
        fontWeight: '600',
    },
    actions: {
        flexDirection: 'row',
        gap: 12,
        marginBottom: 12,
    },
    actionButton: {
        flex: 1,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        paddingVertical: 14,
        borderRadius: 24,
        gap: 8,
    },
    ignoreButton: {
        borderWidth: 2,
    },
    greetButton: {
        // Primary color background
    },
    buttonText: {
        fontSize: 16,
        fontWeight: '600',
    },
    hint: {
        fontSize: 12,
        textAlign: 'center',
        fontStyle: 'italic',
    },
});

export default MatchNotification;
