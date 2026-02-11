import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { setProfile } from '../../store/slices/userSlice';
import { getThemeColors } from '../../theme/colors';
import PillButton from '../../components/common/PillButton';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const HOBBIES = [
    { id: 'music', label: 'Music', icon: 'music' },
    { id: 'travel', label: 'Travel', icon: 'airplane' },
    { id: 'movies', label: 'Movies', icon: 'movie' },
    { id: 'reading', label: 'Reading', icon: 'book' },
    { id: 'sports', label: 'Sports', icon: 'basketball' },
    { id: 'gaming', label: 'Gaming', icon: 'gamepad-variant' },
    { id: 'cooking', label: 'Cooking', icon: 'chef-hat' },
    { id: 'photography', label: 'Photography', icon: 'camera' },
    { id: 'art', label: 'Art', icon: 'palette' },
    { id: 'fitness', label: 'Fitness', icon: 'dumbbell' },
    { id: 'tech', label: 'Tech', icon: 'laptop' },
    { id: 'nature', label: 'Nature', icon: 'pine-tree' },
];

const RegisterStep2Screen = ({ navigation }) => {
    const dispatch = useDispatch();
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    const [selectedHobbies, setSelectedHobbies] = useState([]);

    const toggleHobby = (id) => {
        if (selectedHobbies.includes(id)) {
            setSelectedHobbies(prev => prev.filter(h => h !== id));
        } else {
            if (selectedHobbies.length >= 5) {
                Alert.alert('Limit Reached', 'You can select up to 5 hobbies.');
                return;
            }
            setSelectedHobbies(prev => [...prev, id]);
        }
    };

    const handleNext = () => {
        if (selectedHobbies.length < 3) {
            Alert.alert('More Interests', 'Please select at least 3 hobbies.');
            return;
        }

        dispatch(setProfile({ hobbies: selectedHobbies }));
        navigation.navigate('RegisterStep3');
    };

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <View style={styles.header}>
                <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
                    <Icon name="arrow-left" size={24} color={theme.text} />
                </TouchableOpacity>
                <Text style={[styles.title, { color: theme.text }]}>Your Interests</Text>
                <Text style={[styles.subtitle, { color: theme.textSecondary }]}>
                    Pick at least 3 things you love.
                </Text>
            </View>

            <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
                <View style={styles.grid}>
                    {HOBBIES.map(hobby => {
                        const isSelected = selectedHobbies.includes(hobby.id);
                        return (
                            <TouchableOpacity
                                key={hobby.id}
                                style={[
                                    styles.hobbyItem,
                                    {
                                        backgroundColor: isSelected ? theme.primary : theme.surfaceGlass,
                                        borderColor: isSelected ? theme.primary : theme.border,
                                    }
                                ]}
                                onPress={() => toggleHobby(hobby.id)}
                            >
                                <Icon
                                    name={hobby.icon}
                                    size={24}
                                    color={isSelected ? '#FFF' : theme.textSecondary}
                                />
                                <Text style={[
                                    styles.hobbyLabel,
                                    { color: isSelected ? '#FFF' : theme.textSecondary }
                                ]}>
                                    {hobby.label}
                                </Text>
                            </TouchableOpacity>
                        );
                    })}
                </View>
            </ScrollView>

            <View style={styles.footer}>
                <PillButton
                    title={`Next (${selectedHobbies.length})`}
                    onPress={handleNext}
                    disabled={selectedHobbies.length < 3}
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
        marginBottom: 24,
    },
    backButton: {
        marginBottom: 16,
        padding: 4,
        alignSelf: 'flex-start',
    },
    title: {
        fontSize: 32,
        fontWeight: 'bold',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 16,
    },
    content: {
        paddingBottom: 20,
    },
    grid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: 12,
        justifyContent: 'center',
    },
    hobbyItem: {
        width: '30%', // roughly 3 columns
        aspectRatio: 1,
        borderRadius: 16,
        borderWidth: 1,
        alignItems: 'center',
        justifyContent: 'center',
        padding: 8,
    },
    hobbyLabel: {
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

export default RegisterStep2Screen;
