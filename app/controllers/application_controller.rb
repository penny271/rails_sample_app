class ApplicationController < ActionController::Base
  # sessions_helper.rbを読み込む = sessionメソッドを使えるようにする
  include SessionsHelper
  # protect_from_forgery with: :exception
  # before_action :authenticate_user!
  # before_action :set_locale

  # def set_locale
  #   I18n.locale = current_user.try(:locale) || I18n.default_locale
  # end

  def hello
    render html: "hello, world!"
  end
end
