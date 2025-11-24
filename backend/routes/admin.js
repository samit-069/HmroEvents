const express = require('express');
const User = require('../models/User');
const Event = require('../models/Event');

const router = express.Router();

// Public metrics endpoint so the mobile admin bypass can read counts without JWT
router.get('/metrics', async (req, res) => {
  try {
    const [totalUsers, blockedUsers, organizers, totalEvents] = await Promise.all([
      User.countDocuments({}),
      User.countDocuments({ isBlocked: true }),
      User.countDocuments({ role: 'organizer' }),
      Event.countDocuments({}),
    ]);

    res.json({
      success: true,
      data: { totalUsers, blockedUsers, organizers, totalEvents },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// Set KYC status (verify/reject) for a user
router.post('/users/:id/kyc-status', async (req, res) => {
  try {
    const { status } = req.body || {};
    if (!['pending', 'verified', 'rejected'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid KYC status' });
    }
    const update = { kycStatus: status };
    if (status === 'pending') {
      update.kycSubmittedAt = new Date();
    }
    const user = await User.findByIdAndUpdate(req.params.id, update, { new: true, runValidators: true });
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, message: 'KYC status updated', data: { user } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

module.exports = router;
// Public users listing for admin bypass UI
router.get('/users', async (req, res) => {
  try {
    const users = await User.find({}, '-password').sort({ createdAt: -1 });
    res.json({ success: true, data: { users } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

router.get('/users/organizers', async (req, res) => {
  try {
    const users = await User.find({ role: 'organizer' }, '-password').sort({ createdAt: -1 });
    res.json({ success: true, data: { users } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

router.get('/users/blocked', async (req, res) => {
  try {
    const users = await User.find({ isBlocked: true }, '-password').sort({ createdAt: -1 });
    res.json({ success: true, data: { users } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// Toggle block/unblock
router.post('/users/:id/block-toggle', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    user.isBlocked = !user.isBlocked;
    await user.save();
    res.json({ success: true, message: user.isBlocked ? 'User blocked' : 'User unblocked', data: { user } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// Edit user basic fields
router.put('/users/:id', async (req, res) => {
  try {
    const {
      firstName,
      lastName,
      name,
      email,
      phone,
      location,
      avatar,
      isBlocked,
      kycStatus,
      // Organizer KYC detail fields
      kycDob,
      kycCitizenshipNumber,
      kycProvince,
      kycDistrict,
      kycMunicipality,
      kycWard,
      kycStreet,
    } = req.body || {};
    const update = {};
    if (firstName !== undefined) update.firstName = firstName;
    if (lastName !== undefined) update.lastName = lastName;
    if (name !== undefined) {
      // If a full name is provided, split into first/last as best effort
      const parts = String(name).trim().split(/\s+/);
      if (parts.length > 1) {
        update.firstName = parts.slice(0, -1).join(' ');
        update.lastName = parts.slice(-1).join(' ');
      } else if (parts.length === 1) {
        update.firstName = parts[0];
      }
    }
    if (email !== undefined) update.email = email;
    if (phone !== undefined) update.phone = phone;
    if (location !== undefined) update.location = location;
    if (avatar !== undefined) update.avatar = avatar;
    if (isBlocked !== undefined) update.isBlocked = !!isBlocked;
    if (kycStatus !== undefined) update.kycStatus = kycStatus;
    // Organizer KYC detail fields
    if (kycDob !== undefined) update.kycDob = kycDob;
    if (kycCitizenshipNumber !== undefined) update.kycCitizenshipNumber = kycCitizenshipNumber;
    if (kycProvince !== undefined) update.kycProvince = kycProvince;
    if (kycDistrict !== undefined) update.kycDistrict = kycDistrict;
    if (kycMunicipality !== undefined) update.kycMunicipality = kycMunicipality;
    if (kycWard !== undefined) update.kycWard = kycWard;
    if (kycStreet !== undefined) update.kycStreet = kycStreet;

    const user = await User.findByIdAndUpdate(req.params.id, update, { new: true, runValidators: true });
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, message: 'User updated', data: { user } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// Delete user
router.delete('/users/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    await user.deleteOne();
    res.json({ success: true, message: 'User deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});
