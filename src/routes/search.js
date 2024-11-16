const express = require('express');
const Drink = require('../models/Drink');
const Restaurant = require('../models/Restaurant');
const router = express.Router();
const mongoose = require('mongoose');

// Search for drinks by name or category
router.get('/drinks', async (req, res) => {
    const { query } = req.query;

    try {
        const drinks = await Drink.find({
            $or: [
                { name: { $regex: query, $options: 'i' } },
                { category: { $regex: query, $options: 'i' } },
            ],
        });
        res.status(200).json(drinks);
    } catch (error) {
        res.status(500).json({ error: 'Failed to search drinks', message: error.message });
    }
});

// Search for restaurants by name or location
router.get('/restaurants', async (req, res) => {
    const { query } = req.query;

    try {
        const restaurants = await Restaurant.find({ name: { $regex: query, $options: 'i' } });
        res.status(200).json(restaurants);
    } catch (error) {
        res.status(500).json({ error: 'Failed to search restaurants', message: error.message });
    }
});

module.exports = router;