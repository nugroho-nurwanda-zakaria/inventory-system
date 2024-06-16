const express = require('express');
const router = express.Router();

// DEFINE CONTROLLER (IMPORT CONTRONLLER)
const { register, login } = require('./controllers/userController');
const { getAllCategories, creteateNewCategory, detailCategoryById , updateCategoryById, deleteCategoryById} = require('./controllers/categoryController');
const { getAllProducts, getProductById, createProduct, updateProduct, deleteProduct } = require('./controllers/productController');

// const upload = require('./middlewares/upload');


// FORMAT DEFINE ROUTER
// router.[http-req]([url-endpoint], [method])
// ex : router.post('/register', register);

// ROUTE UNTUK AUTHENTICATION
router.post('/register', register);
router.post('/login', login);

// ROUTE UNTUK HANDLE DATA  CATEGORY
router.get('/categories', getAllCategories);
router.post('/categories', creteateNewCategory);
router.get('/categories/:id', detailCategoryById);
router.patch('/categories/:id', updateCategoryById);
router.delete('/categories/:id', deleteCategoryById);


// ROUTE UNTUK HANDLE DATA PRODUCT
router.get('/products', getAllProducts);
router.get('/products/:id', getProductById);
router.post('/products', createProduct);
router.patch('/products/:id', updateProduct);
router.delete('/products/:id', deleteProduct);


// router.post('/upload', upload.single('image'), (req, res) => {
//   res.status(201).json({ imageUrl: `/uploads/${req.file.filename}` });
// });

module.exports = router;
