# Workspace API Integration

## Tổng quan

Đã tích hợp đầy đủ API workspace vào Flutter app với các chức năng:

### 1. API Endpoints đã tích hợp

#### Create Workspace
- **URL**: `/api/v1/organization/workspace/create`
- **Method**: `POST`
- **Content-Type**: `multipart/form-data`
- **Parameters**:
  - `Name`: Tên workspace
  - `Scope`: '0' (Riêng tư) hoặc '1' (Công khai)

#### Update Workspace  
- **URL**: `/api/v1/organization/workspace/update/{workspaceId}`
- **Method**: `PUT`
- **Content-Type**: `multipart/form-data`
- **Parameters**: Tương tự create

#### Get Workspaces (đã có sẵn)
- **URL**: `/api/v1/organization/workspace/getlistpaging`
- **Method**: `GET`

### 2. Components mới

#### CreateWorkspaceDialog
- **File**: `create_workspace_dialog.dart`
- **Chức năng**: Dialog tạo workspace mới
- **Features**:
  - Form validation
  - Loading state
  - Error handling
  - Success/error toast messages
  - Callback refresh workspace list

#### EditWorkspaceDialog  
- **File**: `edit_workspace_dialog.dart`
- **Chức năng**: Dialog chỉnh sửa workspace
- **Features**: Tương tự CreateWorkspaceDialog + pre-populate data

### 3. Cập nhật WorkspaceList

#### Tính năng mới
- Nút "+" để tạo workspace mới trong header
- Long press workspace item để chỉnh sửa
- Auto refresh list sau khi tạo/cập nhật

#### UI/UX
- Icon "+" trong header chính và trong modal "Xem tất cả"
- Long press feedback
- Consistent styling với app theme

### 4. WorkspaceRepository

#### Methods mới
```dart
// Tạo workspace
Future<Map<String, dynamic>> createWorkspace({
  required String organizationId,
  required String name,
  required String scope,
})

// Cập nhật workspace
Future<Map<String, dynamic>> updateWorkspace({
  required String organizationId,
  required String workspaceId,
  required String name,
  required String scope,
})
```

### 5. Validation & Error Handling

#### Form Validation
- Tên workspace không được để trống
- Real-time validation feedback

#### Error Handling
- Network errors
- API errors
- User-friendly error messages
- Loading states

### 6. Testing

#### Test Helper
- **File**: `workspace_repository_test.dart`
- **Chức năng**: Test các API calls
- **Usage**: `WorkspaceRepositoryTest.runAllTests()`

## Cách sử dụng

### 1. Tạo workspace mới
```dart
// Trong WorkspaceList
onPressed: _showCreateWorkspaceDialog
```

### 2. Chỉnh sửa workspace
```dart
// Long press trên workspace item
onLongPress: () => _showEditWorkspaceDialog(workspace)
```

### 3. Refresh workspace list
```dart
_fetchWorkspaces(); // Gọi sau khi tạo/cập nhật thành công
```

## Security & Best Practices

### Headers yêu cầu
- `organizationId`: Trong header cho mọi request
- `Authorization`: Bearer token (tự động từ ApiClient)
- `accept`: '*/*' cho form data requests

### Data Validation
- Client-side validation trước khi gọi API
- Server response validation
- Type-safe parameter passing

### Error Recovery
- Graceful error handling
- User feedback
- Retry mechanisms (có thể implement sau)

## Future Enhancements

### Có thể thêm
- Delete workspace API
- Workspace settings
- Member management
- Permission levels
- Workspace templates
- Batch operations

### Performance
- Caching workspace list
- Optimistic updates
- Pull-to-refresh
- Pagination for large lists 