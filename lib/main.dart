import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuse_wallet_sdk/fuse_wallet_sdk.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'dart:async';

import 'package:web3auth_flutter/web3auth_flutter.dart';

const publicApiKey = 'pk_1J844BZf9gL7lHYObH1os_EF';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = '';
  bool logoutVisible = false;
  late FuseSDK fuseSDK;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    HashMap themeMap = HashMap<String, String>();
    themeMap['primary'] = "#229954";

    Uri redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl = Uri.parse('fuse-sdk-exmple://io.fuse.examplewallet/auth');
    } else if (Platform.isIOS) {
      redirectUrl = Uri.parse('io.fuse.examplewallet://openlogin');
    } else {
      throw UnKnownException('Unknown platform');
    }

    await Web3AuthFlutter.init(Web3AuthOptions(
      clientId:
          "BPjJLp88CkfXYBVYAGyqPBXjMHz6RPGZgf6OtBde0-QsoxINSAaCEYM9sCeD8trjwBe3l_lAvDQhQ3kqOCJKZGo",
      network: Network.mainnet,
      redirectUrl: redirectUrl,
      whiteLabel: WhiteLabelData(
        dark: true,
        name: "Web3Auth Flutter App",
        theme: themeMap,
      ),
    ));

    await Web3AuthFlutter.initialize();

    final String privateKey = await Web3AuthFlutter.getPrivKey();
    print(privateKey);
    if (privateKey.isNotEmpty) {
      print('Web3AuthResponse Success: $privateKey');
      fuseSDK =
          await FuseSDK.init(publicApiKey, EthPrivateKey.fromHex(privateKey));
      setState(() {});

      setState(() {
        logoutVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fuse Wallet SDK with Web3Auth Flutter Example'),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
              ),
              Visibility(
                visible: !logoutVisible,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const Icon(
                      Icons.flutter_dash,
                      size: 80,
                      color: Color(0xFF1389fd),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      'Web3Auth',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Color(0xFF0364ff)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Welcome to Web3Auth x Flutter Demo',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Login with',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: _login(_withGoogle),
                        child: const Text('Google')),
                    ElevatedButton(
                        onPressed: _login(_withFacebook),
                        child: const Text('Facebook')),
                    ElevatedButton(
                        onPressed: _login(_withEmailPasswordless),
                        child: const Text('Email Passwordless')),
                    ElevatedButton(
                        onPressed: _login(_withDiscord),
                        child: const Text('Discord')),
                  ],
                ),
              ),
              Visibility(
                // ignore: sort_child_properties_last
                child: Column(
                  children: [
                    Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red[600] // This is what you need!
                              ),
                          onPressed: _logout(),
                          child: Column(
                            children: const [
                              Text('Logout'),
                            ],
                          )),
                    ),
                    ElevatedButton(
                        onPressed: _smartWalletAddress(),
                        child: const Text('Get Smart Wallet Address')),
                    ElevatedButton(
                        onPressed: _privKey(_getPrivKey),
                        child: const Text('Get PrivKey')),
                    ElevatedButton(
                        onPressed: _userInfo(_getUserInfo),
                        child: const Text('Get UserInfo')),
                  ],
                ),
                visible: logoutVisible,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_result),
              )
            ],
          )),
        ),
      ),
    );
  }

  VoidCallback _login(Future<Web3AuthResponse> Function() method) {
    return () async {
      try {
        final Web3AuthResponse response = await method();
        setState(() {
          logoutVisible = true;
        });
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  }

  VoidCallback _logout() {
    return () async {
      try {
        await Web3AuthFlutter.logout();
        setState(() {
          _result = '';
          logoutVisible = false;
        });
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  }

  VoidCallback _smartWalletAddress() {
    return () async {
      final privateKey = await Web3AuthFlutter.getPrivKey();
      fuseSDK =
          await FuseSDK.init(publicApiKey, EthPrivateKey.fromHex(privateKey));
      final String response = fuseSDK.wallet.getSender();
      setState(() {
        _result = response;
        logoutVisible = true;
      });
    };
  }

  VoidCallback _privKey(Future<String?> Function() method) {
    return () async {
      try {
        final String? response = await Web3AuthFlutter.getPrivKey();
        setState(() {
          _result = response!;
          logoutVisible = true;
        });
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  }

  VoidCallback _userInfo(Future<TorusUserInfo> Function() method) {
    return () async {
      try {
        final TorusUserInfo response = await Web3AuthFlutter.getUserInfo();
        setState(() {
          _result = response.toString();
          logoutVisible = true;
        });
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  }

  Future<Web3AuthResponse> _withGoogle() {
    return Web3AuthFlutter.login(LoginParams(
      loginProvider: Provider.google,
      mfaLevel: MFALevel.NONE,
    ));
  }

  Future<Web3AuthResponse> _withFacebook() {
    return Web3AuthFlutter.login(LoginParams(loginProvider: Provider.facebook));
  }

  Future<Web3AuthResponse> _withEmailPasswordless() {
    return Web3AuthFlutter.login(LoginParams(
        loginProvider: Provider.email_passwordless,
        extraLoginOptions: ExtraLoginOptions(login_hint: "lior@fuse.io")));
  }

  Future<Web3AuthResponse> _withDiscord() {
    return Web3AuthFlutter.login(LoginParams(loginProvider: Provider.discord));
  }

  Future<String?> _getPrivKey() {
    return Web3AuthFlutter.getPrivKey();
  }

  Future<TorusUserInfo> _getUserInfo() {
    return Web3AuthFlutter.getUserInfo();
  }
}
