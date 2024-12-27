import { ApprovalService } from '../../services/ApprovalService';
import { ApprovalRequest } from '../../models/ApprovalRequest';

jest.mock('../../models/ApprovalRequest');

describe('ApprovalService', () => {
  let service: ApprovalService;

  beforeEach(() => {
    service = new ApprovalService();
    jest.clearAllMocks();
  });

  describe('requestApproval', () => {
    it('should create a new approval request', async () => {
      const mockApproval = { id: 1, requisitionId: 1, status: 'pending' };
      (ApprovalRequest.create as jest.Mock).mockResolvedValue(mockApproval);

      const result = await service.requestApproval(1);
      expect(result).toEqual(mockApproval);
      expect(ApprovalRequest.create).toHaveBeenCalledWith({
        requisitionId: 1,
        status: 'pending'
      });
    });
  });

  describe('getApprovalStatus', () => {
    it('should return approval status', async () => {
      const mockApproval = { id: 1, requisitionId: 1, status: 'pending' };
      (ApprovalRequest.findOne as jest.Mock).mockResolvedValue(mockApproval);

      const result = await service.getApprovalStatus(1);
      expect(result).toEqual(mockApproval);
    });
  });

  describe('updateApprovalStatus', () => {
    it('should update approval status', async () => {
      const updateData = {
        status: 'approved',
        approverUserId: 1,
        comments: 'Approved'
      };
      (ApprovalRequest.update as jest.Mock).mockResolvedValue([1]);

      await service.updateApprovalStatus(1, 'approved', 1, 'Approved');
      expect(ApprovalRequest.update).toHaveBeenCalledWith(
        updateData,
        { where: { requisitionId: 1 } }
      );
    });
  });
});
