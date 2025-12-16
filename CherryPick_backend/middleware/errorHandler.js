// Error Handling Middleware
export const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Firebase errors
  if (err.code && err.code.startsWith('firebase/')) {
    return res.status(400).json({
      success: false,
      error: 'Firebase error',
      message: err.message,
    });
  }

  // Validation errors
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      error: 'Validation error',
      message: err.message,
    });
  }

  // Default error
  res.status(err.status || 500).json({
    success: false,
    error: err.message || 'Internal server error',
  });
};

// 404 handler
export const notFound = (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Route not found',
    path: req.path,
  });
};



