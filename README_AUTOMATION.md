# Module Automation - Cửa Sổ Quảng Cáo (COKA)

## 🎯 Tổng Quan

Module Automation đã được tích hợp cơ bản vào ứng dụng COKA để hỗ trợ:

- **Thu hồi khách hàng (Recall/Eviction Rules)**: Tự động thu hồi khách hàng sau một khoảng thời gian không có phản hồi
- **Nhắc hẹn chăm sóc (Reminder Config)**: Nhắc nhở cập nhật trạng thái sau khi tiếp nhận khách hàng

## 🚀 Trạng Thái Hiện Tại

### ✅ Đã Hoàn Thành
- [x] Tạo màn hình Automation cơ bản (`AutomationPage`)
- [x] Thêm routing cho `/organization/:orgId/campaigns/automation`
- [x] Cập nhật navigation từ `CampaignsPage`
- [x] Tạo models cơ bản (`ReminderConfig`, `EvictionRule`)
- [x] UI/UX cho danh sách automation configs
- [x] Dialog tạo automation mới
- [x] Chức năng bật/tắt automation
- [x] Mock data để demonstration
- [x] **Professional Card Styling**: Active/Inactive states với màu xanh/xám
- [x] **Responsive Grid Layout**: 1-3 columns tùy theo screen size
- [x] **Interactive Components**: Custom switches, badges, hover effects
- [x] **Skeleton Loading**: Animated loading states
- [x] **Statistics Display**: Icons và counters
- [x] **Smooth Animations**: Hover, scale, fade transitions

### ⏳ Cần Phát Triển Thêm
- [ ] Tích hợp API thực tế
- [ ] Implement AutomationService với Dio
- [ ] Thêm Riverpod providers
- [ ] Tạo repository layer
- [ ] Authentication handling
- [ ] Error handling toàn diện
- [ ] Validation cho forms
- [ ] Pagination cho danh sách
- [ ] Màn hình chi tiết automation
- [ ] Màn hình chỉnh sửa automation
- [ ] Logs và analytics

## 📁 Cấu Trúc File Đã Tạo

```
lib/
├── pages/organization/campaigns/automation/
│   └── automation_page.dart              # Màn hình chính
├── models/automation/
│   ├── reminder_config.dart              # Model nhắc hẹn
│   └── eviction_rule.dart               # Model thu hồi
├── widgets/automation/
│   ├── new_automation_card.dart          # Card component chính
│   ├── automation_card_base.dart         # Base card với hover effects
│   ├── automation_badge.dart             # Badge components
│   ├── automation_switch.dart            # Custom switch
│   ├── statistics_item.dart              # Statistics components
│   └── automation_card_skeleton.dart     # Loading skeleton
├── constants/
│   └── automation_colors.dart            # Color palette
├── styles/
│   └── automation_text_styles.dart       # Typography styles
└── router.dart                          # Cập nhật routing
```

## 🔧 Cách Sử Dụng

### 1. Truy Cập Module
```dart
// Từ CampaignsPage, click vào "Automation" trong grid
// Hoặc navigate trực tiếp:
context.push('/organization/$orgId/campaigns/automation');
```

### 2. Tạo Automation Mới
1. Click nút "+" trên AppBar
2. Chọn loại automation:
   - **Thu hồi khách hàng**: Tự động thu hồi sau thời gian định
   - **Nhắc hẹn chăm sóc**: Nhắc nhở update trạng thái
3. Điền thông tin và click "Tạo"

### 3. Quản Lý Automation
- **Bật/Tắt**: Sử dụng Switch trong mỗi card
- **Chỉnh sửa**: Click menu ⋮ → "Chỉnh sửa"
- **Xóa**: Click menu ⋮ → "Xóa"

## 🔌 Tích Hợp API (TODO)

### Endpoints Cần Implement

```dart
// Reminder Config APIs
GET    /api/ReminderConfig/organization/{orgId}
POST   /api/ReminderConfig
PUT    /api/ReminderConfig/{configId}
DELETE /api/ReminderConfig/{configId}
PATCH  /api/ReminderConfig/{configId}/toggle

// Eviction Rule APIs  
GET    /api/v1/automation/eviction/rule/getlistpaging
POST   /api/v1/automation/eviction/rule/create
PATCH  /api/v1/automation/eviction/rule/{ruleId}/update
DELETE /api/v1/automation/eviction/rule/{ruleId}/delete
PATCH  /api/v1/automation/eviction/rule/{ruleId}/updatestatus
```

### Dependencies Cần Thêm

```yaml
dependencies:
  flutter_riverpod: ^2.4.7
  dio: ^5.3.2
  # Đã có sẵn trong pubspec.yaml
```

## 🎨 UI/UX Features

### Màn Hình Chính
- **Empty State**: Hiển thị khi chưa có automation
- **Loading State**: CircularProgressIndicator khi đang tải
- **Error Handling**: Hiển thị lỗi và retry button
- **Pull to Refresh**: Kéo để refresh danh sách

### Automation Cards
- **Type Indicators**: Icon và màu khác nhau cho từng loại
- **Status Toggle**: Switch để bật/tắt
- **Actions Menu**: Chỉnh sửa và xóa
- **Date Display**: Hiển thị ngày tạo

### Dialogs
- **Add Automation**: Chọn loại automation
- **Create Forms**: Form tạo recall/reminder với validation
- **Confirmation**: Xác nhận xóa

## 🚨 Lưu Ý Quan Trọng

### 1. API Configuration
```dart
// Cần cập nhật base URL trong ApiClient
static const String _baseUrl = 'https://api.coka.ai';
static const String _calendarUrl = 'https://calendar.coka.ai';
```

### 2. Authentication
```dart
// Cần thêm Bearer token cho tất cả requests
options.headers['Authorization'] = 'Bearer $token';
options.headers['organizationId'] = orgId;
```

### 3. Error Handling
```dart
// Implement proper error handling
try {
  final response = await apiClient.dio.get('/endpoint');
} on DioException catch (e) {
  // Handle different error types
}
```

## 📝 Ví Dụ Sử dụng

### Navigation
```dart
// Từ campaigns page
context.push('/organization/$organizationId/campaigns/automation');
```

### Mock Data Structure
```dart
final mockConfig = {
  'id': '1',
  'type': 'reminder', // hoặc 'eviction'
  'title': 'Nhắc hẹn sau 30 phút',
  'description': 'Nhắc nhở cập nhật trạng thái...',
  'isActive': true,
  'createdAt': DateTime.now(),
};
```

## 🔄 Next Steps

1. **Tích hợp API Service**: Implement AutomationService với real APIs
2. **State Management**: Thêm Riverpod providers cho state management
3. **Advanced Features**: Chi tiết automation, edit screens, logs
4. **Testing**: Unit tests và integration tests
5. **Performance**: Pagination, caching, optimization

## 🤝 Đóng Góp

Để tiếp tục phát triển module này:

1. Review hướng dẫn chi tiết trong documentation
2. Implement các API services theo specs
3. Thêm error handling và validation
4. Tạo unit tests
5. Update UI/UX theo feedback

---

**Phiên bản**: 1.0.0 (Basic Integration)  
**Cập nhật**: $(date +"%d/%m/%Y")  
**Tác giả**: Development Team 