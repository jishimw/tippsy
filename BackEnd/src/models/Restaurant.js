const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    name: { type: String, required: true },
    //GeoJSON (for geospatial indexing)!!!!
    location: {
        type: {
            type: String, // GeoJSON requires this field to specify the type of geometry
            enum: ['Point'], // Only 'Point' is valid for this schema
            required: true,
            default: 'Point',
        },
        coordinates: {
            type: [Number], // Array of numbers: [longitude, latitude],
            required: true,
            default: [0, 0], // Default location: Null Island
        },
    },
    drinks: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Drink', }],      // Array of drink IDs that the restaurant serves (references to the 'drinks' collection) 
    ratingsId: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Rating',  }],
    reviews: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Review', }],
});

// Add geospatial index to the 'location' field
restaurantSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Restaurant', restaurantSchema);