// CherryPick Backend Server
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { errorHandler, notFound } from './middleware/errorHandler.js';

// Import routes
import productsRoutes from './routes/products.js';
import pricesRoutes from './routes/prices.js';
import storesRoutes from './routes/stores.js';
import receiptsRoutes from './routes/receipts.js';
import wishlistRoutes from './routes/wishlist.js';
import expensesRoutes from './routes/expenses.js';
import navigationRoutes from './routes/navigation.js';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'CherryPick Backend API is running',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use('/api/products', productsRoutes);
app.use('/api/prices', pricesRoutes);
app.use('/api/stores', storesRoutes);
app.use('/api/receipts', receiptsRoutes);
app.use('/api/wishlist', wishlistRoutes);
app.use('/api/expenses', expensesRoutes);
app.use('/api/navigation', navigationRoutes);

// Legacy routes (for backward compatibility with old frontend)
// These are handled by the route modules above

// Error handling
app.use(notFound);
app.use(errorHandler);

// Start server
const server = app.listen(PORT, () => {
  console.log('\n--- CherryPick Backend Running ---');
  console.log(`Server is listening on: http://localhost:${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log('\nAvailable endpoints:');
  console.log('  GET  /health');
  console.log('  GET  /api/products/search?q=query');
  console.log('  GET  /api/products/:id');
  console.log('  GET  /api/prices/product/:productId');
  console.log('  GET  /api/prices/compare/:productId');
  console.log('  POST /api/prices');
  console.log('  GET  /api/stores');
  console.log('  GET  /api/stores/:id');
  console.log('  GET  /api/navigation/nearby?lat=..&lng=..');
  console.log('  GET  /api/receipts (requires auth)');
  console.log('  POST /api/receipts/upload (requires auth)');
  console.log('  GET  /api/wishlist (requires auth)');
  console.log('  POST /api/wishlist (requires auth)');
  console.log('  GET  /api/expenses (requires auth)');
  console.log('  GET  /api/expenses/summary (requires auth)');
  console.log('----------------------------------\n');
});

// Handle server errors (e.g., port already in use)
server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`\n❌ Error: Port ${PORT} is already in use.`);
    console.error(`   Please stop the other process or use a different port.`);
    console.error(`   To find the process: lsof -ti:${PORT}`);
    console.error(`   To kill it: kill $(lsof -ti:${PORT})\n`);
    process.exit(1);
  } else {
    console.error('❌ Server error:', error);
    process.exit(1);
  }
});

export default app;
