require 'redmine'

require_dependency 'redmine_single_mail/mailer_patch'

Redmine::Plugin.register :redmine_single_mail do
  name 'Redmine Single Mail plugin'
  author 'Future Corporation'
  description 'This is a plugin for Redmine single mail'
  version '0.1.0'
  url 'https://www.future.co.jp'
  author_url 'https://www.future.co.jp'
  settings :default => {'single_mail' => true}, :partial => 'settings/single_mail_settings'
end
