const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    username: { type: String, required: true, unique: true },
    email: { type: String, required: true, unique: true },
    password_hash: { type: String, required: true },
    profile_picture: { type: String, required: false },
    location: { type: String },
    friends: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    preferences: {
        drink: { type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Drink' }], default: [] },
        restaurant: { type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Restaurant' }], default: [] },
    },
});

module.exports = mongoose.model('User', userSchema);
