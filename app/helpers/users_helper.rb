module UsersHelper
  # * ヘルパーファイルで定義されているメソッドは、デフォルトで自動的にすべてのビューで利用できます。
  # 引数で与えられたユーザーのGravatar画像を返す
  # def gravatar_for(user, options = { size: 80 })
  def gravatar_for(user, size: 80) # * キーワード引数
    # size         = options[:size]
    gravatar_id  = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end