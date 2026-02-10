// Icon mappings for attributes and settings
// Using react-native-vector-icons (MaterialCommunityIcons)

export const ICONS = {
    // Navigation
    radar: 'radar',
    matches: 'heart-multiple',
    settings: 'cog',

    // Gender
    male: 'gender-male',
    female: 'gender-female',
    nonBinary: 'gender-non-binary',
    lgbtq: 'flag-variant',

    // Hobbies
    sports: 'basketball',
    music: 'music-note',
    reading: 'book-open-variant',
    gaming: 'gamepad-variant',
    cooking: 'chef-hat',
    travel: 'airplane',
    photography: 'camera',
    art: 'palette',
    fitness: 'dumbbell',
    yoga: 'yoga',
    hiking: 'hiking',
    dancing: 'dance-ballroom',
    movies: 'movie-open',
    pets: 'paw',
    technology: 'laptop',
    fashion: 'hanger',
    food: 'food',
    coffee: 'coffee',
    wine: 'glass-wine',
    beer: 'beer',

    // Lifestyle
    smoking: 'smoking',
    nonSmoking: 'smoking-off',
    active: 'run',
    inactive: 'sofa',
    cat: 'cat',
    dog: 'dog',
    longTerm: 'heart',
    shortTerm: 'heart-outline',

    // Personality
    introvert: 'account-tie',
    extrovert: 'account-group',

    // Actions
    search: 'magnify',
    stop: 'stop-circle',
    edit: 'pencil',
    save: 'content-save',
    delete: 'delete',
    add: 'plus-circle',
    remove: 'minus-circle',
    check: 'check-circle',
    close: 'close-circle',
    camera: 'camera',
    gallery: 'image-multiple',
    location: 'map-marker',
    notification: 'bell',

    // Settings
    theme: 'theme-light-dark',
    rainbow: 'rainbow',
    language: 'translate',
    privacy: 'shield-account',
    help: 'help-circle',
    logout: 'logout',

    // Profile
    height: 'human-male-height',
    age: 'calendar',
    distance: 'map-marker-distance',
};

// Get icon name by key
export const getIcon = (key) => {
    return ICONS[key] || 'help-circle';
};

// Hobby list with icons
export const HOBBIES = [
    { id: 'sports', label: 'Sports', icon: ICONS.sports },
    { id: 'music', label: 'Music', icon: ICONS.music },
    { id: 'reading', label: 'Reading', icon: ICONS.reading },
    { id: 'gaming', label: 'Gaming', icon: ICONS.gaming },
    { id: 'cooking', label: 'Cooking', icon: ICONS.cooking },
    { id: 'travel', label: 'Travel', icon: ICONS.travel },
    { id: 'photography', label: 'Photography', icon: ICONS.photography },
    { id: 'art', label: 'Art', icon: ICONS.art },
    { id: 'fitness', label: 'Fitness', icon: ICONS.fitness },
    { id: 'yoga', label: 'Yoga', icon: ICONS.yoga },
    { id: 'hiking', label: 'Hiking', icon: ICONS.hiking },
    { id: 'dancing', label: 'Dancing', icon: ICONS.dancing },
    { id: 'movies', label: 'Movies', icon: ICONS.movies },
    { id: 'pets', label: 'Pets', icon: ICONS.pets },
    { id: 'technology', label: 'Technology', icon: ICONS.technology },
    { id: 'fashion', label: 'Fashion', icon: ICONS.fashion },
    { id: 'food', label: 'Food', icon: ICONS.food },
    { id: 'coffee', label: 'Coffee', icon: ICONS.coffee },
];
