// ...existing code...
router.post('/:id/request-approval', controller.requestApproval.bind(controller));
router.get('/:id/approval-status', controller.checkApprovalStatus.bind(controller));
router.post('/:id/approval-complete', controller.approvalComplete.bind(controller));
// ...existing code...