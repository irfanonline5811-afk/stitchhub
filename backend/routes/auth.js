// const { auth, db } = require('../config/firebase'); // Firebase removed
const express = require('express');
const { v4: uuidv4 } = require('uuid');
const Joi = require('joi');

const router = express.Router();

// Validation schemas
const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  name: Joi.string().min(2).required(),
  phone: Joi.string().min(10).required(),
  userType: Joi.string().valid('customer', 'tailor').required()
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
});

// Register user
router.post('/register', async (req, res) => {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { email, password, name, phone, userType } = value;

    // Create user in Database (TODO: Implement with new DB)
    /*
    const userRecord = await auth.createUser({
      email,
      password,
      displayName: name
    });

    const userId = userRecord.uid;
    */
    const userId = uuidv4(); // Temporary placeholder UID
    const now = new Date();

    // Create user document
    const userData = {
      id: userId,
      email,
      name,
      phone,
      userType,
      createdAt: now,
      updatedAt: now
    };

    // await db.collection('users').doc(userId).set(userData); // Firebase removed

    // If tailor, create tailor document
    if (userType === 'tailor') {
      const tailorData = {
        ...userData,
        businessName: null,
        businessAddress: null,
        latitude: 0,
        longitude: 0,
        specialties: [],
        workSamples: [],
        pricing: {},
        availableDays: [],
        startTime: '09:00',
        endTime: '18:00',
        rating: 0,
        totalReviews: 0,
        isAvailable: true,
        description: null,
        services: []
      };

      // await db.collection('tailors').doc(userId).set(tailorData); // Firebase removed
    }

    res.status(201).json({
      message: 'User registered successfully',
      user: userData
    });
  } catch (error) {
    console.error('Registration error:', error);
    
    if (error.code === 'auth/email-already-exists') {
      return res.status(400).json({
        error: 'Email already exists'
      });
    }

    res.status(500).json({
      error: 'Registration failed',
      message: error.message
    });
  }
});

// Login user
router.post('/login', async (req, res) => {
  try {
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { email, password } = value;

    // Verify user credentials (TODO: Implement with new DB)
    /*
    const userRecord = await auth.getUserByEmail(email);
    
    // Get user data from Database
    const userDoc = await db.collection('users').doc(userRecord.uid).get();
    */
    const userDoc = { exists: false }; // Placeholder
    
    if (!userDoc.exists) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    const userData = userDoc.data();

    // If tailor, get tailor data
    let tailorData = null;
    /*
    if (userData.userType === 'tailor') {
      const tailorDoc = await db.collection('tailors').doc(userRecord.uid).get();
      if (tailorDoc.exists) {
        tailorData = tailorDoc.data();
      }
    }
    */

    res.json({
      message: 'Login successful',
      user: userData,
      tailor: tailorData
    });
  } catch (error) {
    console.error('Login error:', error);
    
    if (error.code === 'auth/user-not-found') {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    res.status(500).json({
      error: 'Login failed',
      message: error.message
    });
  }
});

// Get user profile
router.get('/profile/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    /*
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    const userData = userDoc.data();

    // If tailor, get tailor data
    let tailorData = null;
    if (userData.userType === 'tailor') {
      const tailorDoc = await db.collection('tailors').doc(userId).get();
      if (tailorDoc.exists) {
        tailorData = tailorDoc.data();
      }
    }
    */
    const userData = {}; // Placeholder
    let tailorData = null;

    res.json({
      user: userData,
      tailor: tailorData
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      error: 'Failed to get profile',
      message: error.message
    });
  }
});

// Update user profile
router.put('/profile/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const updateData = req.body;

    // Remove fields that shouldn't be updated directly
    delete updateData.id;
    delete updateData.createdAt;
    updateData.updatedAt = new Date();

    /*
    await db.collection('users').doc(userId).update(updateData);

    // Get updated user data
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    */
    const userData = {}; // Placeholder

    res.json({
      message: 'Profile updated successfully',
      user: userData
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      error: 'Failed to update profile',
      message: error.message
    });
  }
});

// Update tailor profile
router.put('/tailor/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const updateData = req.body;

    // Remove fields that shouldn't be updated directly
    delete updateData.id;
    delete updateData.createdAt;
    updateData.updatedAt = new Date();

    /*
    await db.collection('tailors').doc(userId).update(updateData);

    // Get updated tailor data
    const tailorDoc = await db.collection('tailors').doc(userId).get();
    const tailorData = tailorDoc.data();
    */
    const tailorData = {}; // Placeholder

    res.json({
      message: 'Tailor profile updated successfully',
      tailor: tailorData
    });
  } catch (error) {
    console.error('Update tailor profile error:', error);
    res.status(500).json({
      error: 'Failed to update tailor profile',
      message: error.message
    });
  }
});

// Delete user account
router.delete('/profile/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    /*
    // Delete from Firebase Auth
    await auth.deleteUser(userId);

    // Delete user document
    await db.collection('users').doc(userId).delete();

    // Delete tailor document if exists
    await db.collection('tailors').doc(userId).delete();
    */

    res.json({
      message: 'Account deleted successfully'
    });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({
      error: 'Failed to delete account',
      message: error.message
    });
  }
});

module.exports = router;



