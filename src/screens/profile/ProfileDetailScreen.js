import React from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    Image,
    TouchableOpacity,
    StatusBar,
} from 'react-native';
import { useSelector } from 'react-redux';
import { getThemeColors } from '../../theme/colors';
import GlassCard from '../../components/common/GlassCard';
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

const JOB_ICONS = {
    student: 'school',
    employed: 'briefcase',
    unemployed: 'account-off',
    preferNotToSay: 'help-circle',
};

const EDUCATION_ICONS = {
    highSchool: 'school',
    bachelors: 'school-outline',
    masters: 'certificate',
    phd: 'certificate-outline',
};

const ProfileDetailScreen = ({ route, navigation }) => {
    const { match, isPending } = route.params;
    const { gender } = useSelector(state => state.user);
    const { isDarkMode, rainbowMode } = useSelector(state => state.app);
    const theme = getThemeColors(gender, isDarkMode, rainbowMode);

    import PillButton from '../../components/common/PillButton';

    const renderInfoRow = (icon, label, value) => (
        <View style={styles.infoRow}>
            <View style={styles.infoLeft}>
                <Icon name={icon} size={20} color={theme.primary} />
                <Text style={[styles.infoLabel, { color: theme.textSecondary }]}>{label}</Text>
            </View>
            <Text style={[styles.infoValue, { color: theme.text }]}>{value}</Text>
        </View>
    );

    const handleGreet = () => {
        // This should probably call a prop function or dispatch an action
        // For now, let's assume we pass a callback or just go back with a param?
        // Actually, better to pass the handler from the previous screen or use Redux.
        // Since this is a Screen, we can't easily pass a callback function via params (warnings).
        // Best approach: unique ID for match, and dispatch action.
        console.log('Greeted from profile');
        navigation.goBack();
        // In a real app, we'd trigger the "Greet" logic here.
        // For this prototype, we might just have to assume the user goes back and clicks Greet on the popup,
        // OR we implement a global/redux action to "Greet" this specific user ID.
        // User said: "V kartici osebe mora tudi biti pozdrav ali ignor"
        // Let's implement it as:
        if (route.params.onGreet) route.params.onGreet();
        navigation.goBack();
    };

    const handleIgnore = () => {
        if (route.params.onIgnore) route.params.onIgnore();
        navigation.goBack();
    };

    return (
        <View style={[styles.container, { backgroundColor: theme.background }]}>
            <StatusBar
                barStyle={isDarkMode ? 'light-content' : 'dark-content'}
                backgroundColor={theme.background}
            />

            {/* Header with back button */}
            <View style={styles.header}>
                <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
                    <Icon name="arrow-left" size={24} color={theme.text} />
                </TouchableOpacity>
                <Text style={[styles.headerTitle, { color: theme.text }]}>Profile</Text>
                <View style={styles.placeholder} />
            </View>

            <ScrollView
                style={styles.scrollView}
                contentContainerStyle={styles.scrollContent}
                showsVerticalScrollIndicator={false}
            >
                {/* Profile Images */}
                <View style={styles.imagesSection}>
                    <ScrollView
                        horizontal
                        pagingEnabled
                        showsHorizontalScrollIndicator={false}
                        style={styles.imagesScroll}
                    >
                        {match.profileImages && match.profileImages.length > 0 ? (
                            match.profileImages.map((image, index) => (
                                <Image
                                    key={index}
                                    source={{ uri: image }}
                                    style={styles.profileImage}
                                />
                            ))
                        ) : (
                            <View style={[styles.profileImagePlaceholder, { backgroundColor: theme.surface }]}>
                                <Icon name="account" size={80} color={theme.textSecondary} />
                            </View>
                        )}
                    </ScrollView>
                    {match.profileImages && match.profileImages.length > 1 && (
                        <View style={styles.imageIndicators}>
                            {match.profileImages.map((_, index) => (
                                <View
                                    key={index}
                                    style={[
                                        styles.indicator,
                                        { backgroundColor: theme.primary + '40' }
                                    ]}
                                />
                            ))}
                        </View>
                    )}
                </View>

                {/* Name and Basic Info */}
                <GlassCard style={styles.card}>
                    <View style={styles.nameSection}>
                        <Text style={[styles.name, { color: theme.text }]}>
                            {match.name}, {match.age}
                        </Text>
                        {match.distance && (
                            <View style={styles.distanceRow}>
                                <Icon name="map-marker" size={18} color={theme.primary} />
                                <Text style={[styles.distance, { color: theme.textSecondary }]}>
                                    {match.distance}m away
                                </Text>
                            </View>
                        )}
                    </View>
                </GlassCard>

                {/* About */}
                {match.bio && (
                    <GlassCard style={styles.card}>
                        <Text style={[styles.sectionTitle, { color: theme.text }]}>About</Text>
                        <Text style={[styles.bio, { color: theme.textSecondary }]}>
                            {match.bio}
                        </Text>
                    </GlassCard>
                )}

                {/* Details */}
                <GlassCard style={styles.card}>
                    <Text style={[styles.sectionTitle, { color: theme.text }]}>Details</Text>

                    {match.height && renderInfoRow('human-male-height', 'Height', `${match.height} cm`)}
                    {match.hairColor && renderInfoRow('palette', 'Hair Color', match.hairColor.charAt(0).toUpperCase() + match.hairColor.slice(1))}
                    {match.jobStatus && renderInfoRow(
                        JOB_ICONS[match.jobStatus] || 'briefcase',
                        'Job Status',
                        match.jobStatus === 'preferNotToSay' ? 'Prefer not to say' : match.jobStatus.charAt(0).toUpperCase() + match.jobStatus.slice(1)
                    )}
                    {match.education && renderInfoRow(
                        EDUCATION_ICONS[match.education] || 'school',
                        'Education',
                        match.education === 'highSchool' ? 'High School' : match.education.charAt(0).toUpperCase() + match.education.slice(1)
                    )}
                    {match.location && match.location.city && renderInfoRow(
                        'map-marker',
                        'Location',
                        `${match.location.city}${match.location.country ? ', ' + match.location.country : ''}`
                    )}
                </GlassCard>

                {/* Interests */}
                {match.hobbies && match.hobbies.length > 0 && (
                    <GlassCard style={styles.card}>
                        <Text style={[styles.sectionTitle, { color: theme.text }]}>Interests</Text>
                        <View style={styles.hobbiesGrid}>
                            {match.hobbies.map((hobby, index) => (
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
                                        size={20}
                                        color={theme.primary}
                                    />
                                    <Text style={[styles.hobbyText, { color: theme.primary }]}>
                                        {hobby.charAt(0).toUpperCase() + hobby.slice(1)}
                                    </Text>
                                </View>
                            ))}
                        </View>
                    </GlassCard>
                )}

                {/* Personality */}
                {match.personality !== undefined && (
                    <GlassCard style={styles.card}>
                        <Text style={[styles.sectionTitle, { color: theme.text }]}>Personality</Text>
                        <View style={styles.personalityContainer}>
                            <View style={styles.personalityRow}>
                                <Text style={[styles.personalityLabel, { color: theme.textSecondary }]}>
                                    Introvert
                                </Text>
                                <Text style={[styles.personalityLabel, { color: theme.textSecondary }]}>
                                    Extrovert
                                </Text>
                            </View>
                            <View style={[styles.personalityBar, { backgroundColor: theme.surface }]}>
                                <View
                                    style={[
                                        styles.personalityFill,
                                        {
                                            backgroundColor: theme.primary,
                                            width: `${match.personality}%`
                                        }
                                    ]}
                                />
                            </View>
                        </View>
                    </GlassCard>
                )}
            </ScrollView>

            {/* Action Buttons for Pending Matches */}
            {isPending && (
                <View style={[styles.footer, { backgroundColor: theme.surfaceGlass, borderTopColor: theme.border }]}>
                    <View style={styles.actionButtonsContainer}>
                        <PillButton
                            title="Ignore"
                            onPress={handleIgnore}
                            variant="outline"
                            icon="close"
                            style={styles.actionButton}
                        />
                        <View style={{ width: 16 }} />
                        <PillButton
                            title="Greet"
                            onPress={handleGreet}
                            variant="primary"
                            icon="hand-wave"
                            style={styles.actionButton}
                        />
                    </View>
                </View>
            )}
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingTop: 60,
        paddingHorizontal: 24,
        paddingBottom: 16,
    },
    backButton: {
        width: 40,
        height: 40,
        justifyContent: 'center',
        alignItems: 'flex-start',
    },
    headerTitle: {
        fontSize: 18,
        fontWeight: '600',
    },
    placeholder: {
        width: 40,
    },
    scrollView: {
        flex: 1,
    },
    scrollContent: {
        paddingBottom: 40,
    },
    imagesSection: {
        height: 400,
        marginBottom: 16,
    },
    imagesScroll: {
        flex: 1,
    },
    profileImage: {
        width: 400,
        height: 400,
        resizeMode: 'cover',
    },
    profileImagePlaceholder: {
        width: 400,
        height: 400,
        justifyContent: 'center',
        alignItems: 'center',
    },
    imageIndicators: {
        position: 'absolute',
        bottom: 16,
        left: 0,
        right: 0,
        flexDirection: 'row',
        justifyContent: 'center',
        gap: 6,
    },
    indicator: {
        width: 8,
        height: 8,
        borderRadius: 4,
    },
    card: {
        marginHorizontal: 24,
        marginBottom: 16,
        padding: 20,
    },
    nameSection: {
        alignItems: 'center',
    },
    name: {
        fontSize: 32,
        fontWeight: 'bold',
        marginBottom: 8,
    },
    distanceRow: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 6,
    },
    distance: {
        fontSize: 16,
    },
    sectionTitle: {
        fontSize: 20,
        fontWeight: '600',
        marginBottom: 16,
    },
    bio: {
        fontSize: 16,
        lineHeight: 24,
    },
    infoRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingVertical: 12,
        borderBottomWidth: 1,
        borderBottomColor: 'rgba(255, 255, 255, 0.1)',
    },
    infoLeft: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 12,
    },
    infoLabel: {
        fontSize: 16,
    },
    infoValue: {
        fontSize: 16,
        fontWeight: '600',
    },
    hobbiesGrid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: 10,
    },
    hobbyChip: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 14,
        paddingVertical: 10,
        borderRadius: 20,
        borderWidth: 1,
        gap: 8,
    },
    hobbyText: {
        fontSize: 14,
        fontWeight: '600',
    },
    personalityContainer: {
        marginTop: 8,
    },
    personalityRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 12,
    },
    personalityLabel: {
        fontSize: 14,
    },
    personalityBar: {
        height: 8,
        borderRadius: 4,
        overflow: 'hidden',
    },
    personalityFill: {
        height: '100%',
        borderRadius: 4,
    },
    footer: {
        padding: 24,
        paddingBottom: 36,
        borderTopWidth: 1,
    },
    actionButtonsContainer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
    },
    actionButton: {
        flex: 1,
    },
});

export default ProfileDetailScreen;
