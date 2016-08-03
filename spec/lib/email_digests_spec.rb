require 'rails_helper'

describe EmailDigest do

  describe "notifications" do

    it "returns notifications for a user" do
      user1 = create(:user)
      user2 = create(:user)

      proposal_notification = create(:proposal_notification)
      notification1 = create(:notification, notifiable: proposal_notification, user: user1)
      notification2 = create(:notification, notifiable: proposal_notification, user: user2)

      email_digest = EmailDigest.new(user1)

      expect(email_digest.notifications).to include(notification1)
      expect(email_digest.notifications).to_not include(notification2)
    end

    it "returns only proposal notifications" do
      user = create(:user)

      proposal_notification = create(:proposal_notification)
      comment = create(:comment)

      notification1 = create(:notification, notifiable: proposal_notification, user: user)
      notification2 = create(:notification, notifiable: comment,               user: user)

      email_digest = EmailDigest.new(user)

      expect(email_digest.notifications).to include(notification1)
      expect(email_digest.notifications).to_not include(notification2)
    end

  end

  describe "pending_notifications?" do

    it "returns true when notifications have not been emailed" do
      user = create(:user)

      proposal_notification = create(:proposal_notification)
      notification = create(:notification, notifiable: proposal_notification, user: user)

      email_digest = EmailDigest.new(user)
      expect(email_digest.pending_notifications?).to be
    end

    it "returns false when notifications have been emailed" do
      user = create(:user)

      proposal_notification = create(:proposal_notification)
      notification = create(:notification, notifiable: proposal_notification, user: user, emailed_at: Time.now)

      email_digest = EmailDigest.new(user)
      expect(email_digest.pending_notifications?).to_not be
    end

    it "returns false when there are no notifications for a user" do
      user = create(:user)
      email_digest = EmailDigest.new(user)
      expect(email_digest.pending_notifications?).to_not be
    end

  end

  describe "deliver" do

    it "delivers email if notifications pending" do
      user = create(:user)

      proposal_notification = create(:proposal_notification)
      notification = create(:notification, notifiable: proposal_notification, user: user)

      email_digest = EmailDigest.new(user)
      email_digest.deliver

      email = open_last_email
      expect(email).to have_subject("Proposal notifications in Consul")
    end

    it "does not deliver email if no notifications pending" do
      user = create(:user)

      proposal_notification = create(:proposal_notification)
      notification = create(:notification, notifiable: proposal_notification, user: user, emailed_at: Time.now)

      email_digest = EmailDigest.new(user)
      email_digest.deliver

      expect(all_emails.count).to eq(0)
    end

  end

end