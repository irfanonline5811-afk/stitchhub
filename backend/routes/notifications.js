const express = require('express');
const { sendSMS } = require('../config/twilio');
const { sendPush } = require('../config/firebase');
const Joi = require('joi');

const router = express.Router();

// Validation for Push Notification
const pushNotificationSchema = Joi.object({
  token: Joi.string().required(),
  title: Joi.string().required(),
  body: Joi.string().required(),
  data: Joi.object().optional()
});

// Send Push Notification
router.post('/send-push', async (req, res) => {
  try {
    const { error, value } = pushNotificationSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: 'Validation error', details: error.details[0].message });
    }

    const { token, title, body, data } = value;
    const result = await sendPush(token, title, body, data || {});

    if (result.success) {
      res.json({ message: 'Push notification sent successfully', response: result.response });
    } else {
      res.status(500).json({ error: 'Failed to send push notification', details: result.error });
    }
  } catch (error) {
    res.status(500).json({ error: 'Unexpected error', message: error.message });
  }
});

// Validation schemas
const sendSMSSchema = Joi.object({
  to: Joi.string().required(),
  message: Joi.string().required()
});

const sendOrderConfirmationSchema = Joi.object({
  customerPhone: Joi.string().required(),
  orderId: Joi.string().required(),
  tailorName: Joi.string().required()
});

const sendOrderStatusUpdateSchema = Joi.object({
  customerPhone: Joi.string().required(),
  orderId: Joi.string().required(),
  status: Joi.string().required()
});

const sendNewOrderNotificationSchema = Joi.object({
  tailorPhone: Joi.string().required(),
  orderId: Joi.string().required(),
  customerName: Joi.string().required(),
  serviceType: Joi.string().required()
});

const sendPaymentReminderSchema = Joi.object({
  customerPhone: Joi.string().required(),
  orderId: Joi.string().required(),
  amount: Joi.number().required()
});

const sendPickupReminderSchema = Joi.object({
  customerPhone: Joi.string().required(),
  orderId: Joi.string().required(),
  tailorName: Joi.string().required(),
  tailorAddress: Joi.string().required()
});

const sendDeliveryConfirmationSchema = Joi.object({
  customerPhone: Joi.string().required(),
  orderId: Joi.string().required()
});

const sendReviewRequestSchema = Joi.object({
  customerPhone: Joi.string().required(),
  orderId: Joi.string().required(),
  tailorName: Joi.string().required()
});

// Send generic SMS
router.post('/sms', async (req, res) => {
  try {
    const { error, value } = sendSMSSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { to, message } = value;
    const result = await sendSMS(to, message);

    if (result.success) {
      res.json({
        message: 'SMS sent successfully',
        sid: result.sid
      });
    } else {
      res.status(500).json({
        error: 'Failed to send SMS',
        details: result.error
      });
    }
  } catch (error) {
    console.error('Send SMS error:', error);
    res.status(500).json({
      error: 'Failed to send SMS',
      message: error.message
    });
  }
});

// Send order confirmation SMS
router.post('/order-confirmation', async (req, res) => {
  try {
    const { error, value } = sendOrderConfirmationSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { customerPhone, orderId, tailorName } = value;
    const result = await sendOrderConfirmationSMS(customerPhone, orderId, tailorName);

    if (result.success) {
      res.json({
        message: 'Order confirmation SMS sent successfully',
        sid: result.sid
      });
    } else {
      res.status(500).json({
        error: 'Failed to send order confirmation SMS',
        details: result.error
      });
    }
  } catch (error) {
    console.error('Send order confirmation SMS error:', error);
    res.status(500).json({
      error: 'Failed to send order confirmation SMS',
      message: error.message
    });
  }
});

// Send order status update SMS
router.post('/order-status-update', async (req, res) => {
  try {
    const { error, value } = sendOrderStatusUpdateSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { customerPhone, orderId, status } = value;
    const result = await sendOrderStatusUpdateSMS(customerPhone, orderId, status);

    if (result.success) {
      res.json({
        message: 'Order status update SMS sent successfully',
        sid: result.sid
      });
    } else {
      res.status(500).json({
        error: 'Failed to send order status update SMS',
        details: result.error
      });
    }
  } catch (error) {
    console.error('Send order status update SMS error:', error);
    res.status(500).json({
      error: 'Failed to send order status update SMS',
      message: error.message
    });
  }
});

