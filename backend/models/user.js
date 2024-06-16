module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    username: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    image: {
      type: DataTypes.STRING,
      allowNull: true
    }
  }, {});
  
  User.associate = function(models) {
    User.hasMany(models.Product, { foreignKey: 'createdBy', as: 'CreatedProducts' });
    User.hasMany(models.Product, { foreignKey: 'updatedBy', as: 'UpdatedProducts' });
  };
  
  return User;
};
