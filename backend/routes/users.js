const express = require('express');
const { authorize, protect } = require('../middleware/auth');
const User = require('../models/User');

const router = express.Router();

router.get('/', protect, authorize('admin'), async (req, res) => {
  const users = await User.find();
  res.json({ success: true, count: users.length, data: { users } });
});

router.get('/organizers', async (req, res) => {
  const users = await User.find({ role: 'organizer' });
  res.json({ success: true, count: users.length, data: { users } });
});

router.get('/blocked', protect, authorize('admin'), async (req, res) => {
  const users = await User.find({ isBlocked: true });
  res.json({ success: true, count: users.length, data: { users } });
});

router.get('/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) return res.status(404).json({ success: false, message: 'User not found' });
  res.json({ success: true, data: { user } });
});

router.put('/:id', protect, async (req, res) => {
  if (req.user._id.toString() !== req.params.id && req.user.role !== 'admin') {
    return res.status(403).json({ success: false, message: 'Forbidden' });
  }
  const update = req.body;
  delete update.password;
  const user = await User.findByIdAndUpdate(req.params.id, update, { new: true });
  res.json({ success: true, message: 'User updated successfully', data: { user } });
});

router.put('/:id/block', protect, authorize('admin'), async (req, res) => {
  const user = await User.findByIdAndUpdate(req.params.id, { isBlocked: req.body.isBlocked === true }, { new: true });
  res.json({ success: true, message: 'User block status updated', data: { user } });
});

router.delete('/:id', protect, authorize('admin'), async (req, res) => {
  await User.findByIdAndDelete(req.params.id);
  res.json({ success: true, message: 'User deleted successfully' });
});

module.exports = router;
