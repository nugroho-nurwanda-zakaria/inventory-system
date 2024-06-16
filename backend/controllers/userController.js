// controllers/userController.js
const { User } = require('../models');

const register = async (req, res) => {
  try {
    // tangkap reques body
    const { username, password } = req.body;

    // debug
    // console.table({ username, password });

    // validasi user sudah ada
    const user = await User.findOne({ where: { username } });
    if (user) {
      return res.json({ message: 'Username already exists' });
    }

    // create user
    const createUserResponse = await User.create({ username, password });

    //  return response
    return res.status(201).json({
      message: 'User created successfully',
      data : createUserResponse
    });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

const login = async (req, res) => {
  try {
    // tangkap reques body
    const { username, password } = req.body;

    // debug
    // console.table({ username, password });

    // cek data user ditemukan atau tidak berdasarkan username
    const foundDataUser = await User.findOne({ where: { username } });
    if (!foundDataUser) {
      return res.json({ message: `${username} not found` });
    }

    // console.table(foundDataUser.password); 
    // password cek
    if (password !== foundDataUser.password) {
      return res.json({ message: 'Wrong password' });
    }

    // respone ketika data user dinyatakan valid
   return res.status(200).json({ 
    message: 'Login success',
    data : foundDataUser
   });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

module.exports = { register, login };
