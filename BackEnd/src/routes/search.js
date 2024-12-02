const express = require('express');
const Drink = require('../models/Drink');
const Restaurant = require('../models/Restaurant');
const router = express.Router();
const mongoose = require('mongoose');
errorHandler = require('../utils/errorhandler');

// Search for drinks by name or category
router.get('/drinks', async (req, res) => {
    const { query } = req.query;

    if (!query) {
        return res.status(400).json({ error: 'Query parameter is required' });
    }

    try {
        const drinks = await Drink.find({
            $or: [
                { name: { $regex: query, $options: 'i' } },
                { category: { $regex: query, $options: 'i' } },
            ],
        });
        res.status(200).json(drinks);
    } catch (error) {
        errorHandler(error, req, res, next);
    }
});

// Search for restaurants by name or location
router.get('/restaurants', async (req, res) => {
    const { query } = req.query;

    if (!query) {
        return res.status(400).json({ error: 'Query parameter is required' });
    }

    try {
        const restaurants = await Restaurant.find({ name: { $regex: query, $options: 'i' } });
        res.status(200).json(restaurants);
    } catch (error) {
        errorHandler(error, req, res, next);
    }
});

module.exports = router;