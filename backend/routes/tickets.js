const express = require('express');
const Ticket = require('../models/Ticket');
const Event = require('../models/Event');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Get all tickets for current user
router.get('/', protect, async (req, res) => {
  try {
    const tickets = await Ticket.find({ user: req.user._id })
      .populate('event', 'title date location coverImage price');
    res.json({ success: true, data: { tickets } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// Check if current user already has a ticket for an event
router.get('/has/:eventId', protect, async (req, res) => {
  try {
    const { eventId } = req.params;
    const existing = await Ticket.findOne({ user: req.user._id, event: eventId });
    res.json({ success: true, data: { hasTicket: !!existing } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// Create a ticket for current user
router.post('/', protect, async (req, res) => {
  try {
    const { eventId, amount, transactionId } = req.body;
    if (!eventId || amount === undefined) {
      return res.status(400).json({ success: false, message: 'eventId and amount are required' });
    }

    const ev = await Event.findById(eventId);
    if (!ev) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    // Check existing ticket
    const existing = await Ticket.findOne({ user: req.user._id, event: eventId });
    if (existing) {
      return res.status(400).json({ success: false, message: 'You have already booked a ticket for this event' });
    }

    const ticket = await Ticket.create({
      user: req.user._id,
      event: eventId,
      amount,
      transactionId: transactionId || '',
    });

    res.status(201).json({ success: true, message: 'Ticket booked successfully', data: { ticket } });
  } catch (error) {
    if (error.code === 11000) {
      // Unique index violation
      return res.status(400).json({ success: false, message: 'You have already booked a ticket for this event' });
    }
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

module.exports = router;
