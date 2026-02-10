import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { setProfile } from '../../store/slices/userSlice';
import { getThemeColors } from '../../theme/colors';
import PillButton from '../../components/common/PillButton';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const HOBBIES_LIST = [
    { id: 'music', icon: 'music', label: 'Music' },
    { id: 'travel', icon: 'airplane', label: 'Travel' },
    { id: 'movies', icon: 'movie', label: 'Movies' },
    { id: 'reading', icon: 'book', label: 'Reading' },
    { id: 'sports', icon: 'basketball', label: 'Sports' },
    { id: 'gaming', icon: 'gamepad-variant', label: 'Gaming' },
    { id: 'cooking', icon: 'chef-hat', label: 'Cooking' },
    { id: 'photography', icon: 'camera', label: 'Photography' },
    { id: 'art', icon: 'palette', label: 'Art' },
    { id: 'fitness', icon: 'dumbbell', label: 'Fitness' },
    { id: 'tech', icon: 'laptop', label: 'Tech' },
    { id: 'nature', icon: 'pine-tree', label: 'Nature' },
];

const InterestsScreen = ({ navigation }) => {
    const dispatch = useDispatch();
    const { gender, hobbies } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const [selectedHobbies, setSelectedHobbies] = useState(hobbies || []);

    const toggleHobby = (id) => {
        if (selectedHobbies.includes(id)) {
            setSelectedHobbies(prev => prev.filter(h => h !== id));
        } else {
            if (selectedHobbies.length < 3) {
                setSelectedHobbies(prev => [...prev, id]);
            }
        }
    };

    const handleNext = () => {
        dispatch(setProfile({ hobbies: selectedHobbies }));
        navigation.navigate('Lifestyle');
    };

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <View style={styles.header}>
                <Text style={[styles.title, { color: theme.text }]}>Pick 3 Interests</Text>
                <Text style={[styles.subtitle, { color: theme.textSecondary }]}>
                    {selectedHobbies.length}/3 selected
                </Text>
            </View>

            <ScrollView contentContainerStyle={styles.grid} showsVerticalScrollIndicator={false}>
                {HOBBIES_LIST.map((hobby) => {
                    const isSelected = selectedHobbies.includes(hobby.id);
                    return (
                        <TouchableOpacity
                            key={hobby.id}
                            style={[
                                styles.card,
                                {
                                    backgroundColor: isSelected ? theme.primary : theme.surfaceGlass,
                                    borderColor: theme.border,
                                }
                            ]}
                            onPress={() => toggleHobby(hobby.id)}
                            activeOpacity={0.7}
                        >
                            <Icon
                                name={hobby.icon}
                                size={32}
                                color={isSelected ? theme.text : theme.primary}
                            />
                            <Text style={[
                                styles.cardLabel,
                                { color: isSelected ? theme.text : theme.textSecondary }
                            ]}>
                                {hobby.label}
                            </Text>
                        </TouchableOpacity>
                    );
                })}
            </ScrollView>

            <View style={styles.footer}>
                <PillButton
                    title="Next"
                    onPress={handleNext}
                    disabled={selectedHobbies.length !== 3}
                    variant="primary"
                    style={styles.button}
                />
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        padding: 24,
    },
    header: {
        marginTop: 40,
        marginBottom: 20,
    },
    title: {
        fontSize: 32,
        fontWeight: 'bold',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 16,
    },
    grid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'space-between',
        paddingBottom: 20,
    },
    card: {
        width: '30%',
        aspectRatio: 1,
        marginBottom: 16,
        borderRadius: 16,
        borderWidth: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: 8,
    },
    cardLabel: {
        marginTop: 8,
        fontSize: 12,
        fontWeight: '600',
        textAlign: 'center',
    },
    footer: {
        paddingTop: 16,
    },
    button: {
        width: '100%',
        paddingVertical: 18,
    },
});

export default InterestsScreen;
