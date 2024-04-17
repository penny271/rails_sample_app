# app/mailers/application_mailer.rb
# rails newで作成されるもともと存在するファイルです

class ApplicationMailer < ActionMailer::Base
  # アプリケーション全体で共通するデフォルトのfromアドレスがあります
  default from: "hirotaka.aoki27@gmail.com"
  layout "mailer"
end
