import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfDownloadFuturePage extends StatefulWidget {
  const PdfDownloadFuturePage({super.key});

  @override
  State<PdfDownloadFuturePage> createState() => _PdfDownloadFuturePageState();
}

class _PdfDownloadFuturePageState extends State<PdfDownloadFuturePage> {
  List<FileSystemEntity> imageList = [];
  Future<void> downloadPdf(String url) async {
    Directory? directory = await getExternalStorageDirectory();
    String savePath = '${directory!.path}/Pdf/${url.split('/').last}';
    log('urlPath => $savePath');
    await Dio().download(
      url,
      savePath,
      onReceiveProgress: (count, total) => log('count/total => $count/$total'),
    );
  }

  Future<void> getDownloadedPdf() async {
    Directory? directory = await getExternalStorageDirectory();
    Directory path = Directory('${directory!.path}/Pdf/');
    setState(() => imageList = path.listSync());
    log('imageList :$imageList');
  }

  @override
  void initState() {
    super.initState();
    getDownloadedPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download & Open File'),
        actions: [
          IconButton(
              onPressed: () async {
                await downloadPdf(pdfUrlList[3])
                    .then((value) => getDownloadedPdf());
              },
              icon: const Icon(Icons.download))
        ],
      ),
      body: imageList.isEmpty
          ? const Center(
              child: Text('Empty Data'),
            )
          : ListView.builder(
              itemCount: imageList.length,
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(imageList[index].path.split('/').last),
                  trailing: IconButton(
                    onPressed: () {
                      imageList[index]
                          .delete()
                          .then((value) => getDownloadedPdf());
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  onTap: () async {
                    // await OpenFile.open(imageList[index].path); // outside app
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OfflinePdfViewer(
                            pdfLink: imageList[index].path), // inside app
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

List<String> pdfUrlList = [
  'https://www.africau.edu/images/default/sample.pdf',
  'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
  'https://unec.edu.az/application/uploads/2014/12/pdf-sample.pdf',
  'https://filesamples.com/samples/document/pdf/sample3.pdf',
  'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
];

class OfflinePdfViewer extends StatelessWidget {
  final String pdfLink;
  const OfflinePdfViewer({super.key, required this.pdfLink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Pdf Viewer'),
      ),
      body: SfPdfViewer.file(
        File(pdfLink),
      ),
    );
  }
}
