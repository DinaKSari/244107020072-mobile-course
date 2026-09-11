# Refleksi
Kapan setState masih cukup, dan kapan state harus naik ke Riverpod? <br>
Jawab: <br>
setState: Cukup digunakan untuk state lokal yang hanya memengaruhi satu widget. <br>
Riverpod: Dibutuhkan ketika state harus diakses atau dibagikan ke banyak widget di halaman berbeda, atau ketika state harus bertahan meskipun navigasi berpindah halaman. <br>
Apa perbedaan context.go dan context.push, dan kapan masing-masing tepat digunakan? <br>
jawab: <br>
context.go: Melakukan navigasi absolut dengan mengganti history tumpukan rute saat ini.<br>
context.push: Menambahkan rute baru ke atas tumpukan tanpa menghapus rute sebelumnya, sehingga tombol back otomatis muncul. <br>

Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?<br>
Jawab: <br>
AsyncValue menggabungkan status loading, error, dan data ke dalam satu objek tertutup (sealed class). Ini mencegah bug logika di mana pengembang lupa mengubah salah satu status (misalnya, isLoading bernilai false tapi error terisi data basi), sehingga UI dijamin sinkron dengan kondisi asinkron yang sedang terjadi. <br>

Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?<br>
jawab: <br>
Sudah oke. <br>

## Praktikum 3
1. mengapa menampilkan ulang data lama (stale data) dengan indikator refresh kadang lebih baik daripada mengosongkan layar? Kapan pola itu penting? <br>
jawab: <br>
Agar aplikasinya nggak keliatan nge-bug saat lagi loading data baru. Jika layar tiba-tiba putih atau kosong, user bakal mikir aplikasinya error. Jadi, data lama tetep dipajang biar user masih bisa lihat, sambil nunggu data barunya selesai ditarik dari server. <br>
Pola itu penting pas aplikasi lagi ambil data dari internet yang butuh waktu, jadi user nggak capek menunggu layar kosong. <br>

# AI CHALLENGE
Apakah state diubah secara immutable (tidak ada state.add() atau mutasi list langsung)? <br>
jawab: <br>
Kode tidak pernah menggunakan state.add() atau mengubah isi List secara langsung. Nilai dikembalikan (return) sebagai data/List baru secara langsung dari method build() milik AsyncNotifier. Riverpod secara internal menangani pembuatan objek AsyncValue.data baru tanpa memutasi state lama <br>
Apakah ref.watch hanya dipakai di dalam build, dan ref.read di callback? <br>
jawab: <br>
Pada StatsPage, ref.watch(statsProvider) dipanggil khusus di dalam fungsi build(). Sementara itu, untuk pemicu aksi di dalam callback tombol (onPressed), digunakan ref.invalidate(statsProvider) tanpa menggunakan ref.watch.<br>
Apakah ketiga state AsyncValue benar-benar ditangani (bukan hanya success)? <br>
jawab: <br>
Penggunaan method statsAsync.when(...) secara eksplisit menangani ketiga kondisi utama tanpa ada yang terlewat. <br>
Apakah provider dideklarasikan dengan tipe eksplisit dan tidak duplikat dengan provider lain? <br>
Jawab: <br>
Provider dideklarasikan dengan tipe generik yang sangat jelas dan eksplisit. <br>"final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(() { ... });" <br> Tidak ada tipe data yang tersembunyi (dynamic) dan tidak ada duplikasi variabel provider. <br>
Apakah kode AI memakai API Riverpod versi lama (StateProvider antipattern, StateNotifierProvider usang, atau Consumer bertingkat yang tidak perlu)? Perbaiki ke pola Notifier/ConsumerWidget. <br>
jawab: <br>
Kode sepenuhnya menggunakan Riverpod 2.x+ / 3.x Modern API: <br>
Menggunakan AsyncNotifier & AsyncNotifierProvider (Bukan StateNotifierProvider atau FutureProvider lama). <br>
Menghindari penggunaan StateProvider yang tergolong anti-pattern untuk complex state.
Menggunakan struktur ConsumerWidget bersih tanpa menyisipkan widget Consumer bertingkat yang tidak diperlukan. <br>
Jalankan flutter analyze dan flutter test, apakah hasil AI lolos tanpa warning? <br>
jawab: <br>
Iya, flutter analyze dan flutter test nya lulus tanpa warning. <br>

# Hasil IMAGE
### Praktikum 1
![Home page](Screenshots/home_page_praktikum1.png) <br>
![Detail/Item page](Screenshots/detail_page_praktikum1.png) <br>

### Praktikum 2
![Aplikasi Todo](Screenshots/todo_page_praktikum2.png) <br>
![List 1](Screenshots/todo_page_listbaru.png) <br>

### Praktikum 3
![Product Page](<Screenshots/product_page_praktikum 3.png>) <br>
![Percobaan Error](<Screenshots/product_page_error exception_praktikum3.png>) <br>
![loading screen](<Screenshots/product_page_loading screen_praktikum3.png>) <br>

### AI CHALLENGE
![aplikasi stats hasil AI](Screenshots/AI_challenge_stats_page.png) <br>
![Hasil test dan analyze](<Screenshots/AI_challenge_flutter test_flutter analyze.png>) <br>

### Tugas Refactoring
![Home page](Screenshots/tugas_refactoring_home.png) <br>
![stats page](Screenshots/tugas_refactoring_stats.png) <br>
![Hasil test dan analyze](Screenshots/tugas_refactoring_test_analyze.png) <br>