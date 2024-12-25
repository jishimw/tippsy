const express = require('express');
const Review = require('../models/Review');
const Drink = require('../models/Drink');
const router = express.Router();
const mongoose = require('mongoose');
errorHandler = require('../utils/errorhandler');

// Create a new review
router.post('/', async (req, res) => {
    const { user_id, drink_id, restaurant_id, rating, comment, impairment_level } = req.body;

    try {
        //if the same review was made by the same user for the same drink or restaurant, return an error
        const existingReview = await Review.findOne({ user_id, drink_id, restaurant_id, comment });
        if (existingReview) {
            return res.status(400).json({ message: 'Review already exists' });
        }

        const newReview = new Review({
            _id: new mongoose.Types.ObjectId(),
            user_id,
            drink_id,
            restaurant_id,
            rating,
            comment,
            impairment_level,
        });

        await newReview.save(); // Save the new review in the reviews collection
        //save the review in the reviews collection of tippsy database if the review is for a drink and not a restaurant
        if (drink_id) {
            await Drink.updateOne({ _id: drink_id }, { $push: { reviews: newReview._id } });
        }
        res.status(201).json({ message: 'Review added successfully!' });
    } catch (error) {
        if (error.name === 'ValidationError') {
            res.status(400).json({ message: error.message }); // Send validation error to the client
        } else {
            console.error(error);
            res.status(500).json({ message: 'Internal server error' });
        }
    }
});

// Fetch reviews for a drink
router.get('/drink', async (req, res) => {
    const { drinkId } = req.query; // Optional query parameter
    const filter = drinkId ? { drink_id: drinkId } : { drink_id: { $ne: null } };

    try {
        const reviews = await Review.find(filter).populate('user_id', 'username');
        res.status(200).json(reviews);
    } catch (error) {
        errorHandler(error, req, res);
    }
});


// Fetch reviews for a restaurant
router.get('/restaurant/:restaurantId', async (req, res) => {
    try {
        const reviews = await Review.find({ restaurant_id: req.params.restaurantId }).populate('user_id', 'username');
        res.status(200).json(reviews);
    } catch (error) {
        errorHandler(error, req, res);
    }
});

//Fetch reviews for all restaurants
router.get('/restaurant', async (req, res) => {
    try {
        const reviews = await Review.find({ restaurant_id: { $ne: null } }).populate('user_id', 'username');
        res.status(200).json(reviews);
    } catch (error) {
        errorHandler(error, req, res);
    }
});

module.exports = router;