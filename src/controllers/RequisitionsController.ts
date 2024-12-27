import { Request, Response } from 'express';
import { RequisitionService } from '../services/RequisitionService';
import { ApprovalService } from '../services/ApprovalService';

export class RequisitionsController {
  private requisitionService: RequisitionService;
  private approvalService: ApprovalService;

  constructor() {
    this.requisitionService = new RequisitionService();
    this.approvalService = new ApprovalService();
  }

  async createRequisition(req: Request, res: Response) {
    try {
      const requisition = await this.requisitionService.createRequisition(req.body);
      return res.json(requisition);
    } catch (error) {
      return res.status(400).json({ error: error.message });
    }
  }

  async getRequisition(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const requisition = await this.requisitionService.getRequisition(parseInt(id));
      return res.json(requisition);
    } catch (error) {
      return res.status(400).json({ error: error.message });
    }
  }

  async updateRequisition(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const requisition = await this.requisitionService.updateRequisition(parseInt(id), req.body);
      return res.json(requisition);
    } catch (error) {
      return res.status(400).json({ error: error.message });
    }
  }

  async deleteRequisition(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await this.requisitionService.deleteRequisition(parseInt(id));
      return res.json({ success: true });
    } catch (error) {
      return res.status(400).json({ error: error.message });
    }
  }

  async requestApproval(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const approval = await this.approvalService.requestApproval(parseInt(id));
      return res.json(approval);
    } catch (error) {
      return res.status(400).json({ error: error.message });
    }
  }

  async checkApprovalStatus(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const status = await this.approvalService.getApprovalStatus(parseInt(id));
      return res.json(status);
    } catch (error) {
      return res.status(400).json({ error: error.message });
    }
  }

  async approvalComplete(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { status, approverUserId, comments } = req.body;
      await this.approvalService.updateApprovalStatus(parseInt(id), status, approverUserId, comments);
      return res.json({ success: true });
    } catch (error) {
      return res.status(400).json({ error: error.message });
    }
  }
}
