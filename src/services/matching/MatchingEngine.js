/**
 * Matching Engine Service
 * Core algorithm for determining compatibility between users
 */

export class MatchingEngine {
    /**
     * Calculate match score between current user and potential match
     * @param {Object} userProfile - Current user's profile
     * @param {Object} userPreferences - Current user's preferences
     * @param {Object} otherProfile - Other user's profile
     * @param {Object} otherPreferences - Other user's preferences
     * @returns {Object} - { isMatch: boolean, score: number }
     */
    static calculateMatch(userProfile, userPreferences, otherProfile, otherPreferences) {
        let score = 0;
        const weights = {
            gender: 100, // Must match
            age: 20,
            lifestyle: 15,
            hobbies: 10,
            personality: 5,
        };

        // 1. Gender Preference Check (MUST MATCH)
        const genderMatch = this.checkGenderPreference(
            userProfile.gender,
            userPreferences.genderPreference,
            otherProfile.gender,
            otherPreferences.genderPreference
        );

        if (!genderMatch) {
            return { isMatch: false, score: 0 };
        }
        score += weights.gender;

        // 2. Age Range Check
        const ageMatch = this.checkAgeRange(
            userProfile.age,
            userPreferences.ageRange,
            otherProfile.age,
            otherPreferences.ageRange
        );

        if (!ageMatch) {
            return { isMatch: false, score: 0 };
        }
        score += weights.age;

        // 3. Lifestyle Compatibility
        const lifestyleScore = this.calculateLifestyleScore(
            userPreferences.lifestyle,
            otherProfile,
            otherPreferences.lifestyle,
            userProfile
        );
        score += lifestyleScore * weights.lifestyle;

        // 4. Hobby Overlap
        const hobbyScore = this.calculateHobbyOverlap(
            userProfile.hobbies,
            otherProfile.hobbies
        );
        score += hobbyScore * weights.hobbies;

        // 5. Personality Compatibility
        const personalityScore = this.calculatePersonalityCompatibility(
            userProfile.personality,
            otherProfile.personality
        );
        score += personalityScore * weights.personality;

        // Determine if it's a match (threshold: 70% of max score)
        const maxScore = Object.values(weights).reduce((a, b) => a + b, 0);
        const matchThreshold = maxScore * 0.7;
        const isMatch = score >= matchThreshold;

        return { isMatch, score, maxScore };
    }

    /**
     * Check if gender preferences are mutually compatible
     */
    static checkGenderPreference(userGender, userPref, otherGender, otherPref) {
        // Check if user's preference matches other's gender
        const userMatches =
            userPref === 'all' ||
            userPref === otherGender ||
            (userPref === 'nonBinary' && otherGender === 'nonBinary');

        // Check if other's preference matches user's gender
        const otherMatches =
            otherPref === 'all' ||
            otherPref === userGender ||
            (otherPref === 'nonBinary' && userGender === 'nonBinary');

        return userMatches && otherMatches;
    }

    /**
     * Check if ages fall within each other's preferred ranges
     */
    static checkAgeRange(userAge, userAgeRange, otherAge, otherAgeRange) {
        const userInRange = otherAge >= userAgeRange.min && otherAge <= userAgeRange.max;
        const otherInRange = userAge >= otherAgeRange.min && userAge <= otherAgeRange.max;

        return userInRange && otherInRange;
    }

    /**
     * Calculate lifestyle compatibility score (0-1)
     */
    static calculateLifestyleScore(userPrefs, otherProfile, otherPrefs, userProfile) {
        let matches = 0;
        let total = 0;

        // Relationship type
        if (userPrefs.relationshipType && otherPrefs.relationshipType) {
            total++;
            if (userPrefs.relationshipType === otherPrefs.relationshipType) {
                matches++;
            }
        }

        // Smoking preference
        if (userPrefs.smoking !== 'any' && otherPrefs.smoking !== 'any') {
            total++;
            if (userPrefs.smoking === otherPrefs.smoking) {
                matches++;
            }
        }

        // Activity level
        if (userPrefs.activity !== 'any' && otherPrefs.activity !== 'any') {
            total++;
            if (userPrefs.activity === otherPrefs.activity) {
                matches++;
            }
        }

        // Pet preference
        if (
            userPrefs.petPreference !== 'both' &&
            otherPrefs.petPreference !== 'both' &&
            userPrefs.petPreference !== 'none' &&
            otherPrefs.petPreference !== 'none'
        ) {
            total++;
            if (userPrefs.petPreference === otherPrefs.petPreference) {
                matches++;
            }
        }

        return total > 0 ? matches / total : 0.5; // Default to 0.5 if no preferences set
    }

    /**
     * Calculate hobby overlap score (0-1)
     */
    static calculateHobbyOverlap(userHobbies, otherHobbies) {
        if (!userHobbies || !otherHobbies || userHobbies.length === 0 || otherHobbies.length === 0) {
            return 0.5; // Default if no hobbies
        }

        const overlap = userHobbies.filter(hobby => otherHobbies.includes(hobby)).length;
        const maxOverlap = Math.min(userHobbies.length, otherHobbies.length);

        return maxOverlap > 0 ? overlap / maxOverlap : 0;
    }

    /**
     * Calculate personality compatibility (0-1)
     * Introverts and extroverts can be compatible, but extreme differences are penalized
     */
    static calculatePersonalityCompatibility(userPersonality, otherPersonality) {
        if (userPersonality === undefined || otherPersonality === undefined) {
            return 0.5; // Default if not set
        }

        const difference = Math.abs(userPersonality - otherPersonality);
        // Normalize: 0 difference = 1.0, 100 difference = 0.0
        return 1 - difference / 100;
    }

    /**
     * Check if two users are within proximity distance
     */
    static isWithinProximity(userLocation, otherLocation, maxDistance) {
        const distance = this.calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            otherLocation.latitude,
            otherLocation.longitude
        );

        return distance <= maxDistance;
    }

    /**
     * Calculate distance between two coordinates using Haversine formula
     * @returns {number} Distance in meters
     */
    static calculateDistance(lat1, lon1, lat2, lon2) {
        const R = 6371e3; // Earth's radius in meters
        const φ1 = (lat1 * Math.PI) / 180;
        const φ2 = (lat2 * Math.PI) / 180;
        const Δφ = ((lat2 - lat1) * Math.PI) / 180;
        const Δλ = ((lon2 - lon1) * Math.PI) / 180;

        const a =
            Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
            Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return R * c; // Distance in meters
    }
}

export default MatchingEngine;
