import { Model, DataTypes } from 'sequelize';
import sequelize from '../config/database';

export class RequisitionField extends Model {
  public id!: number;
  public requisitionId!: number;
  public fieldName!: string;
  public fieldValue?: string;
}

RequisitionField.init({
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  requisitionId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  fieldName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  fieldValue: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  sequelize,
  tableName: 'requisition_fields'
});
