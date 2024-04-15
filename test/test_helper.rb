ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # 指定のワーカー数でテストを並列実行する
  parallelize(workers: :number_of_processors)
  # test/fixtures/*.ymlのfixtureをすべてセットアップする
  fixtures :all

  # テストユーザーがログイン中の場合にtrueを返す
  def is_logged_in?
    !session[:user_id].nil?
  end

  # テストユーザーとしてログインする
  def log_in_as(user)
    session[:user_id] = user.id
  end

  # * test環境でもApplicationヘルパーを使えるようにする
  include ApplicationHelper

  # Add more helper methods to be used by all tests here...
end

# 今回は統合テストで扱うヘルパーなのでActionDispatch::IntegrationTestクラスの中で定義します。
# これにより、私たち開発者は単体テストか統合テストかを意識せずに、ログイン済みの状態をテストしたいときはlog_in_asメソッドをただ呼び出せば良い、ということになります
class ActionDispatch::IntegrationTest

  # テストユーザーとしてログインする
  # キーワード引数を使用
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end