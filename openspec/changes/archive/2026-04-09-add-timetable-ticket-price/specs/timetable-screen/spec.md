## MODIFIED Requirements

### Requirement: 顯示班次列表
時刻表頁面 SHALL 顯示班次卡片列表，每張卡片包含車次名稱與編號、出發時間、抵達時間、行駛時間、票價。

#### Scenario: 顯示班次卡片
- **WHEN** API 回傳班次資料時
- **THEN** 頁面列出所有班次卡片，依出發時間遞增排序

#### Scenario: 班次卡片內容（含真實票價）
- **WHEN** 顯示某班次卡片時
- **THEN** 卡片顯示車次名稱（如「自強 3000」）＋編號（如「#171」）、出發時間、抵達時間、行駛時間（格式 Xh Xm）、票價（格式 NT$ XXX，金額為 TDX ODFare API 回傳的成人全票價格）

#### Scenario: 票價未取得時的降級顯示
- **WHEN** ODFare API 失敗或找不到對應列車種類票價時
- **THEN** 卡片票價欄位顯示 NT$ 0，其餘班次資訊正常顯示