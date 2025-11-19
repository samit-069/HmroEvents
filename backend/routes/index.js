const express = require('express');
const router = express.Router();

router.get('/health', (req, res) => res.json({ success: true, status: 'ok' }));

router.use('/auth', require('./auth'));
router.use('/users', require('./users'));
router.use('/events', require('./events'));
router.use('/upload', require('./upload'));
router.use('/admin', require('./admin'));

module.exports = router;
