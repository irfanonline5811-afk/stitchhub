// const { db } = require('../config/firebase'); // Firebase removed
const express = require('express');
const { v4: uuidv4 } = require('uuid');
const Joi = require('joi');
const { 
  sendOrderConfirmationSMS, 
  sendOrderStatusUpdateSMS, 
  sendNewOrderNotificationSMS 
} = require('../config/twilio');

const router = express.Router();

// Validation schemas
const createOrderSchema = Joi.object({
  customerId: Joi.string().required(),
  tailorId: Joi.string().required(),
  customerName: Joi.string().required(),
  tailorName: Joi.string().required(),
  serviceType: Joi.string().required(),
  description: Joi.string().required(),
  images: Joi.array().items(Joi.string()).default([]),
  measurements: Joi.object().default({}),
  price: Joi.number().min(0).required(),
  paymentMethod: Joi.string().valid('cashOnDelivery', 'online').default('cashOnDelivery'),
  notes: Joi.string().optional(),
  customerAddress: Joi.string().optional(),
  tailorAddress: Joi.string().optional()
});

const updateOrderStatusSchema = Joi.object({
  status: Joi.string().valid('pending', 'confirmed', 'inProgress', 'readyForPickup', 'completed', 'cancelled').required()
});

const addReviewSchema = Joi.object({
  rating: Joi.number().min(1).max(5).required(),
  review: Joi.string().optional()
});

// Create order
router.post('/', async (req, res) => {
  try {
    const { error, value } = createOrderSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const orderId = uuidv4();
    const now = new Date();

    const orderData = {
      id: orderId,
      ...value,
      status: 'pending',
      paymentStatus: 'pending',
      orderDate: now,
      createdAt: now,
      updatedAt: now
    };

    // await db.collection('orders').doc(orderId).set(orderData); // Firebase removed

    // Send notification to tailor
    try {
      const tailorDoc = await db.collection('tailors').doc(value.tailorId).get();
      if (tailorDoc.exists) {
        const tailorData = tailorDoc.data();
        await sendNewOrderNotificationSMS(
          tailorData.phone,
          orderId,
          value.customerName,
          value.serviceType
        );
      }
    } catch (smsError) {
      console.error('Failed to send SMS notification:', smsError);
      // Don't fail the order creation if SMS fails
    }

    res.status(201).json({
      message: 'Order created successfully',
      order: orderData
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({
      error: 'Failed to create order',
      message: error.message
    });
  }
});

// Get customer orders
router.get('/customer/:customerId', async (req, res) => {
  try {
    const { customerId } = req.params;
    const { status } = req.query;

    let query = db
      .collection('orders')
      .where('customerId', '==', customerId)
      .orderBy('createdAt', 'desc');

    if (status) {
      query = query.where('status', '==', status);
    }

    /*
    const ordersSnapshot = await query.get();
    const orders = [];
    
    ordersSnapshot.forEach(doc => {
      orders.push(doc.data());
    });
    */
    const orders = []; // Placeholder

    res.json({
      orders,
      count: orders.length
    });
  } catch (error) {
    console.error('Get customer orders error:', error);
    res.status(500).json({
      error: 'Failed to fetch customer orders',
      message: error.message
    });
  }
});

// Get tailor orders
router.get('/tailor/:tailorId', async (req, res) => {
  try {
    const { tailorId } = req.params;
    const { status } = req.query;

    let query = db
      .collection('orders')
      .where('tailorId', '==', tailorId)
      .orderBy('createdAt', 'desc');

    if (status) {
      query = query.where('status', '==', status);
    }

    /*
    const ordersSnapshot = await query.get();
    const orders = [];
    
    ordersSnapshot.forEach(doc => {
      orders.push(doc.data());
    });
    */
    const orders = []; // Placeholder

    res.json({
      orders,
      count: orders.length
    });
  } catch (error) {
    console.error('Get tailor orders error:', error);
    res.status(500).json({
      error: 'Failed to fetch tailor orders',
      message: error.message
    });
  }
});

// Get order by ID
router.get('/:orderId', async (req, res) => {
  try {
    const { orderId } = req.params;

    // const orderDoc = await db.collection('orders').doc(orderId).get(); // Firebase removed
    const orderDoc = { exists: false }; // Placeholder
    
    if (!orderDoc.exists) {
      return res.status(404).json({
        error: 'Order not found'
      });
    }

    const orderData = orderDoc.data();

    res.json({
      order: orderData
    });
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({
      error: 'Failed to get order',
      message: error.message
    });
  }
});

// Update order status
router.put('/:orderId/status', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { error, value } = updateOrderStatusSchema.validate(req.body);
    
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { status } = value;
    const now = new Date();
    const updateData = {
      status,
      updatedAt: now
    };

    // Add specific date fields based on status
    switch (status) {
      case 'confirmed':
        updateData.confirmedDate = now;
        break;
      case 'completed':
        updateData.completedDate = now;
        break;
      case 'readyForPickup':
        updateData.pickupDate = now;
        break;
    }

    await db.collection('orders').doc(orderId).update(updateData);

    // Send SMS notification to customer
    try {
      const orderDoc = await db.collection('orders').doc(orderId).get();
      if (orderDoc.exists) {
        const orderData = orderDoc.data();
        const customerDoc = await db.collection('users').doc(orderData.customerId).get();
        
        if (customerDoc.exists) {
          const customerData = customerDoc.data();
          await sendOrderStatusUpdateSMS(
            customerData.phone,
            orderId,
            status
          );
        }
      }
    } catch (smsError) {
      console.error('Failed to send SMS notification:', smsError);
      // Don't fail the status update if SMS fails
    }

    res.json({
      message: 'Order status updated successfully'
    });
  } catch (error) {
    console.error('Update order status error:', error);
    res.status(500).json({
      error: 'Failed to update order status',
      message: error.message
    });
  }
});

