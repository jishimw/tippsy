const express = require('express');
const mongoose = require('mongoose');
const Restaurant = require('../models/Restaurant');
const Review = require('../models/Review');
const router = express.Router();

router.get('/name/:restaurantName', async (req, res) => {
    console.log('Fetching restaurant:', req.params.restaurantName); // Log the restaurant name
    try {
        const restaurant = await Restaurant.findOne({ name: req.params.restaurantName })
            .populate('drinks');

        if (!restaurant) {
            console.log('Restaurant not found:', req.params.restaurantName); // Log if restaurant is not found
            return res.status(404).json({ message: 'Restaurant not found' });
        }

        const reviews = await Review.find({ restaurant_id: restaurant._id })
            .populate({ path: 'user_id', select: 'username avatar' })
            .sort({ timestamp: -1 });

        const totalRatings = reviews.length;
        const averageRating = totalRatings
            ? (reviews.reduce((sum, review) => sum + review.rating, 0) / totalRatings).toFixed(1)
            : 'No ratings yet';

        const response = {
            id: restaurant._id.toString(),
            name: restaurant.name,
            location: restaurant.location,
            averageRating,
            totalReviews: totalRatings,
            drinks: restaurant.drinks,
            reviews: reviews.map(review => ({
                id: review._id,
                user: {
                    username: review.user_id?.username || "Anonymous", // Handle null user_id
                    avatar: review.user_id?.avatar || "" // Handle null user_id
                },
                drinkName: null, // Add this field
                restaurantName: null, // Add this field
                rating: review.rating,
                comment: review.comment,
                impairment_level: review.impairment_level,
            })),
        };

        console.log('Sending response:', response); // Log the response
        res.status(200).json(response);
    } catch (error) {
        console.error('Error fetching restaurant:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;