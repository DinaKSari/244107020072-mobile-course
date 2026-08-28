# my_first_app

Penjelasan r dan R:
hot reload tekan r untuk mereload aplikasi nya, sedangkan hot restart tekan R untuk merestart aplikasi nya.

Buktinya:
saat hot reload di terminal ditampilkan text "Reloaded 1 of 754 libraries in 454ms (compile: 20 ms, reload: 211 ms, reassemble: 69 ms)". sedangkan hot restart di terminal ditampilkan text "Restarted application in 578ms."

Kendala yang dihadapi:
saat melakukan flutter doctor, sdk android studio saya tidak ke detect karena berbeda path dengan konfigurasi flutter doctor nya. 

solusi:
saya ganti dulu path yang ada di flutter doctor agar sesuai dengan path sdk saya. saya menggunakan 'flutter config --android-sdk "PATH"' dan akhirnya bisa ke detect. namun license nya status unknown, sudah jalanin 'flutter doctor --android-licenses' masih tetap unknown. Tapi ada warning 'Warning: The --licenses option is no longer needed.', jadi saya biarkan saja.

hasil:
cek 'flutter devices', device nya muncul di dalam list nya.