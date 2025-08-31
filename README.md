## 指定題目說明
- [x] Swift Concurrency / Combine 使用場景
 - 存取 API 時採用 Swift Concurrency，取代傳統 closure 做法。
 - 回來的結果用 Combine 發佈。matches 與 odds 都有後才要組合成最終的結果，用 combineLatest 聽到兩個結果後才進行合成。
 - 合成後通知 ViewController 更新畫面。
- [x] 如何確保資料取存取 thread-safe？
 - 非 Actor 時，採用 DispatchQueue 的 .barrier flag 設定。
- [x] UI 與 ViewModel 資料綁定方式
 - cell 中兩個賠率用 Combine 的語法 @Published 來 assign 到指定 label 上。
 - 如不使用 Combine，則是掛 Observer 的方式來更新 label。

## 專案說明
- 使用方式：
  1) App 開啟後，去的是 ConfigViewController。
  2) 設定的兩個值是模擬 Socket 每秒要推送的數量。產的資料量隨機從最小至最大之間產出。如果想要看到大量快速跳動，可以設定高一點。Match 資料筆數為 120 筆。直接按少，會設成 4 ~ 10，按多就是 90 ~ 100。然後按 Go 就會推至列表頁。
  3) 進到主畫面，請將畫面上下滑動檢查數據與效果。上方顯示的 FPS 是基本 DisplayLink 那個方法做的。
- 架構為 MVVMC。
  1) 資料的獲取與基本礎理再分至 Repository。所用的 API 服務可以外部注入。
  2) ViewModel 也要注入所用的 repository。
  3) 由 Coordinator 總管 ViewController、ViewModel 與 Repository 的關係。
- 更新 cell 的方法：
  1) 一切都用舊原始手段的做法位於 commit 00d1f2b。資料放在 OddsInfo 這個 Singleton 裡。裡面包含快取了哪個 cell index 是放哪個 match 的資料。更新時就可以直接抓到該 cell 並更新賠率。
  2) 自定義 observer 的做法位於 commit 465a3ea。賠率變成觀察者在聽新的資料進來。prepareForReuse() 需要手動加入清除程序，讓滑出畫面外的 cell 不再聽資料。
  3) 最後的 commit 是改用 Combine 的語法做。監聽的一切都交給系統處理。