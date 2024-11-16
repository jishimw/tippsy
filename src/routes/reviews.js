const express = require('express');
const Review = require('../models/Review');
const router = express.Router();
const mongoose = require('mongoose');

// Create a new review
router.post('/', async (req, res) => {
    console.log(req.body);  //debug

    const { user_id, drink_id, restaurant_id, rating, comment, impairment_level } = req.body;

    try {
        const newReview = new Review({
            _id: new mongoose.Types.ObjectId(),
            user_id,
            drink_id,
            restaurant_id,
            rating,
            comment,
            impairment_level,
        });

        await newReview.save();
        res.status(201).json({ message: 'Review added successfully!' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to add review', message: error.message });
    }
});

// Fetch reviews for a drink
router.get('/drink/:drinkId', async (req, res) => {
    try {
        const reviews = await Review.find({ drink_id: req.params.drinkId }).populate('user_id', 'username');
        res.status(200).json(reviews);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch reviews', message: error.message });
    }
});

//Fetch reviews for all drinks
router.get('/drink', async (req, res) => {
    try {
        const reviews = await Review.find({ drink_id: { $ne: null } }).populate('user_id', 'username');
        res.status(200).json(reviews);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch reviews', message: error.message });
    }
});

// Fetch reviews for a restaurant
router.get('/restaurant/:restaurantId', async (req, res) => {
    try {
        const reviews = await Review.find({ restaurant_id: req.params.restaurantId }).populate('user_id', 'username');
        res.status(200).json(reviews);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch reviews', message: error.message });
    }
});

//Fetch reviews for all restaurants
router.get('/restaurant', async (req, res) => {
    try {
        const reviews = await Review.find({ restaurant_id: { $ne: null } }).populate('user_id', 'username');
        res.status(200).json(reviews);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch reviews', message: error.message });
    }
});

module.exports = router;