import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfDownloadPage extends StatefulWidget {
  const PdfDownloadPage({super.key});

  @override
  State<PdfDownloadPage> createState() => _PdfDownloadPageState();
}

class _PdfDownloadPageState extends State<PdfDownloadPage> {
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
    List<FileSystemEntity> imageList = path.listSync();
    streamSink.add(imageList);
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
                await downloadPdf(pdfUrlList[2])
                    .then((value) => getDownloadedPdf());
              },
              icon: const Icon(Icons.download))
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            log(snapshot.data.toString());
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(snapshot.data![index].path.split('/').last),
                    trailing: Text('${index + 1}'),
                    onTap: () async {
                      // await OpenFile.open(snapshot.data![index].path);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OfflinePdfViewer(
                              pdfLink: snapshot.data![index].path),
                        ),
                      );
                    },
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return const Text('Snapshot has Error');
            } else {
              return const Text('No Image');
            }
          },
        ),
      ),
    );
  }
}

StreamController<List<FileSystemEntity>> streamController = StreamController();
StreamSink streamSink = streamController.sink;
Stream<List<FileSystemEntity>> stream = streamController.stream;

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
