const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    drink_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Drink', required: true },
    restaurant_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Restaurant' },
    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String },
    timestamp: { type: Date, default: Date.now },
    impairment_level: { type: Number, min: 1, max: 5 },
});

module.exports = mongoose.model('Review', reviewSchema);
