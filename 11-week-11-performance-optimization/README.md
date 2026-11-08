# Hasil Profile Before
## Performance
![perform](screenshots/before_perform.png)
## CPU
![cpu](screenshots/before_cpu.png)

# Hasil Profile After
## Performance
![perform](screenshots/after_optimasi.png)
## CPU
![cpu](screenshots/cpu_afteroptimasi.png)
## Heap Snapshot tidak ada memori leak
![no leak](screenshots/heap-snapshot.png)

# Hasil flutter test dan analyze
![test](screenshots/hasil_test.png)

# Refleksi
1. Optimasi mana yang memberikan dampak terbesar dan mengapa?<br>
cache stale-while-revalidate mengurangi request API yang berulang dan menampilkan data cache lebih cepat. Dibanding optimasi widget, dampaknya bisa lebih terasa saat jaringan lambat.<br>

2. Bagaimana Anda memverifikasi bahwa optimasi benar-benar bekerja (bukan placebo)?<br>
test memeriksa cache segar tidak memicu refresh dan refresh latar belakang tidak berulang; analisis dan build juga lolos. Belum ada profil sebelum/sesudah, jadi dampak pada waktu frame belum terbukti terukur.<br>

3. Trade-off apa yang Anda hadapi (misalnya kompleksitas kode vs performa)?<br>
cache menambah aturan umur data dan penanganan refresh; ekstraksi widget dan select menambah struktur, tetapi membatasi rebuild. ThemeData yang disimpan dan widget statis lebih sederhana.<br>
4. Kapan sebaiknya optimasi premature dihindari?<br>
Hindari premature optimization: jangan mengoptimasi berdasarkan dugaan. Ukur dahulu, cari bottleneck yang konsisten, lalu ubah bagian itu dan bandingkan hasilnya.