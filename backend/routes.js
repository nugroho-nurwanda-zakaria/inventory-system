const express = require('express');
const cors = require('cors');
const { register, login } = require('./controllers/userController');
const { getAllCategories } = require('./controllers/categoryController');
const { getAllProducts, getProductById, createProduct, updateProduct, deleteProduct } = require('./controllers/productController');
const upload = require('./middlewares/upload');

const router = express.Router();
router.use(cors());
router.use(express.json());
router.use('/uploads', express.static('uploads'));

router.post('/register', register);
router.post('/login', login);
router.get('/categories', getAllCategories);
router.get('/products', getAllProducts);
router.get('/products/:id', getProductById);
router.post('/products', createProduct);
router.put('/products/:id', updateProduct);
router.delete('/products/:id', deleteProduct);
router.post('/upload', upload.single('image'), (req, res) => {
  res.status(201).json({ imageUrl: `/uploads/${req.file.filename}` });
});

module.exports = router;
