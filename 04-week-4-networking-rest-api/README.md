# Praktikum 2
# Uji tiga skenario error
1.Jalankan aplikasi dengan internet normal, amati loading lalu daftar 100 posts.<br>
jawab:<br>
![internet normal dan list 100 post](Screenshots/list-page-praktikum1dan2.png)<br><br>
2.Matikan internet (mode pesawat), tekan refresh, amati pesan ramah + tombol Coba lagi. Nyalakan kembali internet, tekan Coba lagi.<br>
jawab:<br>
![no internet](Screenshots/no-internet-praktikum1dan2.png)<br><br>
3.Sementara ubah baseUrl menjadi URL salah, amati pesan error koneksi. Kembalikan setelah uji.<br>
jawab: <br>
![kesalahan](Screenshots/kesalahan-jaringan-praktikum1dan2.png) <br><br>

# Praktikum 3
![hasil akhir saat scrooll](<Screenshots/praktikum 3- list dan scroll.png>)

# Hasil Ai challenge
Semua verifikasi sudah sukses dilakukan, hasil test juga lulus
![hasil test](Screenshots/ai_challenge_test.png) <br><br>
![hasil akhir](Screenshots/hasil_ai-challenge.png) <br><br>

# Hasil Refactoring
![hasil akhir](Screenshots/hasil_week4_refactoring.png) <br><br>
![hasil test dan analyze](Screenshots/week4_api-refactoring-test.png)<br><br>

# REFLEKSI
Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika aturan ini dilanggar?
jawab:<br>
Jika dilanggar:<br>
Testing sulit — test jadi butuh koneksi asli, bukan mock.<br>
Kode duplikat — logika network tersebar di banyak file UI.<br>
UI jadi berat karena ikut urus state jaringan, padahal harusnya cuma tampilkan data.<br>
<br><br>
Kapan pagination client-side cukup, dan kapan harus mengandalkan pagination server (_page/_limit)?<br>
jawab:<br>
Client-side: data kecil, jarang berubah, butuh filter/sort instan.<br>
Server-side: data besar, agar hemat memori, kuota, dan loading awal cepat.<br><br>
Bagaimana exception repository berubah menjadi AsyncError tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?<br>
jawab: <br>
Exception dari build() otomatis ditangkap Riverpod jadi AsyncError, ditangani via .when(). Tapi untuk aksi user (submit, refresh, load more) tetap perlu try/catch manual agar tidak crash dan bisa tampilkan error ke user.<br><br>

Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
jawab:<br>
Bug yang Diperbaiki<br>
Import ganda friendlyErrorMessage : hapus versi lama. karena dua fungsi friendlyErrorMessage bentrok (di providers.dart dan network_errors.dart)<br>
.valueOrNull : diganti .value.<br>
RangeError di ListView : kondisi jadi index >= length agar index lebih render loading/footer, bukan crash.<br>