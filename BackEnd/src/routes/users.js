const express = require('express');
const User = require('../models/User');
const Review = require('../models/Review');
const Drink = require('../models/Drink');
const Restaurant = require('../models/Restaurant');
const router = express.Router();
const mongoose = require('mongoose');


// Fetch user profile
router.get('/:userId', async (req, res) => {
    try {
        const user = await User.findById(req.params.userId)
            .populate('preferences.drink', 'name') // Ensure the Drink model is registered
            .populate('preferences.restaurant', 'name') // Ensure the Restaurant model is registered
            .populate('friends', 'username profile_picture'); // Ensure 'friends' correctly references the User model
        
        const reviews = await Review.find({ user_id: req.params.userId })
            .populate('drink_id', 'name') // Ensure the Drink model is registered
            .populate('restaurant_id', 'name'); // Ensure the Restaurant model is registered

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Structure the response
        res.status(200).json({
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                profilePicture: user.profile_picture || "",
                preferences: {
                    drink: user.preferences.drink.map(drink => drink.name), // Map to names
                    restaurant: user.preferences.restaurant.map(restaurant => restaurant.name), // Map to names
                },
                friends: user.friends.map(friend => ({
                    id: friend._id,
                    username: friend.username,
                    profilePicture: friend.profile_picture,
                })),
            },
            reviews: reviews.map(review => ({
                id: review._id,
                drinkName: review.drink_id?.name || null,
                restaurantName: review.restaurant_id?.name || null,
                rating: review.rating,
                comment: review.comment,
                impairmentLevel: review.impairment_level,
            })),
        });        
        console.log("\nFetched User -> ", user);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching profile', error: error.message });
    }
});


// Update user profile (When saving profile_picture, decode the base64 string to a file and save it to the server)
router.put('/:userId', async (req, res) => {
    const { username, profile_picture, preferences } = req.body;

    try {
        const drinkIds = await Promise.all(preferences.drink.map(async (drinkName) => {
            const drink = await Drink.findOne({ name: drinkName });
            if (!drink) throw new Error(`Drink '${drinkName}' not found`);
            return drink._id;
        }));

        const restaurantIds = await Promise.all(preferences.restaurant.map(async (restaurantName) => {
            const restaurant = await Restaurant.findOne({ name: restaurantName });
            if (!restaurant) throw new Error(`Restaurant '${restaurantName}' not found`);
            return restaurant._id;
        }));

        const updatedUser = await User.findByIdAndUpdate(
            req.params.userId,
            {
                username,
                profile_picture,
                preferences: { drink: drinkIds, restaurant: restaurantIds },
            },
            { new: true }
        ).populate('preferences.drink', 'name')
         .populate('preferences.restaurant', 'name');

        res.status(200).json({
            id: updatedUser._id,
            username: updatedUser.username,
            profilePicture: updatedUser.profile_picture,
            preferences: {
                drink: updatedUser.preferences.drink.map((drink) => drink.name),
                restaurant: updatedUser.preferences.restaurant.map((restaurant) => restaurant.name),
            },
        });
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ message: 'Error updating profile', error: error.message });
    }
});

module.exports = router;