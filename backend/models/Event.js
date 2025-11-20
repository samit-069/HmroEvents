const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  title: { type: String, required: true, trim: true },
  category: { type: String, required: true, enum: ['Music', 'Conference', 'Sports', 'Food & Drink', 'Art & Culture', 'Workshop'] },
  dateTime: { type: Date, required: true },
  location: { type: String, required: true },
  attendees: { type: Number, default: 0 },
  price: { type: String, default: 'Free Entry' },
  imageUrl: { type: String, default: '' },
  iconEmoji: { type: String, default: '' },
  organizer: { type: String, default: '' },
  description: { type: String, default: 'Details coming soon. Stay tuned!' },
  isUserCreated: { type: Boolean, default: false },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  bookmarkedBy: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }]
}, { timestamps: true });

// Text index for search
try {
  eventSchema.index({ title: 'text', description: 'text', location: 'text', organizer: 'text' });
} catch (e) {}

// Helper to check bookmark
eventSchema.methods.isBookmarkedBy = function(userId) {
  return this.bookmarkedBy.some(id => id.toString() === userId.toString());
};

module.exports = mongoose.model('Event', eventSchema);
