const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('../models/User');
const Event = require('../models/Event');
const connectDB = require('../config/database');

dotenv.config();

const seedUsers = [
  { firstName: 'Admin', lastName: 'User', email: process.env.ADMIN_EMAIL || 'admin@admin.com', password: process.env.ADMIN_PASSWORD || 'Admin@123', role: 'admin', phone: '9800000000' },
  { firstName: 'John', lastName: 'Doe', email: 'john.doe@example.com', password: 'password123', role: 'user', phone: '9841234567' },
  { firstName: 'Jane', lastName: 'Smith', email: 'jane.smith@example.com', password: 'password123', role: 'organizer', phone: '9841234568' }
];

const seedEvents = [
  { title: 'PCPS Dashain Fest 2025', category: 'Music', dateTime: new Date('2025-11-15T18:00:00'), location: 'Kupondole, Lalitpur', attendees: 2500, price: 'From Rs. 100', imageUrl: '', iconEmoji: '🎵', organizer: 'HamroEvents', description: 'Celebrate Dashain with live music, cultural performances, and curated food stalls at PCPS.', isUserCreated: false },
  { title: 'Tech Innovation Conference', category: 'Conference', dateTime: new Date('2025-11-08T09:00:00'), location: 'Hotel Soaltee, Kathmandu', attendees: 850, price: 'From Rs. 80', imageUrl: '', organizer: 'Kathmandu Tech Council', description: 'A full-day conference featuring 20+ speakers on AI, cloud, fintech, and digital transformation.', isUserCreated: false },
  { title: 'College Basketball Championship', category: 'Sports', dateTime: new Date('2025-11-05T19:30:00'), location: 'PCPS College, Kupondole', attendees: 5000, price: 'From Rs. 250', imageUrl: '', iconEmoji: '🏀', organizer: 'Nepal Student Sports Association', description: 'Top college teams compete for the national title under the lights with live commentary.', isUserCreated: false },
  { title: 'International Food Festival', category: 'Food & Drink', dateTime: new Date('2025-11-14T11:00:00'), location: 'Bhrikutimandap, KTM', attendees: 3200, price: 'Free Entry', imageUrl: '', iconEmoji: '🍜', organizer: 'Global Chefs Collective', description: '40+ international chefs bring their signature dishes, live demos, and tasting sessions.', isUserCreated: false },
  { title: 'Modern Art Exhibition', category: 'Art & Culture', dateTime: new Date('2025-11-01T10:00:00'), location: 'Naxal, KTM', attendees: 450, price: 'From Rs. 75', imageUrl: '', iconEmoji: '🎨', organizer: 'Artists Hub Nepal', description: 'A curated collection of modern Nepali art with live painting corners and collector meetups.', isUserCreated: false }
];

const seedDatabase = async () => {
  try {
    await connectDB();
    console.log('Clearing existing data...');
    await User.deleteMany({});
    await Event.deleteMany({});

    console.log('Creating users...');
    const createdUsers = await User.insertMany(seedUsers);
    const adminUser = createdUsers.find(u => u.role === 'admin');
    const organizerUser = createdUsers.find(u => u.role === 'organizer');

    console.log('Creating events...');
    const eventsWithCreator = seedEvents.map((e, i) => ({ ...e, createdBy: i < 2 ? adminUser._id : organizerUser._id }));
    await Event.insertMany(eventsWithCreator);

    console.log('Database seeded successfully!');
    console.log(`Admin Email: ${process.env.ADMIN_EMAIL || 'admin@admin.com'}`);
    console.log(`Admin Password: ${process.env.ADMIN_PASSWORD || 'Admin@123'}`);
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
};

seedDatabase();
