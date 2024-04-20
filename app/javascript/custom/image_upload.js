// ユーザーがアップロードしようとする画像が巨大過ぎる場合に警告を表示してみましょう。これにより意図しない長時間アップロードを防止し、サーバーの負荷も軽減できます。

// 巨大画像のアップロードを防止する
document.addEventListener("turbo:load", function () {
  document.addEventListener("change", function (event) {
    let image_upload = document.querySelector("#micropost_image");
    if (image_upload && image_upload.files.length > 0) {
      const size_in_megabytes = image_upload.files[0].size / 1024 / 1024;
      if (size_in_megabytes > 5) {
        alert("Maximum file size is 5MB. Please choose a smaller file.");
        image_upload.value = "";
      }
    }
  });
});
// このコードは、画像ファイルが選択されたときにファイルサイズをチェックし、5MBを超える場合に警告を表示します。画像ファイルのサイズは、ファイルのサイズをバイト単位で取得し、1024で割ってKBに変換し、さらに1024で割ってMBに変換しています。画像ファイルのサイズが5MBを超える場合は、警告を表示してファイルをクリアします。
