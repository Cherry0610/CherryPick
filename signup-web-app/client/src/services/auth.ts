import axios from 'axios';

const API_URL = 'http://localhost:5000/api/auth/';

export const registerUser = async (userData) => {
  try {
    const response = await axios.post(`${API_URL}signup`, userData);
    return response.data;
  } catch (error) {
    throw new Error(error.response.data.message || 'Registration failed');
  }
};

export const signInUser = async (credentials) => {
  try {
    const response = await axios.post(`${API_URL}signin`, credentials);
    return response.data;
  } catch (error) {
    throw new Error(error.response.data.message || 'Sign-in failed');
  }
};