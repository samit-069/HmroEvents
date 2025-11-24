const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  firstName: { type: String, required: true, trim: true, minlength: 2 },
  lastName: { type: String, required: true, trim: true, minlength: 2 },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  phone: { type: String, trim: true, default: '' },
  password: { type: String, required: true, minlength: 6, select: false },
  role: { type: String, enum: ['user', 'organizer', 'admin'], default: 'user' },
  isBlocked: { type: Boolean, default: false },
  location: { type: String, default: '' },
  avatar: { type: String, default: '' },
  deviceToken: { type: String, default: '' },
  // KYC status for organizers: none, pending, verified, rejected
  kycStatus: { type: String, enum: ['none', 'pending', 'verified', 'rejected'], default: 'none' },
  kycSubmittedAt: { type: Date },
  // Organizer KYC details (only used when role === 'organizer')
  kycDob: { type: String, default: '' },
  kycCitizenshipNumber: { type: String, default: '' },
  kycProvince: { type: String, default: '' },
  kycDistrict: { type: String, default: '' },
  kycMunicipality: { type: String, default: '' },
  kycWard: { type: String, default: '' },
  kycStreet: { type: String, default: '' },
  createdAt: { type: Date, default: Date.now }
}, { timestamps: true });

userSchema.virtual('name').get(function() {
  return `${this.firstName} ${this.lastName}`;
});

userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

userSchema.methods.toJSON = function() {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};

module.exports = mongoose.model('User', userSchema);
