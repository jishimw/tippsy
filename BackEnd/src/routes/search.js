const express = require('express');
const Drink = require('../models/Drink');
const Restaurant = require('../models/Restaurant');
const router = express.Router();
const mongoose = require('mongoose');
errorHandler = require('../utils/errorhandler');
const User = require('../models/User');

// Search (query) for drinks by name or category
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
        errorHandler(error, req, res);
    }
});

// Search (query) for restaurants by name
router.get('/restaurants', async (req, res) => {
    const { query } = req.query;

    if (!query) {
        return res.status(400).json({ error: 'Query parameter is required' });
    }

    try {
        const restaurants = await Restaurant.find({ name: { $regex: query, $options: 'i' } });
        res.status(200).json(restaurants);
    } catch (error) {
        errorHandler(error, req, res);
    }
});

// Fetch all drinks
router.get('/allDrinks', async (req, res) => {
    try {
        const drinks = await Drink.find({}, 'name'); // Fetch only the 'name' field
        res.status(200).json(drinks);
    } catch (error) {
        errorHandler(error, req, res);
    }
});

// Fetch all restaurants
router.get('/allRestaurants', async (req, res) => {
    try {
        const restaurants = await Restaurant.find({}, 'name'); // Fetch only the 'name' field
        res.status(200).json(restaurants);
    } catch (error) {
        errorHandler(error, req, res);
    }
});

// Search User by Username

router.get('/users', async (req, res) => {
    const { username } = req.query;

    if (!username) {
        return res.status(400).json({ error: 'Username query parameter is required' });
    }

    try {
        const users = await User.find({ username: { $regex: username, $options: 'i' } });
        res.status(200).json(users);
    } catch (error) {
        errorHandler(error, req, res);
    }
});



module.exports = router;