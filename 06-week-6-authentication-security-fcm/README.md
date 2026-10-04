# Hasil praktikum
![hasil](screenshots/fcm-console-test.png)

![gagal login](screenshots/login-gagal.png)
# Ai Challenge jawaban
Apakah background handler berupa fungsi top-level dengan @pragma('vm:entry-point')? (tolak jika berupa method kelas).<br>
jawab: sudah bagus
Apakah onTokenRefresh benar-benar mengirim token baru ke backend, bukan hanya dicetak ke log?<br>
jawab: sudah bagus juga
Apakah foreground memakai local notification manual? (tanpa ini banner tidak muncul saat aplikasi terbuka).<br>
jawab: sudah benar, ada banner nya
Apakah klik dari ketiga state (foreground/background/terminated) masuk ke rute yang benar? Buktikan dengan tabel pengujian.
jawab: saat saya klik banner nya, hanya menuju ke beranda untuk login
Apakah token/secret tidak di-hardcode dan tidak di-log penuh? Perbaiki bila AI melanggarnya.<br>
jawab: sudah bagus, ia tidak melanggarnya.
Keputusan final dan alasan teknis Anda, boleh berbeda dari saran AI selama berargumen.<br>
jawab: saya putuskan untuk memakai kode awal saja.

## hasil ai challenge
![notif ai](screenshots/aichalleng-notif.png)<br>

# hasil refactoring
![test](screenshots/refactor-test.png)<br>
![alt text](<screenshots/notif refactor.png>)<br>

# refleksi
Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?<br>

Apa yang rusak bila onTokenRefresh diabaikan selama satu semester perkuliahan?<br>

Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing.<br>

Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?<br>