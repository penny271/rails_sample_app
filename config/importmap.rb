# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# * Importmapを使ってプロジェクトのカスタムJavaScriptコードがapp/javascript/customにあることをRailsに認識させる設定を行います
pin_all_from "app/javascript/custom",      under: "custom"