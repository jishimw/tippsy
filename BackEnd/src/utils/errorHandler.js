// /src/utils/errorHandler.js
const errorHandler = (err, req, res) => {
    res.status(err.status || 500).json({
        error: true,
        message: err.message || 'Internal Server Error',
    });
};

module.exports = errorHandler;
