const express = require('express');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const path = require('path');

const router = express.Router();

// Configure multer for memory storage
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    // Check file type
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  }
});

// Upload profile image
router.post('/profile-image/:userId', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'No image file provided'
      });
    }

    const { userId } = req.params;
    const file = req.file;
    /*
    const fileName = `profile_images/${userId}.jpg`;
    
    // Create a reference to the file
    const fileRef = storage.bucket().file(fileName);
    ...
    stream.end(file.buffer);
    */
    res.status(501).json({ error: 'File upload not implemented without Firebase' });
  } catch (error) {
    console.error('Upload profile image error:', error);
    res.status(500).json({
      error: 'Upload failed',
      message: error.message
    });
  }
});

// Upload work sample
router.post('/work-sample/:tailorId', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'No image file provided'
      });
    }

    const { tailorId } = req.params;
    const file = req.file;
    const fileName = `work_samples/${tailorId}/${uuidv4()}.jpg`;
    
    // Create a reference to the file
    const fileRef = storage.bucket().file(fileName);
    
    // Create a write stream
    const stream = fileRef.createWriteStream({
      metadata: {
        contentType: file.mimetype,
      },
    });

    // Handle stream events
    stream.on('error', (error) => {
      console.error('Upload error:', error);
      res.status(500).json({
        error: 'Upload failed',
        message: error.message
      });
    });

    stream.on('finish', async () => {
      try {
        // Make the file public
        await fileRef.makePublic();
        
        // Get the public URL
        const publicUrl = `https://storage.googleapis.com/${storage.bucket().name}/${fileName}`;
        
        res.json({
          message: 'Work sample uploaded successfully',
          imageUrl: publicUrl
        });
      } catch (error) {
        console.error('Error making file public:', error);
        res.status(500).json({
          error: 'Failed to make file public',
          message: error.message
        });
      }
    });

    // Write the file
    stream.end(file.buffer);
  } catch (error) {
    console.error('Upload work sample error:', error);
    res.status(500).json({
      error: 'Upload failed',
      message: error.message
    });
  }
});

// Upload order images
router.post('/order-images/:orderId', upload.array('images', 5), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        error: 'No image files provided'
      });
    }

    const { orderId } = req.params;
    const files = req.files;
    const imageUrls = [];

    // Process each file
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const fileName = `order_images/${orderId}/${uuidv4()}.jpg`;
      
      // Create a reference to the file
      const fileRef = storage.bucket().file(fileName);
      
      // Create a write stream
      const stream = fileRef.createWriteStream({
        metadata: {
          contentType: file.mimetype,
        },
      });

      // Handle stream events
      await new Promise((resolve, reject) => {
        stream.on('error', (error) => {
          console.error('Upload error:', error);
          reject(error);
        });

        stream.on('finish', async () => {
          try {
            // Make the file public
            await fileRef.makePublic();
            
            // Get the public URL
            const publicUrl = `https://storage.googleapis.com/${storage.bucket().name}/${fileName}`;
            imageUrls.push(publicUrl);
            resolve();
          } catch (error) {
            console.error('Error making file public:', error);
            reject(error);
          }
        });

        // Write the file
        stream.end(file.buffer);
      });
    }

    res.json({
      message: 'Order images uploaded successfully',
      imageUrls
    });
  } catch (error) {
    console.error('Upload order images error:', error);
    res.status(500).json({
      error: 'Upload failed',
      message: error.message
    });
  }
});

// Delete image
router.delete('/image', async (req, res) => {
  try {
    const { imageUrl } = req.body;

    if (!imageUrl) {
      return res.status(400).json({
        error: 'Image URL is required'
      });
    }

    // Extract file path from URL
    const url = new URL(imageUrl);
    const filePath = url.pathname.substring(1); // Remove leading slash
    
    // Create a reference to the file
    const fileRef = storage.bucket().file(filePath);
    
    // Check if file exists
    const [exists] = await fileRef.exists();
    if (!exists) {
      return res.status(404).json({
        error: 'Image not found'
      });
    }

    // Delete the file
    await fileRef.delete();

    res.json({
      message: 'Image deleted successfully'
    });
  } catch (error) {
    console.error('Delete image error:', error);
    res.status(500).json({
      error: 'Failed to delete image',
      message: error.message
    });
  }
});

// Error handling middleware for multer
router.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        error: 'File too large',
        message: 'File size must be less than 10MB'
      });
    }
  }
  
  if (error.message === 'Only image files are allowed') {
    return res.status(400).json({
      error: 'Invalid file type',
      message: 'Only image files are allowed'
    });
  }

  next(error);
});

module.exports = router;



