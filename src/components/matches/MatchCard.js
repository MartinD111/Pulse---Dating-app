import React, { useState } from 'react';
import { View, Text, Image, StyleSheet, TouchableOpacity, Switch } from 'react-native';
import { useSelector } from 'react-redux';
import { useNavigation } from '@react-navigation/native';
import { getThemeColors } from '../../theme/colors';
import GlassCard from '../common/GlassCard';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const MatchCard = ({ match, onToggleRematch }) => {
    const navigation = useNavigation();
    const [canRematch, setCanRematch] = useState(match.canRematch !== false);
    const { gender } = useSelector(state => state.user);
    const { isDarkMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode);

    const formatTime = (timestamp) => {
        const date = new Date(timestamp);
        const now = new Date();
        const diffMs = now - date;
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMs / 3600000);
        const diffDays = Math.floor(diffMs / 86400000);

        if (diffMins < 60) return `${diffMins}m ago`;
        if (diffHours < 24) return `${diffHours}h ago`;
        return `${diffDays}d ago`;
    };

    const handleToggle = (value) => {
        setCanRematch(value);
        if (onToggleRematch) {
            onToggleRematch(match.id, value);
        }
    };

    const handlePress = () => {
        navigation.navigate('ProfileDetail', { match });
    };

    return (
        <GlassCard style={styles.card}>
            <TouchableOpacity onPress={handlePress} activeOpacity={0.8}>
                <View style={styles.content}>
                    <View style={styles.imageContainer}>
                        {match.profileImage ? (
                            <Image source={{ uri: match.profileImage }} style={styles.image} />
                        ) : (
                            <View style={[styles.imagePlaceholder, { backgroundColor: theme.surface }]}>
                                <Icon name="account" size={40} color={theme.textSecondary} />
                            </View>
                        )}
                    </View>

                    <View style={styles.info}>
                        <Text style={[styles.name, { color: theme.text }]}>
                            {match.name}, {match.age}
                        </Text>
                        <View style={styles.metaRow}>
                            <Icon name="clock-outline" size={14} color={theme.textSecondary} />
                            <Text style={[styles.time, { color: theme.textSecondary }]}>
                                {formatTime(match.timestamp)}
                            </Text>
                        </View>
                        {match.distance && (
                            <View style={styles.metaRow}>
                                <Icon name="map-marker" size={14} color={theme.textSecondary} />
                                <Text style={[styles.distance, { color: theme.textSecondary }]}>
                                    {match.distance}m away
                                </Text>
                            </View>
                        )}
                    </View>

                    <Icon name="chevron-right" size={24} color={theme.textSecondary} />
                </View>
            </TouchableOpacity>

            <View style={styles.toggleContainer}>
                <Text style={[styles.toggleLabel, { color: theme.textSecondary }]}>
                    Allow rematch
                </Text>
                <Switch
                    value={canRematch}
                    onValueChange={handleToggle}
                    trackColor={{ false: theme.surface, true: theme.primaryLight }}
                    thumbColor={canRematch ? theme.primary : theme.textSecondary}
                />
            </View>
        </GlassCard>
    );
};

const styles = StyleSheet.create({
    card: {
        marginBottom: 12,
    },
    content: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    imageContainer: {
        marginRight: 12,
    },
    image: {
        width: 60,
        height: 60,
        borderRadius: 30,
    },
    imagePlaceholder: {
        width: 60,
        height: 60,
        borderRadius: 30,
        justifyContent: 'center',
        alignItems: 'center',
    },
    info: {
        flex: 1,
    },
    name: {
        fontSize: 18,
        fontWeight: '600',
        marginBottom: 4,
    },
    metaRow: {
        flexDirection: 'row',
        alignItems: 'center',
        marginTop: 2,
    },
    time: {
        fontSize: 13,
        marginLeft: 4,
    },
    distance: {
        fontSize: 13,
        marginLeft: 4,
    },
    toggleContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingTop: 12,
        marginTop: 12,
        borderTopWidth: 1,
        borderTopColor: 'rgba(255, 255, 255, 0.1)',
    },
    toggleLabel: {
        fontSize: 14,
        fontWeight: '500',
    },
});

export default MatchCard;
