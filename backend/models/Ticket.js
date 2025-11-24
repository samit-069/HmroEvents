const mongoose = require('mongoose');

const ticketSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  event: { type: mongoose.Schema.Types.ObjectId, ref: 'Event', required: true },
  amount: { type: Number, required: true },
  transactionId: { type: String, default: '' },
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

// Prevent same user from booking the same event multiple times
ticketSchema.index({ user: 1, event: 1 }, { unique: true });

module.exports = mongoose.model('Ticket', ticketSchema);
