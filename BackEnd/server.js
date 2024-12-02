const express = require('express');
const app = express();
const mongoose = require('mongoose');
require('dotenv').config();
const cors = require('cors');


const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors());

// Routes
app.get('/', (req, res) => res.send('TIPPSY API is running!'));

// Import routes
const authRoutes = require('./src/routes/auth');
const reviewRoutes = require('./src/routes/reviews');
const searchRoutes = require('./src/routes/search');

// Use routes
app.use('/auth', authRoutes);
app.use('/reviews', reviewRoutes);
app.use('/search', searchRoutes);

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.error(err));

// Start the server
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