// Update payment status
router.put('/:orderId/payment', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { paymentStatus } = req.body;

    if (!['pending', 'paid', 'failed', 'refunded'].includes(paymentStatus)) {
      return res.status(400).json({
        error: 'Invalid payment status'
      });
    }

    await db.collection('orders').doc(orderId).update({
      paymentStatus,
      updatedAt: new Date()
    });

    res.json({
      message: 'Payment status updated successfully'
    });
  } catch (error) {
    console.error('Update payment status error:', error);
    res.status(500).json({
      error: 'Failed to update payment status',
      message: error.message
    });
  }
});

// Add order review
router.post('/:orderId/review', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { error, value } = addReviewSchema.validate(req.body);
    
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { rating, review } = value;

    // Update the order with review
    await db.collection('orders').doc(orderId).update({
      rating,
      review,
      updatedAt: new Date()
    });

    // Get order details for review
    const orderDoc = await db.collection('orders').doc(orderId).get();
    if (orderDoc.exists) {
      const orderData = orderDoc.data();
      
      // Create review document
      const reviewId = uuidv4();
      const reviewData = {
        id: reviewId,
        orderId,
        customerId: orderData.customerId,
        tailorId: orderData.tailorId,
        customerName: orderData.customerName,
        tailorName: orderData.tailorName,
        rating,
        review: review || '',
        createdAt: new Date(),
        updatedAt: new Date()
      };

      await db.collection('reviews').doc(reviewId).set(reviewData);

      // Update tailor's rating
      await updateTailorRating(orderData.tailorId);
    }

    res.json({
      message: 'Review added successfully'
    });
  } catch (error) {
    console.error('Add review error:', error);
    res.status(500).json({
      error: 'Failed to add review',
      message: error.message
    });
  }
});

// Get orders by status
router.get('/status/:status', async (req, res) => {
  try {
    const { status } = req.params;

    if (!['pending', 'confirmed', 'inProgress', 'readyForPickup', 'completed', 'cancelled'].includes(status)) {
      return res.status(400).json({
        error: 'Invalid status'
      });
    }

    const ordersSnapshot = await db
      .collection('orders')
      .where('status', '==', status)
      .orderBy('createdAt', 'desc')
      .get();

    const orders = [];
    ordersSnapshot.forEach(doc => {
      orders.push(doc.data());
    });

    res.json({
      orders,
      count: orders.length
    });
  } catch (error) {
    console.error('Get orders by status error:', error);
    res.status(500).json({
      error: 'Failed to fetch orders by status',
      message: error.message
    });
  }
});

// Cancel order
router.put('/:orderId/cancel', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { reason } = req.body;

    await db.collection('orders').doc(orderId).update({
      status: 'cancelled',
      notes: reason || 'Order cancelled',
      updatedAt: new Date()
    });

    res.json({
      message: 'Order cancelled successfully'
    });
  } catch (error) {
    console.error('Cancel order error:', error);
    res.status(500).json({
      error: 'Failed to cancel order',
      message: error.message
    });
  }
});

// Helper function to update tailor rating
async function updateTailorRating(tailorId) {
  try {
    // Get all reviews for this tailor
    const reviewsSnapshot = await db
      .collection('reviews')
      .where('tailorId', '==', tailorId)
      .get();

    if (reviewsSnapshot.docs.length > 0) {
      let totalRating = 0;
      reviewsSnapshot.docs.forEach(doc => {
        const reviewData = doc.data();
        totalRating += reviewData.rating;
      });

      const averageRating = totalRating / reviewsSnapshot.docs.length;

      await db.collection('tailors').doc(tailorId).update({
        rating: averageRating,
        totalReviews: reviewsSnapshot.docs.length,
        updatedAt: new Date()
      });
    }
  } catch (error) {
    console.error('Error updating tailor rating:', error);
  }
}

module.exports = router;



