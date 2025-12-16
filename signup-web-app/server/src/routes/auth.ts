import { Router } from 'express';
import { signUp, signIn } from '../controllers/authController';

const router = Router();

// Route for user sign-up
router.post('/signup', signUp);

// Route for user sign-in
router.post('/signin', signIn);

export default router;