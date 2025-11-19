const jwt = require('jsonwebtoken');
const User = require('../models/User');

exports.optionalAuth = async (req, res, next) => {
  try {
    const header = req.headers.authorization || '';
    if (header.startsWith('Bearer ')) {
      const token = header.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'changeme');
      req.user = await User.findById(decoded.id);
    }
  } catch (e) {}
  next();
};
