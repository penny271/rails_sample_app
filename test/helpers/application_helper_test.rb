require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal 'Ruby on Rails Tutorial Sample App', full_title
    assert_equal 'Help | Ruby on Rails Tutorial Sample App', full_title("Help")
  end
end

# * Applicationヘルパーで使っているfull_titleヘルパーを、test環境でも使えるようにすると便利です。こうしておくと、リスト 5.35のようなコードを使って、正しいタイトルをテストすることができます。ただし、これは完璧なテストではありません。例えばベースタイトルに「Ruby on Rails Tutoial」といった誤字があったとしても、このテストでは発見することができないでしょう。この問題を解決するためには、full_titleヘルパーに対するテストを書く必要があります。

# * そこで、Applicationヘルパーをテストするファイルを作成し、リスト 5.36の（コードを書き込む）の部分を適切なコードに置き換えてみてください。（ヒント: リスト 5.36ではassert_equal <期待される値>, <実際の値>といった形で使っていましたが、内部では==演算子で期待される値と実際の値を比較し、正しいかどうかのテストをしています。）