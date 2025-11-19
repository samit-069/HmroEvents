const jwt = require('jsonwebtoken');

module.exports = function generateToken(id) {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'changeme', {
    expiresIn: process.env.JWT_EXPIRE || '7d'
  });
};
