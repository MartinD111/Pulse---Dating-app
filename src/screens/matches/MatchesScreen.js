import React from 'react';
import { View, Text, StyleSheet, FlatList, StatusBar } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import MatchCard from '../../components/matches/MatchCard';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const MatchesScreen = () => {
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const { matches } = useSelector(state => state.matches);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);
    const navigation = useNavigation();

    const handleToggleRematch = (matchId, canRematch) => {
        // TODO: Dispatch action to update match rematch status
        console.log('Toggle rematch for:', matchId, canRematch);
    };

    const handleMatchPress = (match) => {
        // Navigate to ProfileDetail in read-only mode (isPending: false)
        // User said: "če kliknemo na osebo se nam tudi odpre njihova kartica (pozdrav ali ignor ni možen)"
        navigation.navigate('ProfileDetail', { match, isPending: false });
    };

    const renderEmptyState = () => (
        <View style={styles.emptyContainer}>
            <Icon name="account-group-outline" size={80} color={theme.textSecondary} />
            <Text style={[styles.emptyTitle, { color: theme.text }]}>No people yet</Text>
            <Text style={[styles.emptySubtitle, { color: theme.textSecondary }]}>
                Start searching to find people nearby
            </Text>
        </View>
    );

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <StatusBar
                barStyle={isDarkMode ? 'light-content' : 'dark-content'}
                backgroundColor={theme.background}
            />

            <View style={styles.header}>
                <Text style={[styles.title, { color: theme.text }]}>People</Text>
                <Text style={[styles.subtitle, { color: theme.textSecondary }]}>
                    {matches.length} {matches.length === 1 ? 'person' : 'people'} matched
                </Text>
            </View>

            <FlatList
                data={matches}
                keyExtractor={(item) => item.id}
                renderItem={({ item }) => (
                    <MatchCard
                        match={item}
                        onPress={() => handleMatchPress(item)}
                        onToggleRematch={handleToggleRematch}
                    />
                )}
                contentContainerStyle={styles.listContent}
                ListEmptyComponent={renderEmptyState}
                showsVerticalScrollIndicator={false}
            />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    header: {
        paddingTop: 60,
        paddingHorizontal: 24,
        paddingBottom: 20,
    },
    title: {
        fontSize: 32,
        fontWeight: 'bold',
        marginBottom: 4,
    },
    subtitle: {
        fontSize: 16,
    },
    listContent: {
        paddingHorizontal: 24,
        paddingBottom: 20,
        flexGrow: 1,
    },
    emptyContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        paddingVertical: 60,
    },
    emptyTitle: {
        fontSize: 24,
        fontWeight: '600',
        marginTop: 16,
        marginBottom: 8,
    },
    emptySubtitle: {
        fontSize: 16,
        textAlign: 'center',
    },
});

export default MatchesScreen;
