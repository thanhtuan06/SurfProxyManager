# Surf Proxy Manager

Biến tài khoản Surfshark thành một dàn proxy SOCKS5/HTTP chạy trên chính máy Windows của bạn, mỗi proxy đi ra một vị trí/IP VPN riêng, để gắn vào từng profile GPM Login. Mọi thao tác làm trên Web UI tại `http://127.0.0.1:8686`.

## Cách hoạt động

Mỗi tunnel là một tiến trình [wireproxy](https://github.com/windtf/wireproxy) (WireGuard chạy hoàn toàn ở userspace). Nó không tạo card mạng ảo, không đổi route của Windows, không cần quyền Admin, nên mạng thật của máy không bị ảnh hưởng và chạy hàng chục tunnel vẫn nhẹ (mỗi tunnel khoảng 10–20 MB RAM).

```
GPM profile A ──► 127.0.0.1:20001 ─► wireproxy ─► Surfshark US  ─► Internet
GPM profile B ──► 127.0.0.1:20002 ─► wireproxy ─► Surfshark DE  ─► Internet
GPM profile C ──► 127.0.0.1:20003 ─► wireproxy ─► Surfshark JP  ─► Internet
                         ▲
                  Surf Proxy Manager: bật/tắt, kiểm tra IP, tự phục hồi, xoay IP
```

Ứng dụng chỉ dùng thư viện chuẩn của Python, không cần `pip install`.

## Cài đặt (một lần)

1. Cài Python 3.9 trở lên từ python.org (tick "Add python.exe to PATH"). Nếu không muốn cài Python trên máy chạy, xem mục "Đóng gói thành .exe".
2. Giải nén thư mục này vào nơi cố định, ví dụ `D:\SurfProxyManager`.
3. Nhấp đúp `start_hidden.vbs`. Trình duyệt sẽ mở Web UI.
4. Trên Web UI bấm **Tải wireproxy** (tự tải bản chính thức từ GitHub vào thư mục `bin\`). Nếu máy không ra được GitHub, tải tay file `wireproxy_windows_amd64.tar.gz` ở trang Releases rồi giải nén `wireproxy.exe` vào `bin\`.

## Lấy file WireGuard từ Surfshark

1. Đăng nhập trang quản lý Surfshark → VPN → Cài đặt thủ công (Manual setup) → Máy tính/Router → WireGuard.
2. Tạo cặp khóa (Generate key pair). Đặt tên dễ nhớ.
3. Chọn vị trí → tải file `.conf`. Lặp lại cho mỗi vị trí bạn muốn.

**Quan trọng về cặp khóa:** một cặp khóa dùng được cho nhiều vị trí khác nhau cùng lúc. Nhưng nếu hai tunnel cùng khóa kết nối vào *cùng một server*, chúng sẽ đá nhau rớt mạng liên tục. Ứng dụng tự tránh trường hợp này khi chọn server, và sẽ cảnh báo nếu không tránh được. Nếu bạn cần nhiều proxy ở cùng một thành phố, hãy tạo mỗi proxy một cặp khóa riêng rồi tải file `.conf` bằng cặp khóa đó.

## Sử dụng với NordVPN (Mới)

Ứng dụng hỗ trợ kết nối trực tiếp với tài khoản NordVPN qua công nghệ NordLynx (WireGuard) tự động hoàn toàn:

1. Đăng nhập [Nord Account](https://my.nordaccount.com/dashboard/nordvpn/manual-configuration/) ➔ **VPN** ➔ **Cài đặt thủ công (Manual setup)** ➔ bấm **Get access token (Lấy access token)**.
2. Sao chép chuỗi Access Token được cấp.
3. Trên Web UI của Surf Proxy Manager, bấm **Thêm NordVPN**:
   - Dán Access Token vào ô nhập.
   - Chọn Quốc gia mong muốn (Việt Nam, Mỹ, Nhật Bản, Singapore, v.v.).
   - Chọn số lượng Proxy muốn tạo (ví dụ 1, 3, 5...).
   - Bấm **Tạo Proxy NordVPN**. Hệ thống sẽ tự động lấy khóa, tìm máy chủ tối ưu và mở proxy ngay lập tức!
   *(Nếu bạn đã có sẵn file `.conf` NordLynx tải từ trước, bạn vẫn có thể nạp trực tiếp qua nút "Nạp file .conf").*

## Tạo proxy

- **Nhanh:** bấm **Nạp file .conf**, kéo thả nhiều file vào. Với ô "Tạo luôn mỗi file thành 1 tunnel" được tick, mỗi file thành một tunnel với 1 cổng SOCKS5 (từ 20001) và 1 cổng HTTP (từ 30001), bật ngay.
- **Tùy chỉnh:** bấm **Tạo tunnel** để đặt tên, cổng, tài khoản/mật khẩu proxy, lịch đổi IP, và chọn nhiều file để tunnel luân phiên giữa các vị trí.

Sau khoảng 5–10 giây, cột "IP ra ngoài" hiện IP Surfshark và mã quốc gia. Bấm vào số cổng để sao chép chuỗi proxy.

## Gắn vào GPM Login

1. Chọn các tunnel → **Xuất cho GPM Login** → chọn giao thức SOCKS5 và định dạng → **Sao chép**.
2. Trong GPM Login, khi tạo/sửa profile (hoặc nhập proxy hàng loạt), dán chuỗi và chọn loại proxy SOCKS5.

Nên dùng SOCKS5: tên miền được phân giải qua DNS của Surfshark bên trong tunnel, không rò DNS ra nhà mạng. Nếu GPM Login báo sai định dạng, đổi sang định dạng khác trong hộp thoại xuất (`host:port:user:pass` là kiểu phổ biến nhất).

Mỗi profile nên gắn một cổng riêng. Hai profile dùng chung một cổng sẽ có chung IP.

## Xoay IP (Rotating IP)

Tính năng Rotating IP trong app Surfshark không áp dụng cho kết nối WireGuard thủ công, nên ứng dụng giả lập bằng hai cách, dùng riêng hoặc kết hợp:

- **Đổi server trong cùng vị trí:** mỗi tên máy chủ Surfshark (ví dụ `us-nyc.prod.surfshark.com`) trỏ tới nhiều server. Khi bật "chọn ngẫu nhiên 1 server khác", mỗi lần kết nối lại ứng dụng chọn một server khác, nên IP đổi mà quốc gia giữ nguyên. Nếu một vị trí chỉ có một server thì IP sẽ không đổi.
- **Luân phiên vị trí:** chọn nhiều file `.conf` cho một tunnel; mỗi lần đổi IP sẽ chuyển sang file kế tiếp.

Đổi IP ngay bằng nút ⟳ trên từng hàng, hàng loạt bằng nút **Đổi IP**, hoặc đặt "Tự đổi IP sau (phút)". Lưu ý mỗi lần đổi IP, kết nối đang mở qua proxy đó bị ngắt khoảng 1–3 giây; đừng đặt tự đổi IP cho profile đang cần giữ phiên đăng nhập ổn định.

## Tự phục hồi

- Cứ mỗi 30 giây (chỉnh trong Cài đặt), ứng dụng đi qua từng proxy tới `cloudflare.com/cdn-cgi/trace` để lấy IP, quốc gia và độ trễ.
- Lỗi 3 lần liên tiếp → tự khởi động lại tunnel (thử server khác nếu đang bật chọn ngẫu nhiên).
- wireproxy bị thoát → tự chạy lại, chờ tăng dần 5–60 giây để không spam.
- Máy ngủ dậy / mất mạng / đổi Wi-Fi → các tunnel tự kết nối lại khi mạng có lại.
- Tắt máy rồi bật lại → các tunnel đang bật sẽ tự chạy lại khi ứng dụng khởi động.

## Chạy ngầm và tự khởi động

| File | Tác dụng |
|---|---|
| `start_hidden.vbs` | Chạy ngầm, không cửa sổ, mở Web UI |
| `open_web_ui.bat` | Mở lại Web UI khi ứng dụng đang chạy ngầm |
| `install_autostart.bat` | Tự chạy ngầm mỗi lần đăng nhập Windows (không cần Admin) |
| `remove_autostart.bat` | Gỡ tự khởi động |
| `start_console.bat` | Chạy có cửa sổ để xem log trực tiếp khi gỡ lỗi |
| `build_exe.bat` | Đóng gói thành `SurfProxyManager.exe` |

Tắt hẳn ứng dụng: Web UI → Cài đặt → **Thoát ứng dụng** (dừng mọi proxy).

## Đóng gói thành .exe

Chạy `build_exe.bat` trên một máy có Python. File `SurfProxyManager.exe` tạo ra để cùng thư mục với `bin\` (chứa `wireproxy.exe`); `start_hidden.vbs` sẽ tự ưu tiên chạy file exe nếu có.

## Dùng proxy từ máy khác trong mạng LAN

Sửa tunnel → "Lắng nghe trên: Cả mạng LAN". Bắt buộc đặt tài khoản/mật khẩu proxy. Windows Firewall sẽ hỏi cho phép `wireproxy.exe` lần đầu, chọn mạng Private. Trong hộp thoại xuất, đổi "Địa chỉ host" thành IP LAN của máy này (xem trong Cài đặt).

Web UI cũng có thể mở ra LAN (Cài đặt → Web UI lắng nghe trên: Cả mạng LAN), khi đó bắt buộc đặt mật khẩu Web UI và khởi động lại ứng dụng.

## Giới hạn cần biết

- **Chỉ TCP.** wireproxy không chuyển UDP qua SOCKS5. Duyệt web, API, đăng nhập đều là TCP nên không ảnh hưởng; WebRTC do GPM Login tự giả lập.
- **Chỉ WireGuard, không OpenVPN.** Trên Windows, mỗi kết nối OpenVPN cần một card mạng TAP/Wintun riêng, quyền Admin, và phải can thiệp bảng route để từng proxy đi đúng tunnel; chạy nhiều kết nối cùng lúc dễ xung đột và làm hỏng mạng thật của máy. WireGuard userspace tránh được toàn bộ chuyện này, nhanh hơn và nhẹ hơn, nên ứng dụng chỉ hỗ trợ WireGuard.
- **IP là IP datacenter của VPN,** không phải IP dân cư. Nhiều người dùng chung IP Surfshark, nên một số nền tảng có thể đánh giá điểm tin cậy thấp hơn IP dân cư.
- **Điều khoản:** tài khoản Surfshark dành cho sử dụng cá nhân. Không bán lại hay chia sẻ proxy công khai ra Internet. Việc chạy nhiều tài khoản trên các nền tảng (Facebook, Google, TikTok, sàn TMĐT...) cũng phải tuân theo điều khoản của từng nền tảng.

## Cấu trúc thư mục

```
SurfProxyManager\
  app.py              lõi quản lý + API + máy chủ Web UI
  web\index.html      giao diện
  bin\wireproxy.exe   tải về qua Web UI
  data\configs\       các file .conf đã nạp (chứa khóa riêng — đừng chia sẻ)
  data\runtime\       cấu hình sinh ra cho từng tunnel
  data\logs\          nhật ký từng tunnel
  data\state.json     danh sách tunnel và cài đặt
  data\app.log        nhật ký ứng dụng
```

Sao lưu cả thư mục `data\` là đủ để chuyển sang máy khác.

## Gỡ lỗi nhanh

- **"Cổng ... đang bị chương trình khác chiếm":** đổi cổng tunnel, hoặc tắt chương trình đang dùng cổng đó (`netstat -ano | findstr :20001`).
- **Kẹt ở "Đang kết nối"/"Kiểm tra lỗi: timed out":** mở Nhật ký của tunnel. Thấy lặp lại "Handshake did not complete" nghĩa là không bắt tay được với server: cặp khóa đã bị xóa/hết hạn trên trang Surfshark, hoặc mạng đang chặn UDP cổng 51820. Tạo lại cặp khóa và tải lại file `.conf`.
- **Tunnel cùng khóa rớt luân phiên:** xem cảnh báo "dùng chung 1 cặp khóa", tạo thêm cặp khóa cho các tunnel cùng vị trí.
