const express = require('express');
const { body, validationResult } = require('express-validator');
const Event = require('../models/Event');
const User = require('../models/User');
const { protect, authorize } = require('../middleware/auth');
const { optionalAuth } = require('../middleware/optionalAuth');
const fetch = require('node-fetch');
const path = require('path');
const { GoogleAuth } = require('google-auth-library');

const router = express.Router();

const serviceAccountPath = path.join(__dirname, '..', 'service-account.json');
const googleAuth = new GoogleAuth({
  keyFile: serviceAccountPath,
  scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
});

async function getAccessToken() {
  const client = await googleAuth.getClient();
  const tokenResponse = await client.getAccessToken();
  return tokenResponse.token || tokenResponse;
}

router.get('/', optionalAuth, async (req, res) => {
  try {
    const { category, search, userId, bookmarked } = req.query;
    const userIdParam = req.user ? req.user._id : null;

    const query = {};
    if (category && category !== 'All Events') query.category = category;
    if (userId) query.createdBy = userId;
    if (search) {
      const rx = new RegExp(search, 'i');
      query.$or = [
        { title: rx },
        { description: rx },
        { location: rx },
        { organizer: rx },
      ];
    }

    let events = await Event.find(query).populate('createdBy', 'firstName lastName email').sort({ dateTime: 1 });

    if (userIdParam) {
      events = events.map(e => { const o = e.toObject(); o.isBookmarked = e.isBookmarkedBy(userIdParam); return o; });
    } else {
      events = events.map(e => { const o = e.toObject(); o.isBookmarked = false; return o; });
    }

    if (bookmarked === 'true' && userIdParam) {
      events = events.filter(e => e.isBookmarked);
    }

    res.json({ success: true, count: events.length, data: { events } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

async function sendFcmNotification(tokens, { title, body }) {
  if (!Array.isArray(tokens) || tokens.length === 0) return;

  const projectId = process.env.FCM_PROJECT_ID || 'event-us-af71c';
  const accessToken = await getAccessToken();

  for (const token of tokens) {
    try {
      const payload = {
        message: {
          token,
          notification: { title, body },
        },
      };

      await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify(payload),
      });
    } catch (err) {
      console.error('Failed to send FCM v1 message:', err.message || err);
    }
  }
}

router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id).populate('createdBy', 'firstName lastName email');
    if (!event) return res.status(404).json({ success: false, message: 'Event not found' });
    const o = event.toObject();
    o.isBookmarked = req.user ? event.isBookmarkedBy(req.user._id) : false;
    res.json({ success: true, data: { event: o } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

router.post('/', protect, authorize('organizer', 'admin'), [
  body('title').trim().notEmpty().isLength({ max: 200 }),
  body('category').isIn(['Music', 'Conference', 'Sports', 'Food & Drink', 'Art & Culture', 'Workshop']),
  body('dateTime').notEmpty().isISO8601(),
  body('location').trim().notEmpty(),
  body('attendees').optional().isInt({ min: 0 }),
  body('price').optional().trim(),
  body('description').optional().trim().isLength({ max: 2000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });

    // Only allow organizers with verified KYC to create events
    if (req.user && req.user.role === 'organizer' && req.user.kycStatus !== 'verified') {
      return res.status(403).json({ success: false, message: 'Your KYC is not verified yet. You cannot create events.' });
    }

    const { title, category, dateTime, location, attendees = 0, price = 'Free Entry', imageUrl = '', iconEmoji = '', organizer = '', description = 'Details coming soon. Stay tuned!' } = req.body;

    const organizerName = organizer || req.user.name || 'Independent Organizer';

    const event = await Event.create({ title, category, dateTime: new Date(dateTime), location, attendees: parseInt(attendees), price, imageUrl, iconEmoji, organizer: organizerName, description, createdBy: req.user._id, isUserCreated: true });
    const populated = await Event.findById(event._id).populate('createdBy', 'firstName lastName email');

    // Send push notification to all users who have a deviceToken
    try {
      const usersWithToken = await User.find({ deviceToken: { $ne: '' } }).select('deviceToken');
      const tokens = usersWithToken.map(u => u.deviceToken).filter(Boolean);
      if (tokens.length > 0) {
        await sendFcmNotification(tokens, {
          title: 'New Event: ' + title,
          body: `${organizerName} published a new ${category} event`,
        });
      }
    } catch (notifyErr) {
      console.error('Failed to send push notifications for new event:', notifyErr.message || notifyErr);
    }

    res.status(201).json({ success: true, message: 'Event created successfully', data: { event: populated } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

router.put('/:id', protect, authorize('organizer', 'admin'), [
  body('title').optional().trim().isLength({ max: 200 }),
  body('category').optional().isIn(['Music', 'Conference', 'Sports', 'Food & Drink', 'Art & Culture', 'Workshop']),
  body('dateTime').optional().isISO8601(),
  body('description').optional().trim().isLength({ max: 2000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });

    let event = await Event.findById(req.params.id);
    if (!event) return res.status(404).json({ success: false, message: 'Event not found' });

    if (req.user.role !== 'admin' && event.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized to update this event' });
    }

    const update = {};
    ['title','category','dateTime','location','attendees','price','imageUrl','iconEmoji','organizer','description'].forEach(k=>{
      if (req.body[k] !== undefined) update[k] = k === 'dateTime' ? new Date(req.body[k]) : req.body[k];
    });

    event = await Event.findByIdAndUpdate(req.params.id, update, { new: true, runValidators: true }).populate('createdBy', 'firstName lastName email');
    res.json({ success: true, message: 'Event updated successfully', data: { event } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// NOTE: This delete route is intentionally left without auth for the in-app admin dashboard bypass.
// In production, you should re-add proper protect/authorize middleware.
router.delete('/:id', async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) return res.status(404).json({ success: false, message: 'Event not found' });

    await event.deleteOne();
    res.json({ success: true, message: 'Event deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

router.post('/:id/bookmark', protect, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) return res.status(404).json({ success: false, message: 'Event not found' });
    const userId = req.user._id;
    const isBookmarked = event.isBookmarkedBy(userId);
    if (isBookmarked) {
      event.bookmarkedBy = event.bookmarkedBy.filter(id => id.toString() !== userId.toString());
    } else {
      event.bookmarkedBy.push(userId);
    }
    await event.save();
    const populated = await Event.findById(event._id).populate('createdBy', 'firstName lastName email');
    const o = populated.toObject();
    o.isBookmarked = !isBookmarked;
    res.json({ success: true, message: `Event ${!isBookmarked ? 'bookmarked' : 'unbookmarked'} successfully`, data: { event: o } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

router.get('/user/:userId', async (req, res) => {
  try {
    const events = await Event.find({ createdBy: req.params.userId }).populate('createdBy', 'firstName lastName email').sort({ dateTime: 1 });
    res.json({ success: true, count: events.length, data: { events } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

module.exports = router;
