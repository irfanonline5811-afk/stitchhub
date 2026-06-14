const twilio = require('twilio');

let client = null;

if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN) {
  try {
    client = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );
    console.log('✅ Twilio initialized');
  } catch (error) {
    console.error('❌ Failed to initialize Twilio:', error.message);
  }
} else {
  console.log('⚠️ Twilio credentials missing. SMS service will be disabled.');
}

const sendSMS = async (to, message) => {
  try {
    if (!client) {
      console.warn('Cannot send SMS: Twilio client not initialized');
      return { success: false, error: 'Twilio not initialized' };
    }
    const result = await client.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: to
    });
    
    console.log(`SMS sent successfully: ${result.sid}`);
    return { success: true, sid: result.sid };
  } catch (error) {
    console.error('Error sending SMS:', error);
    return { success: false, error: error.message };
  }
};

const sendOrderConfirmationSMS = async (customerPhone, orderId, tailorName) => {
  const message = `
Hello! Your order #${orderId} has been confirmed by ${tailorName}.
We'll keep you updated on the progress.

Thank you for choosing StitchHub!
  `;
  
  return await sendSMS(customerPhone, message);
};

const sendOrderStatusUpdateSMS = async (customerPhone, orderId, status) => {
  let statusMessage = '';
  switch (status.toLowerCase()) {
    case 'confirmed':
      statusMessage = 'Your order has been confirmed and work has started.';
      break;
    case 'inprogress':
      statusMessage = 'Your order is currently being worked on.';
      break;
    case 'readyforpickup':
      statusMessage = 'Your order is ready for pickup!';
      break;
    case 'completed':
      statusMessage = 'Your order has been completed successfully.';
      break;
    default:
      statusMessage = 'Your order status has been updated.';
  }

  const message = `
Order #${orderId} Update:
${statusMessage}

Thank you for choosing StitchHub!
  `;
  
  return await sendSMS(customerPhone, message);
};

const sendNewOrderNotificationSMS = async (tailorPhone, orderId, customerName, serviceType) => {
  const message = `
New Order Alert!
Order #${orderId} from ${customerName}
Service: ${serviceType}

Please check your StitchHub app for details.

Thank you for using StitchHub!
  `;
  
  return await sendSMS(tailorPhone, message);
};

module.exports = {
  sendSMS,
  sendOrderConfirmationSMS,
  sendOrderStatusUpdateSMS,
  sendNewOrderNotificationSMS
};



