import 'package:flutter/material.dart';
import 'package:vantech/dashboard/dashboard.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: const Text(
          'Information',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animasi untuk bagian pertama
            const AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Text(
                'Sampah pada Lingkungan Kampus:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Text(
                'Tantangan dan Solusi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildParagraph(
                'Kampus adalah lingkungan dengan aktivitas yang sangat padat, dari kegiatan akademik, perkantoran, hingga mahasiswa yang menjalankan kehidupan sehari-hari. Ini menyebabkan tingginya produksi sampah yang beragam, mulai dari sampah makanan, kertas, plastik, hingga elektronik. Pengelolaan sampah yang tepat di lingkungan kampus sangat penting untuk menjaga kebersihan, kenyamanan, dan kelestarian lingkungan.'),
            const SizedBox(height: 16),

            const AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Text(
                'Perbedaan Sampah Organik & Anorganik',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildParagraph(
                'Sampah organik berasal dari makhluk hidup, sedangkan sampah anorganik merupakan hasil dari benda mati atau buatan manusia. Sampah organik mengandung karbon dan hidrogen serta berasal dari makhluk hidup atau sisa-sisa organisme. Komposisinya lebih kompleks dibandingkan dengan sampah anorganik. Sebaliknya, sampah anorganik tidak mengandung karbon, tersusun dari bahan tak hidup, dan memiliki sifat-sifat mineral. Sampah organik dapat terbakar secara alami saat terkena panas. Sebaliknya, sampah anorganik tidak mudah terbakar secara alami.'),
            const SizedBox(height: 16),

            const AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Text(
                'Jenis Sampah di Lingkungan Kampus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildParagraph(
                'Memisahkan sampah organik dan non-organik tidak hanya memudahkan pembuangan dan daur ulang, tetapi juga mencegah penumpukan sampah yang bisa menjadi sarang kuman penyebab penyakit. Penumpukan sampah berisiko mencemari udara dan memicu masalah kesehatan, terutama terkait paru-paru dan pernapasan. Selain itu, tumpukan sampah dapat menyebabkan banjir, mencemari air, dan menimbulkan penyakit kulit, mual, muntah, serta diare. Dengan pemisahan sampah, udara lebih sehat, lingkungan bersih, dan pengolahan sampah jadi lebih mudah.'),
            const SizedBox(height: 8),

            const AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Text(
                'Jenis Sampah di Lingkungan Kampus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Sampah Organik
            const AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Text(
                'Sampah Organik:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoints([
              'Sumber: Kantin, makanan sisa',
              'Contoh: Sisa makanan, kulit buah, daun kering',
              'Pengelolaan yang tepat: Sampah organik dapat dikomposkan menjadi penghijauan',
            ]),

            // Sampah Anorganik
            const AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Text(
                'Sampah Anorganik:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoints([
              'Sumber: Kantor administrasi, ruang kelas, laboratorium',
              'Contoh: Kertas, kemasan, kaleng, sampah elektronik',
              'Pengelolaan yang Tepat: Sampah anorganik harus dibuang dengan benar dan karilasan dipilah diterapkan untuk daur ulang',
            ]),

            // Sampah Plastik
            const AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Text(
                'Sampah Plastik:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoints([
              'Sumber: Penggunaan botol air kemasan, kemasan makanan, dan plastik non-tulis',
              'Contoh: Botol minuman plastik, kemasan makanan',
              'Pengelolaan yang Tepat: Kampus harus patuh pada penyediaan tempat daur ulang plastik. Mengurangi penggunaan botol minum plastik atau menggunakan tumbler pribadi.',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(seconds: 1),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: points
            .map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
