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

  private
    # ユーザーのログインを確認する（どのコントローラーでも共通して使えるようにする）
    # * Usersコントローラ内にこのメソッドがあったので、beforeフィルターで指定していましたが、このメソッドはMicropostsコントローラでも必要です。そこで、各コントローラが継承するApplicationコントローラにこのメソッドを移し、beforeフィルターで呼び出すようにします。
    def logged_in_user
      # puts("before_action :logged_in_user, only: [:edit, :update]でログイン済みユーザーかどうか確認する")
      unless logged_in?
        # フレンドリーフォワーディングのURL(当初飛びたかったpageのurl)を保存する
        store_location # app/helpers/sessions_helper.rb
        flash[:danger] = "Please log in."
        redirect_to login_url, status: :see_other # :see_otherステータスは、他の場所にリダイレクトすることを示すHTTPステータスコード（303）を表します。
      end
    end
end
