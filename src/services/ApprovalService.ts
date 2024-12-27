import { EventEmitter } from 'events';
import { ApprovalRequest } from '../models/ApprovalRequest';

export const approvalEvents = new EventEmitter();

export class ApprovalService {
  async requestApproval(requisitionId: number) {
    const approval = await ApprovalRequest.create({
      requisitionId,
      status: 'pending'
    });

    approvalEvents.emit('approval_requested', {
      requisitionId,
      approvalId: approval.id,
      timestamp: new Date()
    });

    return approval;
  }

  async getApprovalStatus(requisitionId: number) {
    return await ApprovalRequest.findOne({
      where: { requisitionId }
    });
  }

  async updateApprovalStatus(requisitionId: number, status: 'approved' | 'rejected', approverUserId: number, comments?: string) {
    return await ApprovalRequest.update(
      { status, approverUserId, comments },
      { where: { requisitionId } }
    );
  }
}
