import { Request, Response } from 'express';
import { User } from '../models/user';

export class AuthController {
  public async signUp(req: Request, res: Response): Promise<void> {
    const { username, email, password } = req.body;

    // Validate input
    if (!username || !email || !password) {
      res.status(400).json({ message: 'All fields are required' });
      return;
    }

    try {
      const newUser = new User({ username, email, password });
      await newUser.save();
      res.status(201).json({ message: 'User registered successfully' });
    } catch (error) {
      res.status(500).json({ message: 'Error registering user', error });
    }
  }

  public async signIn(req: Request, res: Response): Promise<void> {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      res.status(400).json({ message: 'All fields are required' });
      return;
    }

    try {
      const user = await User.findByEmail(email);
      if (!user || user.password !== password) {
        res.status(401).json({ message: 'Invalid credentials' });
        return;
      }

      res.status(200).json({ message: 'Sign in successful', user });
    } catch (error) {
      res.status(500).json({ message: 'Error signing in', error });
    }
  }
}