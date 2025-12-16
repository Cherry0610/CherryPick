// Firebase Admin SDK Configuration
import admin from 'firebase-admin';
import { readFileSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

let firebaseApp;
let db, auth, storage;

try {
  const serviceAccountPath = join(__dirname, '..', 'serviceAccountKey.json');
  
  // Check if service account key exists
  if (existsSync(serviceAccountPath)) {
    // Try to load service account key
    const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));

    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: process.env.FIREBASE_PROJECT_ID || 'cherrypick-67246',
    });

    console.log('✅ Firebase Admin SDK initialized successfully with service account');
  } else {
    // Try to initialize with default credentials (for development/emulator)
    try {
      // Check if Firebase is already initialized
      if (admin.apps.length === 0) {
        firebaseApp = admin.initializeApp({
          projectId: process.env.FIREBASE_PROJECT_ID || 'cherrypick-67246',
        });
        console.log('✅ Firebase Admin SDK initialized with default credentials');
      } else {
        firebaseApp = admin.app();
        console.log('✅ Using existing Firebase Admin SDK instance');
      }
    } catch (initError) {
      console.warn('⚠️  Firebase Admin SDK initialization failed:', initError.message);
      console.warn('⚠️  Make sure you have serviceAccountKey.json in the backend directory');
      console.warn('⚠️  Or set up Firebase emulator/credentials for development');
      console.warn('⚠️  The app will continue but Firebase features may not work');
    }
  }

  // Initialize Firebase services only if app is initialized
  if (firebaseApp) {
    db = admin.firestore();
    auth = admin.auth();
    storage = admin.storage();
  }
} catch (error) {
  console.error('❌ Critical error initializing Firebase:', error.message);
  console.error('⚠️  Firebase features will not be available');
}

// Export with fallback to prevent crashes
export { db, auth, storage };
export default firebaseApp;



