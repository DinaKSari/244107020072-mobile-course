String? validateNoteTitle(String? value) =>
    (value ?? '').trim().isEmpty ? 'Judul wajib diisi.' : null;