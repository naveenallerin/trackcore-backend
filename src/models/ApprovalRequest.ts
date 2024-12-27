import { Model, DataTypes } from 'sequelize';
import sequelize from '../config/database';

export class ApprovalRequest extends Model {
  public id!: number;
  public requisitionId!: number;
  public status!: 'pending' | 'approved' | 'rejected';
  public approverUserId?: number;
  public comments?: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;
}

ApprovalRequest.init({
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  requisitionId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('pending', 'approved', 'rejected'),
    allowNull: false,
    defaultValue: 'pending'
  },
  approverUserId: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  comments: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  sequelize,
  tableName: 'approval_requests'
});
