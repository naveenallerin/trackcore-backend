class OnboardingTaskReminderJob < ApplicationJob
  queue_as :default

  def perform
    check_due_soon_tasks
    check_overdue_tasks
  end

  private

  def check_due_soon_tasks
    OnboardingTask.due_soon.find_each do |task|
      OnboardingMailer.task_reminder(task).deliver_now
    end
  end

  def check_overdue_tasks
    OnboardingTask.pending.where('due_date < ?', Date.current).find_each do |task|
      task.mark_as_overdue!
      OnboardingMailer.task_overdue_notification(task).deliver_now
    end
  end
end
