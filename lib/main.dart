import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ftest/Presentation/Authentication/Login.dart';
import 'package:ftest/Presentation/Home/HomePage.dart';
import 'package:ftest/firebase_options.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
// firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:share/share.dart';
import 'helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var isLogin = false;

  @override
  void initState() {
    isLogedin();
    // TODO: implement initState
    super.initState();
  }

  isLogedin() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          isLogin = true;
        });
      } else {
        setState(() {
          isLogin = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLogin == false ? Login() : HomePage(),
    );
  }
}

// Existing Code - Don't make any changes in this code
class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xactitude Attendance App')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const QRViewExample(),
                ));
              },
              child: const Text('SCAN'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const QRViewExample(),
                ));
              },
              child: const Text('HISTORY'),
            ),
          ),
        ],
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class Attendance {
  late String id;
  late DateTime time;
  Attendance(this.id, this.time);
}

class _QRViewExampleState extends State<QRViewExample> {
  String? result;
  String message = "Start scanning to take attendance";
  late List<Attendance> resultArr = <Attendance>[];
  late QRViewController controller;
  static List<String> events = <String>[
    'Codefi',
    'Websea',
    'Glitch',
    'Electrohertz',
    'Graphosnark',
    'IT Manager',
    'Fifa 22',
    'Valorant',
    'Keystrokes',
    'Viktoriin',
    'Ideathon',
    'Mathletes',
    'Food',
  ];
  String selectedEvent = events.first;
  Color? scanStatus;
  bool cameraPaused = false;
  bool saved = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 1, child: _buildQrView(context)),
          Expanded(flex: 2, child: _buildAttListView(context)),
        ],
      ),
    );
  }

  Widget _buildAttListView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        // MESSAGE GRAY
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    child: Text('${cameraPaused ? "Resume" : "Pause"} Camera'),
                    onPressed: () async {
                      await (cameraPaused
                          ? controller.resumeCamera()
                          : controller.pauseCamera());
                      setState(() {
                        cameraPaused = !cameraPaused;
                      });
                    },
                  ),
                  const Text('Event: '),
                  DropdownButton(
                    value: selectedEvent,
                    items: events
                        .map((value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedEvent = value!;
                      });
                    },
                  ),
                ],
              ),
              Text(
                message,
                style: const TextStyle(fontSize: 24, color: Colors.grey),
              ),
            ],
          ),
        ),
        // CODE LIST
        Expanded(
          flex: 5,
          child: Scrollbar(
            child: ListView.separated(
              itemBuilder: (context, index) => Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Text(
                        resultArr[index].id,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        timeFormat(resultArr[index].time),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        String? answer = await prompt(
                          context,
                          title: Text(
                              'ARE YOU SURE YOU WANT TO DELETE ATTENDANCE OF $result?'),
                          textOK: Text('I AM EXTREMELY SURE TO DELETE $result'),
                          textCancel: Text('NO DO NOT DELETE $result'),
                          initialValue: "no",
                          hintText: "type yes to delete",
                          textCapitalization: TextCapitalization.none,
                        );
                        if (answer != null && answer.toLowerCase() == 'yes') {
                          setState(() {
                            message = "${resultArr[index].id} Deleted";
                            scanStatus = Colors.red;
                            resultArr.removeAt(index);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('DID NOT DELETE $result'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: resultArr.length,
            ),
          ),
        ),
        Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: const Text(
                    "SAVE & SHARE",
                    style: TextStyle(fontSize: 32),
                  ),
                  onPressed: () async {
                    if (resultArr.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Cant Save Empty List. Take Attendance First')));
                      return;
                    }
                    String event =
                        selectedEvent.replaceAll(' ', '').toLowerCase();
                    String path = await saveCSV(resultArr, event);
                    if (path != "") {
                      Share.shareFiles(
                        [path],
                        subject: 'csv-$event-${DateTime.now()}.csv',
                        text: 'csv-$event-${DateTime.now()}.csv',
                      );
                      saved = true;
                    }
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    "END",
                    style: TextStyle(fontSize: 32),
                  ),
                  onPressed: () {
                    if (saved) {
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Save the file first!')));
                    }
                  },
                )
              ],
            ))
      ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how wide or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: scanStatus ?? Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 20,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != result) {
        if (validQR(scanData.code!)) {
          setState(() {
            result = scanData.code;
            if (!resultArr.map((e) => e.id).contains(result)) {
              resultArr.add(Attendance(result!, DateTime.now()));
              scanStatus = Colors.green;
              message = "Attendance Taken";
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext context, _, __) =>
                      const ScanOverlay(),
                ),
              );
            } else {
              scanStatus = Colors.orange;
              message = "$result already exists";
            }
          });
        } else {
          setState(() {
            message = "QR Code is not of a XACT participant";
            scanStatus = Colors.red;
          });
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScanOverlay extends StatelessWidget {
  const ScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.85),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
              child: Text(
            "Attendance Taken",
            style: TextStyle(fontSize: 32),
          )),
          ElevatedButton(
            autofocus: true,
            clipBehavior: Clip.antiAlias,
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