// Send new order notification SMS
router.post('/new-order-notification', async (req, res) => {
  try {
    const { error, value } = sendNewOrderNotificationSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { tailorPhone, orderId, customerName, serviceType } = value;
    const result = await sendNewOrderNotificationSMS(tailorPhone, orderId, customerName, serviceType);

    if (result.success) {
      res.json({
        message: 'New order notification SMS sent successfully',
        sid: result.sid
      });
    } else {
      res.status(500).json({
        error: 'Failed to send new order notification SMS',
        details: result.error
      });
    }
  } catch (error) {
    console.error('Send new order notification SMS error:', error);
    res.status(500).json({
      error: 'Failed to send new order notification SMS',
      message: error.message
    });
  }
});

// Send payment reminder SMS
router.post('/payment-reminder', async (req, res) => {
  try {
    const { error, value } = sendPaymentReminderSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { customerPhone, orderId, amount } = value;
    const message = `
Payment Reminder
Order #${orderId}
Amount: $${amount.toFixed(2)}

Please complete your payment to continue with your order.

Thank you for choosing StitchHub!
    `;
    
    const result = await sendSMS(customerPhone, message);

    if (result.success) {
      res.json({
        message: 'Payment reminder SMS sent successfully',
        sid: result.sid
      });
    } else {
      res.status(500).json({
        error: 'Failed to send payment reminder SMS',
        details: result.error
      });
    }
  } catch (error) {
    console.error('Send payment reminder SMS error:', error);
    res.status(500).json({
      error: 'Failed to send payment reminder SMS',
      message: error.message
    });
  }
});

// Send pickup reminder SMS
router.post('/pickup-reminder', async (req, res) => {
  try {
    const { error, value } = sendPickupReminderSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { customerPhone, orderId, tailorName, tailorAddress } = value;
    const message = `
Pickup Reminder
Order #${orderId} is ready for pickup!

Tailor: ${tailorName}
Address: ${tailorAddress}

Please contact the tailor to arrange pickup.

Thank you for choosing StitchHub!
    `;
    
    const result = await sendSMS(customerPhone, message);

    if (result.success) {
      res.json({
        message: 'Pickup reminder SMS sent successfully',
        sid: result.sid
      });
    } else {
      res.status(500).json({
        error: 'Failed to send pickup reminder SMS',
        details: result.error
      });
    }
  } catch (error) {
    console.error('Send pickup reminder SMS error:', error);
    res.status(500).json({
      error: 'Failed to send pickup reminder SMS',
      message: error.message
    });
  }
});

// Send delivery confirmation SMS
router.post('/delivery-confirmation', async (req, res) => {
  try {
    const { error, value } = sendDeliveryConfirmationSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { customerPhone, orderId } = value;
    const message = `
Delivery Confirmed!
Order #${orderId} has been delivered successfully.

We hope you're satisfied with our service. Please rate your experience in the app.

Thank you for choosing StitchHub!
    `;
    
    const result = await sendSMS(customerPhone, message);

    if (result.success) {
      res.json({
        message: 'Delivery confirmation SMS sent successfully',
        sid: result.sid
      });
    } else {
      res.status(500).json({
        error: 'Failed to send delivery confirmation SMS',
        details: result.error
      });
    }
  } catch (error) {
    console.error('Send delivery confirmation SMS error:', error);
    res.status(500).json({
      error: 'Failed to send delivery confirmation SMS',
      message: error.message
    });
  }
});

// Send review request SMS
router.post('/review-request', async (req, res) => {
  try {
    const { error, value } = sendReviewRequestSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { customerPhone, orderId, tailorName } = value;
    const message = `
How was your experience?
Order #${orderId} with ${tailorName}

Please take a moment to rate and review your experience in the StitchHub app. Your feedback helps us improve our service.

Thank you for choosing StitchHub!
    `;
    
    const result = await sendSMS(customerPhone, message);

    if (result.success) {
      res.json({
        message: 'Review request SMS sent successfully',
        sid: result.sid
      });
    } else {
      res.status(500).json({
        error: 'Failed to send review request SMS',
        details: result.error
      });
    }
  } catch (error) {
    console.error('Send review request SMS error:', error);
    res.status(500).json({
      error: 'Failed to send review request SMS',
      message: error.message
    });
  }
});

module.exports = router;



