# Refleksi
## Praktikum 3
1. mengapa menampilkan ulang data lama (stale data) dengan indikator refresh kadang lebih baik daripada mengosongkan layar? Kapan pola itu penting? <br>
jawab: <br>

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