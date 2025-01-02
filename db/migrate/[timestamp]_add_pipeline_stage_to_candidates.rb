class AddPipelineStageToCandidates < ActiveRecord::Migration[7.0]
  def up
    add_column :candidates, :pipeline_stage, :string, default: 'new'
  end

  def down
    remove_column :candidates, :pipeline_stage
  end
end

{
  "candidates": [
    {
      "id": 123,
      "name": "John Doe",
      "email": "john@example.com",
      "pipeline": {
        "current_stage": "Interviewing",
        "stage_updated_at": "2024-01-15T10:30:00Z",
        "days_in_stage": 5,
        "can_advance": true
      },
      "knockout": {
        "status": "passed",
        "failed_rules": [],
        "last_checked_at": "2024-01-10T15:00:00Z",
        "requires_review": false
      },
      "licenses": {
        "total": 3,
        "active": 2,
        "expired": 1,
        "expiring_soon": 1,
        "critical_missing": false,
        "details": [
          {
            "type": "Nursing License",
            "status": "active",
            "expires_at": "2024-12-31",
            "verified": true
          }
        ]
      },
      "tasks": {
        "total": 5,
        "pending": 2,
        "overdue": 1,
        "next_due": "2024-01-20T00:00:00Z",
        "items": [
          {
            "id": 456,
            "title": "Complete background check",
            "due_at": "2024-01-20T00:00:00Z",
            "assigned_to": "Jane Smith",
            "priority": "high"
          }
        ]
      },
      "interviews": {
        "next_interview": "2024-01-18T14:00:00Z",
        "total_scheduled": 2,
        "past_interviews": 1,
        "latest_feedback": "Strong technical skills, good culture fit"
      },
      "alerts": [
        {
          "level": "warning",
          "message": "In current stage for 5 days",
          "category": "pipeline"
        }
      ]
    }
  ],
  "total_count": 1,
  "updated_at": "2024-01-15T12:00:00Z"
}
