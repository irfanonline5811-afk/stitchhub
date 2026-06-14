// const { db } = require('../config/firebase'); // Firebase removed
const express = require('express');
const Joi = require('joi');

const router = express.Router();

// Validation schemas
const searchTailorsSchema = Joi.object({
  latitude: Joi.number().min(-90).max(90).required(),
  longitude: Joi.number().min(-180).max(180).required(),
  radiusKm: Joi.number().min(0.1).max(100).default(10),
  serviceType: Joi.string().optional(),
  minRating: Joi.number().min(0).max(5).optional()
});

// Get all tailors
router.get('/', async (req, res) => {
  try {
    /*
    const tailorsSnapshot = await db
      .collection('tailors')
      .where('isAvailable', '==', true)
      .get();

    const tailors = [];
    tailorsSnapshot.forEach(doc => {
      tailors.push(doc.data());
    });
    */
    const tailors = []; // Placeholder

    res.json({
      tailors,
      count: tailors.length
    });
  } catch (error) {
    console.error('Get tailors error:', error);
    res.status(500).json({
      error: 'Failed to fetch tailors',
      message: error.message
    });
  }
});

// Search tailors by location
router.post('/search', async (req, res) => {
  try {
    const { error, value } = searchTailorsSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { latitude, longitude, radiusKm, serviceType, minRating } = value;

    let query = db
      .collection('tailors')
      .where('isAvailable', '==', true);

    if (serviceType) {
      query = query.where('services', 'array-contains', serviceType);
    }

    if (minRating) {
      query = query.where('rating', '>=', minRating);
    }

    /*
    const tailorsSnapshot = await query.get();
    const allTailors = [];
    
    tailorsSnapshot.forEach(doc => {
      allTailors.push(doc.data());
    });
    */
    const allTailors = []; // Placeholder

    // Filter by distance
    const nearbyTailors = allTailors.filter(tailor => {
      const distance = calculateDistance(
        latitude,
        longitude,
        tailor.latitude,
        tailor.longitude
      );
      return distance <= radiusKm;
    });

    // Sort by distance
    nearbyTailors.sort((a, b) => {
      const distanceA = calculateDistance(
        latitude,
        longitude,
        a.latitude,
        a.longitude
      );
      const distanceB = calculateDistance(
        latitude,
        longitude,
        b.latitude,
        b.longitude
      );
      return distanceA - distanceB;
    });

    res.json({
      tailors: nearbyTailors,
      count: nearbyTailors.length
    });
  } catch (error) {
    console.error('Search tailors error:', error);
    res.status(500).json({
      error: 'Failed to search tailors',
      message: error.message
    });
  }
});

// Get tailor by ID
router.get('/:tailorId', async (req, res) => {
  try {
    const { tailorId } = req.params;

    // const tailorDoc = await db.collection('tailors').doc(tailorId).get(); // Firebase removed
    const tailorDoc = { exists: false }; // Placeholder
    
    if (!tailorDoc.exists) {
      return res.status(404).json({
        error: 'Tailor not found'
      });
    }

    const tailorData = tailorDoc.data();

    res.json({
      tailor: tailorData
    });
  } catch (error) {
    console.error('Get tailor error:', error);
    res.status(500).json({
      error: 'Failed to get tailor',
      message: error.message
    });
  }
});

// Update tailor availability
router.put('/:tailorId/availability', async (req, res) => {
  try {
    const { tailorId } = req.params;
    const { isAvailable } = req.body;

    if (typeof isAvailable !== 'boolean') {
      return res.status(400).json({
        error: 'isAvailable must be a boolean'
      });
    }

    await db.collection('tailors').doc(tailorId).update({
      isAvailable,
      updatedAt: new Date()
    });

    res.json({
      message: 'Availability updated successfully'
    });
  } catch (error) {
    console.error('Update availability error:', error);
    res.status(500).json({
      error: 'Failed to update availability',
      message: error.message
    });
  }
});

// Update tailor pricing
router.put('/:tailorId/pricing', async (req, res) => {
  try {
    const { tailorId } = req.params;
    const { pricing } = req.body;

    if (!pricing || typeof pricing !== 'object') {
      return res.status(400).json({
        error: 'Pricing must be an object'
      });
    }

    await db.collection('tailors').doc(tailorId).update({
      pricing,
      updatedAt: new Date()
    });

    res.json({
      message: 'Pricing updated successfully'
    });
  } catch (error) {
    console.error('Update pricing error:', error);
    res.status(500).json({
      error: 'Failed to update pricing',
      message: error.message
    });
  }
});

// Add work sample
router.put('/:tailorId/work-samples', async (req, res) => {
  try {
    const { tailorId } = req.params;
    const { imageUrl } = req.body;

    if (!imageUrl) {
      return res.status(400).json({
        error: 'Image URL is required'
      });
    }

    // Get current work samples
    const tailorDoc = await db.collection('tailors').doc(tailorId).get();
    
    if (!tailorDoc.exists) {
      return res.status(404).json({
        error: 'Tailor not found'
      });
    }

    const tailorData = tailorDoc.data();
    const currentSamples = tailorData.workSamples || [];
    currentSamples.push(imageUrl);

    await db.collection('tailors').doc(tailorId).update({
      workSamples: currentSamples,
      updatedAt: new Date()
    });

    res.json({
      message: 'Work sample added successfully'
    });
  } catch (error) {
    console.error('Add work sample error:', error);
    res.status(500).json({
      error: 'Failed to add work sample',
      message: error.message
    });
  }
});

// Update tailor location
router.put('/:tailorId/location', async (req, res) => {
  try {
    const { tailorId } = req.params;
    const { latitude, longitude } = req.body;

    if (typeof latitude !== 'number' || typeof longitude !== 'number') {
      return res.status(400).json({
        error: 'Latitude and longitude must be numbers'
      });
    }

    await db.collection('tailors').doc(tailorId).update({
      latitude,
      longitude,
      updatedAt: new Date()
    });

    res.json({
      message: 'Location updated successfully'
    });
  } catch (error) {
    console.error('Update location error:', error);
    res.status(500).json({
      error: 'Failed to update location',
      message: error.message
    });
  }
});

// Update tailor services
router.put('/:tailorId/services', async (req, res) => {
  try {
    const { tailorId } = req.params;
    const { services } = req.body;

    if (!Array.isArray(services)) {
      return res.status(400).json({
        error: 'Services must be an array'
      });
    }

    await db.collection('tailors').doc(tailorId).update({
      services,
      updatedAt: new Date()
    });

    res.json({
      message: 'Services updated successfully'
    });
  } catch (error) {
    console.error('Update services error:', error);
    res.status(500).json({
      error: 'Failed to update services',
      message: error.message
    });
  }
});

// Update tailor schedule
router.put('/:tailorId/schedule', async (req, res) => {
  try {
    const { tailorId } = req.params;
    const { availableDays, startTime, endTime } = req.body;

    if (!Array.isArray(availableDays)) {
      return res.status(400).json({
        error: 'Available days must be an array'
      });
    }

    if (!startTime || !endTime) {
      return res.status(400).json({
        error: 'Start time and end time are required'
      });
    }

    await db.collection('tailors').doc(tailorId).update({
      availableDays,
      startTime,
      endTime,
      updatedAt: new Date()
    });

    res.json({
      message: 'Schedule updated successfully'
    });
  } catch (error) {
    console.error('Update schedule error:', error);
    res.status(500).json({
      error: 'Failed to update schedule',
      message: error.message
    });
  }
});

// Helper function to calculate distance between two coordinates
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in kilometers
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

module.exports = router;



