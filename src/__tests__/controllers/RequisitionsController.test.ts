import { RequisitionsController } from '../../controllers/RequisitionsController';
import { Request, Response } from 'express';

describe('RequisitionsController', () => {
  let controller: RequisitionsController;
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;

  beforeEach(() => {
    controller = new RequisitionsController();
    mockRes = {
      json: jest.fn(),
      status: jest.fn().mockReturnThis()
    };
  });

  describe('requestApproval', () => {
    it('should request approval for requisition', async () => {
      mockReq = {
        params: { id: '1' }
      };

      await controller.requestApproval(mockReq as Request, mockRes as Response);
      expect(mockRes.json).toHaveBeenCalled();
    });
  });

  describe('checkApprovalStatus', () => {
    it('should return approval status', async () => {
      mockReq = {
        params: { id: '1' }
      };

      await controller.checkApprovalStatus(mockReq as Request, mockRes as Response);
      expect(mockRes.json).toHaveBeenCalled();
    });
  });

  describe('approvalComplete', () => {
    it('should update approval status', async () => {
      mockReq = {
        params: { id: '1' },
        body: {
          status: 'approved',
          approverUserId: 1,
          comments: 'Approved'
        }
      };

      await controller.approvalComplete(mockReq as Request, mockRes as Response);
      expect(mockRes.json).toHaveBeenCalledWith({ success: true });
    });
  });
});
