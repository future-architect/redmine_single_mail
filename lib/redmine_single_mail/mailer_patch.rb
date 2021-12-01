module RadmineSingleMail
  module MailerPatch
    ## Builds a mail for notifying user about a new issue
    def issue_add(user, issue)
      msg = super(user, issue)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        to_users = issue.notified_users
        cc_users = issue.notified_watchers - issue.notified_users
        mail :to => to_users, :cc => cc_users, :subject => msg.subject
      else
        msg
      end
    end

    ## Builds a mail for notifying user about an issue update
    def issue_edit(user, journal)
      msg = super(user, journal)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        to_users = journal.notified_users
        to_users.select! do |user|
          journal.notes? || journal.visible_details(user).any?
        end
        cc_users = journal.notified_watchers - journal.notified_users
        cc_users.select! do |user|
          journal.notes? || journal.visible_details(user).any?
        end
        mail :to => to_users, :cc => cc_users, :subject => msg.subject
      else
        msg
      end
    end

    ## Builds a mail to user about a new document.
    def document_added(user, document, author)
      msg = super(user, document, author)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        users = document.notified_users
        mail :to => users, :subject => msg.subject
      else
        msg
      end
    end

    ## Builds a mail to user about new attachements.
    def attachments_added(user, attachments)
      msg = super(user, attachments)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        container = attachments.first.container
        case container.class.name
        when 'Project', 'Version'
          users = container.project.notified_users.select {|user| user.allowed_to?(:view_files, container.project)}
        when 'Document'
          users = container.notified_users
        end
        mail :to => users, :subject => msg.subject
      else
        msg
      end
    end

    ## Builds a mail to user about a new news.
    def news_added(user, news)
      msg = super(user, news)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        users = news.notified_users | news.notified_watchers_for_added_news
        mail :to => users, :subject => msg.subject
      else
        msg
      end
    end

    ## Builds a mail to user about a new news comment.
    def news_comment_added(user, comment)
      msg = super(user, comment)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        news = comment.commented
        users = news.notified_users | news.notified_watchers
        mail :to => users, :subject => msg.subject
      else
        msg
      end
    end

    ## Builds a mail to user about a new message.
    def message_posted(user, message)
      msg = super(user, message)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        users  = message.notified_users
        users |= message.root.notified_watchers
        users |= message.board.notified_watchers
        mail :to => users, :subject => msg.subject
      else
        msg
      end
    end

    ## Builds a mail to user about a new wiki content.
    def wiki_content_added(user, wiki_content)
      msg = super(user, wiki_content)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        users = wiki_content.notified_users | wiki_content.page.wiki.notified_watchers
        mail :to => users, :subject => msg.subject
      else
        msg
      end
    end

    ## Builds a mail to user about an update of the specified wiki content.
    def wiki_content_updated(user, wiki_content)
      msg = super(user, wiki_content)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        users  = wiki_content.notified_users
        users |= wiki_content.page.notified_watchers
        users |= wiki_content.page.wiki.notified_watchers
        mail :to => users, :subject => msg.subject
      else
        msg
      end
    end

    ## Builds a mail to user about an account activation request.
    def account_activation_request(user, new_user)
      msg = super(user, new_user)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        users = User.active.where(:admin => true)
        mail :to => users, :subject => msg.subject
      else
        msg
      end
    end
  end
end
Mailer.prepend(RadmineSingleMail::MailerPatch)

module RadmineSingleMail
  module MailerClassPatch
    ## Notifies users about a new issue.
    def deliver_issue_add(issue)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        issue_add(User.current, issue).deliver_later
      else
        super(issue)
      end
    end

    ## Notifies users about an issue update.
    def deliver_issue_edit(journal)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        issue_edit(User.current, journal).deliver_later
      else
        super(journal)
      end
    end

    ## Notifies users that document was created by author
    def deliver_document_added(document, author)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        document_added(User.current, document, author).deliver_later
      else
        super(document, author)
      end
    end

    ## Notifies users about new attachments
    def deliver_attachments_added(attachments)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        attachments_added(User.current, attachments).deliver_later
      else
        super(attachments)
      end
    end

    ## Notifies users about new news
    def deliver_news_added(news)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        news_added(User.current, news).deliver_later
      else
        super(news)
      end
    end

    ## Notifies users about a new comment on a news
    def deliver_news_comment_added(comment)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        news_comment_added(User.current, comment).deliver_later
      else
        super(comment)
      end
    end

    ## Notifies users about a new forum message.
    def deliver_message_posted(message)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        message_posted(User.current, message).deliver_later
      else
        super(message)
      end
    end

    ## Notifies users about a new wiki content (wiki page added).
    def deliver_wiki_content_added(wiki_content)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        wiki_content_added(User.current, wiki_content).deliver_later
      else
        super(wiki_content)
      end
    end

    ## Notifies users about the update of the specified wiki content
    def deliver_wiki_content_updated(wiki_content)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        wiki_content_updated(User.current, wiki_content).deliver_later
      else
        super(wiki_content)
      end
    end

    ## Notifies admin users that an account activation request needs
    def deliver_account_activation_request(new_user)
      if !!Setting.plugin_redmine_single_mail[:single_mail]
        account_activation_request(User.current, new_user).deliver_later
      else
        super(new_user)
      end
    end
  end
end
Mailer.singleton_class.prepend(RadmineSingleMail::MailerClassPatch)

