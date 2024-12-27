import { Model, DataTypes } from 'sequelize';
import sequelize from '../config/database';

class Requisition extends Model {
  public id!: number;
  public title!: string;
  public department!: string;
  public description!: string;
  public createdAt!: Date;
  public updatedAt!: Date;

  static associate(models: any) {
    Requisition.belongsTo(models.User, {
      foreignKey: 'userId',
      as: 'user'
    });
    Requisition.hasOne(models.ApprovalRequest, {
      foreignKey: 'requisitionId',
      as: 'approval'
    });
    Requisition.hasMany(models.RequisitionField, {
      foreignKey: 'requisitionId',
      as: 'customFields'
    });
  }
}

Requisition.init(
  {
    id: {
      type: DataTypes.INTEGER.UNSIGNED,
      autoIncrement: true,
      primaryKey: true,
    },
    title: {
      type: new DataTypes.STRING(128),
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [3, 128]
      }
    },
    department: {
      type: new DataTypes.STRING(64),
      allowNull: false,
      validate: {
        notEmpty: true
      }
    },
    description: {
      type: new DataTypes.STRING(256),
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'requisitions',
  }
);

export default Requisition;
