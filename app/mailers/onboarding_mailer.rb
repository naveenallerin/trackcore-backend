class OnboardingMailer < ApplicationMailer
  def task_reminder(task)
    @task = task
    @candidate = task.candidate
    @due_date = task.due_date.strftime('%B %d, %Y')

    mail(
      to: @candidate.email,
      subject: "Reminder: #{@task.title} due on #{@due_date}"
    )
  end

  def task_overdue_notification(task)
    @task = task
    @candidate = task.candidate
    @due_date = task.due_date.strftime('%B %d, %Y')

    mail(
      to: @candidate.email,
      subject: "Overdue: #{@task.title} was due on #{@due_date}"
    )
  end
end
